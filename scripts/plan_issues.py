#!/usr/bin/env python3
"""
plan_issues.py

Python replacement for plan-issues.sh.

Design goals:
- Exact behavioral parity with Bash version
- No shell injection surface
- Deterministic, debuggable execution
- Better structure, resumability, throttling, JSON output
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional, Iterable

# ---------------------------------------------------------------------
# Constants (match bash defaults)
# ---------------------------------------------------------------------

MAX_ISSUES_FETCH = 500
MAX_RETRIES = 3
CLAUDE_MAX_TOOLS = 50
CLAUDE_MAX_STEPS = 50

ALLOWED_EDITORS = {"vim", "vi", "emacs", "nano", "code", "subl", "nvim", "helix", "micro", "edit"}

ALLOWED_TIMEZONES = {
    "America/Los_Angeles",
    "America/New_York",
    "America/Chicago",
    "America/Denver",
    "America/Phoenix",
    "UTC",
    "Europe/London",
    "Europe/Paris",
    "Asia/Tokyo",
}

RATE_LIMIT_RE = re.compile(
    r"Limit reached.*resets\s+(?P<time>[0-9:apm]+)\s*\((?P<tz>[^)]+)\)",
    re.IGNORECASE,
)

# ---------------------------------------------------------------------
# Structured logging
# ---------------------------------------------------------------------


def log(level: str, msg: str) -> None:
    ts = time.strftime("%H:%M:%S")
    out = sys.stderr if level in {"WARN", "ERROR"} else sys.stdout
    print(f"[{level}] {ts} {msg}", file=out, flush=True)


# ---------------------------------------------------------------------
# Subprocess helpers
# ---------------------------------------------------------------------


def run(cmd: list[str], *, timeout: Optional[int] = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
        check=False,
    )


# ---------------------------------------------------------------------
# Rate-limit handling (matches bash logic)
# ---------------------------------------------------------------------


def parse_reset_epoch(time_str: str, tz: str) -> int:
    if tz not in ALLOWED_TIMEZONES:
        tz = "America/Los_Angeles"

    now_utc = dt.datetime.now(dt.timezone.utc)
    today = now_utc.astimezone(dt.ZoneInfo(tz)).date()

    m = re.match(r"^(\d{1,2})(?::(\d{2}))?(am|pm)?$", time_str, re.I)
    if not m:
        return int(time.time()) + 3600

    hour, minute, ampm = m.groups()
    hour = int(hour)
    minute = int(minute or 0)

    if ampm:
        ampm = ampm.lower()
        if ampm == "pm" and hour < 12:
            hour += 12
        if ampm == "am" and hour == 12:
            hour = 0

    local = dt.datetime.combine(
        today,
        dt.time(hour, minute),
        tzinfo=dt.ZoneInfo(tz),
    )

    if local < now_utc.astimezone(dt.ZoneInfo(tz)):
        local += dt.timedelta(days=1)

    return int(local.timestamp())


def detect_rate_limit(text: str) -> Optional[int]:
    m = RATE_LIMIT_RE.search(text)
    if not m:
        return None
    return parse_reset_epoch(m.group("time"), m.group("tz"))


def wait_until(epoch: int) -> None:
    while True:
        remaining = epoch - int(time.time())
        if remaining <= 0:
            print()
            return
        h, r = divmod(remaining, 3600)
        m, s = divmod(r, 60)
        print(f"\r[INFO] Rate limit resets in {h:02d}:{m:02d}:{s:02d}", end="", flush=True)
        time.sleep(1)


# ---------------------------------------------------------------------
# GitHub helpers
# ---------------------------------------------------------------------


def gh_issue_json(issue: int) -> dict:
    cp = run(["gh", "issue", "view", str(issue), "--json", "title,body,comments"])
    if cp.returncode != 0:
        raise RuntimeError(cp.stderr.strip())
    return json.loads(cp.stdout)


# ---------------------------------------------------------------------
# Options
# ---------------------------------------------------------------------


@dataclasses.dataclass(frozen=True)
class Options:
    auto: bool
    replan: bool
    replan_reason: Optional[str]
    dry_run: bool
    cleanup: bool
    parallel: bool
    max_parallel: int
    timeout: int
    throttle_seconds: float
    json_output: bool


@dataclasses.dataclass
class Result:
    issue: int
    status: str
    error: Optional[str] = None


# ---------------------------------------------------------------------
# Planner
# ---------------------------------------------------------------------


class Planner:
    def __init__(self, repo_root: pathlib.Path, tempdir: pathlib.Path, opts: Options):
        self.repo_root = repo_root
        self.tempdir = tempdir
        self.opts = opts

        prompt_path = repo_root / ".claude/agents/chief-architect.md"
        if not prompt_path.exists():
            raise RuntimeError(f"Missing system prompt: {prompt_path}")
        self.system_prompt = prompt_path.read_text()

        self._throttle_lock = threading.Lock()
        self._last_call = 0.0

    # --------------------------------------------------------------

    def fetch_issues(self, explicit: Optional[list[int]], limit: Optional[int]) -> list[int]:
        if explicit:
            return explicit

        cp = run(["gh", "issue", "list", "--state", "open", "--limit", str(MAX_ISSUES_FETCH), "--json", "number"])
        if cp.returncode != 0:
            raise RuntimeError(cp.stderr)

        issues = [i["number"] for i in json.loads(cp.stdout)]
        return issues[:limit] if limit else issues

    # --------------------------------------------------------------

    def process_issue(self, issue: int, idx: int, total: int) -> Result:
        state_file = self.tempdir / f"issue-{issue}.state"
        if state_file.exists() and not self.opts.replan:
            return Result(issue, "skipped")

        try:
            log("INFO", f"[{idx}/{total}] Issue #{issue}")
            data = gh_issue_json(issue)

            title = (data.get("title") or "Untitled")[:500]
            body = data.get("body") or ""

            if not self.opts.replan:
                for c in data.get("comments", []):
                    if "## Detailed Implementation Plan" in (c.get("body") or ""):
                        state_file.write_text("skipped")
                        return Result(issue, "skipped")

            plan = self.generate_plan(issue, title, body)

            if not plan.strip():
                raise RuntimeError("Empty plan")

            if not self.opts.auto:
                plan = self.review_plan(plan)
                if not plan.strip():
                    state_file.write_text("skipped")
                    return Result(issue, "skipped")

            if self.opts.dry_run:
                self.show_diff(issue, plan)
                state_file.write_text("dry-run")
                return Result(issue, "dry-run")

            self.post_plan(issue, plan)
            state_file.write_text("posted")
            return Result(issue, "posted")

        except Exception as e:
            state_file.write_text("error")
            return Result(issue, "error", str(e))

    # --------------------------------------------------------------

    def throttle(self) -> None:
        if self.opts.throttle_seconds <= 0:
            return
        with self._throttle_lock:
            now = time.time()
            delta = now - self._last_call
            if delta < self.opts.throttle_seconds:
                time.sleep(self.opts.throttle_seconds - delta)
            self._last_call = time.time()

    # --------------------------------------------------------------

    def generate_plan(self, issue: int, title: str, body: str) -> str:
        prompt = self.build_prompt(issue, title, body)

        for attempt in range(1, MAX_RETRIES + 1):
            self.throttle()

            cp = run(
                [
                    "claude",
                    "--model",
                    "opus",
                    "--add-dir",
                    str(self.repo_root),
                    "--system-prompt",
                    self.system_prompt,
                    "-p",
                    prompt,
                ],
                timeout=self.opts.timeout,
            )

            combined = cp.stdout + cp.stderr
            reset = detect_rate_limit(combined)
            if reset:
                wait_until(reset)
                continue

            if cp.returncode == 0:
                return cp.stdout

            time.sleep(2**attempt)

        raise RuntimeError("Claude retries exceeded")

    # --------------------------------------------------------------

    def build_prompt(self, issue: int, title: str, body: str) -> str:
        parts = [
            "Create a detailed implementation plan for the following GitHub issue:\n\n",
            f"Issue #{issue}: {title}\n\n",
            body,
        ]

        if self.opts.replan:
            parts.append("\nNOTE: This is a REPLAN request.\n")
            if self.opts.replan_reason:
                parts.append(f"REPLAN REASON: {self.opts.replan_reason}\n")

        parts.append(
            f"""

BUDGET: You have a maximum of {CLAUDE_MAX_TOOLS} tool calls and {CLAUDE_MAX_STEPS} steps.

Output markdown with:
1. Summary
2. Step-by-step implementation tasks
3. Files to modify/create
4. Testing approach
5. Success criteria

End with:
## Resource Usage
"""
        )
        return "".join(parts)

    # --------------------------------------------------------------

    def review_plan(self, plan: str) -> str:
        editor = os.environ.get("EDITOR", "vim")
        cmd = pathlib.Path(editor).name
        if cmd not in ALLOWED_EDITORS:
            log("WARN", f"Editor '{cmd}' not approved, using vim")
            editor = "vim"

        path = self.tempdir / "review.md"
        path.write_text(plan)

        subprocess.run([editor, str(path)])
        return path.read_text()

    # --------------------------------------------------------------

    def post_plan(self, issue: int, plan: str) -> None:
        header = "## Detailed Implementation Plan"
        if self.opts.replan:
            header += " (Revised)"
        header += "\n\n"

        if self.opts.replan_reason:
            header += f"**Replan reason:** {self.opts.replan_reason}\n\n"

        proc = subprocess.Popen(
            ["gh", "issue", "comment", str(issue), "--body-file", "-"],
            stdin=subprocess.PIPE,
            text=True,
        )
        assert proc.stdin
        proc.stdin.write(header)
        proc.stdin.write(plan)
        proc.stdin.close()
        proc.wait()

        if proc.returncode != 0:
            raise RuntimeError("Failed to post comment")

    # --------------------------------------------------------------

    def show_diff(self, issue: int, plan: str) -> None:
        log("INFO", f"[DRY RUN] Issue #{issue}")
        print(plan[:2000])


# ---------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--limit", type=int)
    p.add_argument("--issues")
    p.add_argument("--auto", action="store_true")
    p.add_argument("--replan", action="store_true")
    p.add_argument("--replan-reason")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--cleanup", action="store_true")
    p.add_argument("--parallel", action="store_true")
    p.add_argument("--max-parallel", type=int, default=4)
    p.add_argument("--timeout", type=int, default=600)
    p.add_argument("--throttle", type=float, default=0.0)
    p.add_argument("--json", action="store_true")

    args = p.parse_args()

    if args.parallel and not args.auto:
        p.error("--parallel requires --auto")

    issues = [int(i) for i in args.issues.split(",")] if args.issues else None

    opts = Options(
        auto=args.auto,
        replan=args.replan or bool(args.replan_reason),
        replan_reason=args.replan_reason,
        dry_run=args.dry_run,
        cleanup=args.cleanup,
        parallel=args.parallel,
        max_parallel=args.max_parallel,
        timeout=args.timeout,
        throttle_seconds=args.throttle,
        json_output=args.json,
    )

    repo_root = pathlib.Path(__file__).resolve().parents[1]
    tempdir = pathlib.Path(tempfile.mkdtemp(prefix="plan-issues-"))
    log("INFO", f"Temp directory: {tempdir}")

    planner = Planner(repo_root, tempdir, opts)
    issue_list = planner.fetch_issues(issues, args.limit)

    results: list[Result] = []

    if opts.parallel:
        with ThreadPoolExecutor(max_workers=opts.max_parallel) as ex:
            futures = {
                ex.submit(planner.process_issue, issue, i + 1, len(issue_list)): issue
                for i, issue in enumerate(issue_list)
            }
            for f in as_completed(futures):
                results.append(f.result())
    else:
        for i, issue in enumerate(issue_list):
            results.append(planner.process_issue(issue, i + 1, len(issue_list)))

    if opts.json_output:
        print(json.dumps([dataclasses.asdict(r) for r in results], indent=2))
    else:
        posted = sum(1 for r in results if r.status == "posted")
        skipped = len(results) - posted
        log("INFO", f"Posted: {posted}")
        log("INFO", f"Skipped: {skipped}")

    if opts.cleanup:
        shutil.rmtree(tempdir, ignore_errors=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
