#!/usr/bin/env python3
"""
Validate Test Coverage - Ensure all test_*.mojo files are covered by CI

This script finds all test_*.mojo files in the repository and verifies they are
included in the CI test matrix in .github/workflows/comprehensive-tests.yml.

Exit codes:
  0 - All tests covered
  1 - Uncovered tests found or validation errors

Usage:
    python scripts/validate_test_coverage.py
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Set, Tuple
import yaml


def find_test_files(root_dir: Path) -> List[Path]:
    """Find all test_*.mojo files, excluding build artifacts and examples."""
    test_files = []

    # Exclude patterns for directories we don't want to scan
    exclude_patterns = [
        ".pixi/",
        "build/",
        "dist/",
        "__pycache__/",
        ".git/",
        "worktrees/",
        # Examples are tested separately and may require datasets
        # Only specific example tests are included in CI (e.g., test_lenet5.mojo)
    ]

    for test_file in root_dir.rglob("test_*.mojo"):
        # Check if file is in an excluded directory
        if any(exclude in str(test_file) for exclude in exclude_patterns):
            continue

        test_files.append(test_file.relative_to(root_dir))

    return sorted(test_files)


def parse_ci_matrix(workflow_file: Path) -> Dict[str, Dict[str, str]]:
    """Parse the CI workflow YAML to extract test groups and their patterns."""

    with open(workflow_file, "r") as f:
        workflow = yaml.safe_load(f)

    # Navigate to the test matrix
    try:
        jobs = workflow["jobs"]
        test_job = jobs.get("test-mojo-comprehensive", {})
        strategy = test_job.get("strategy", {})
        matrix = strategy.get("matrix", {})
        test_groups = matrix.get("test-group", [])
    except (KeyError, TypeError) as e:
        print(f"❌ Error parsing workflow file: {e}", file=sys.stderr)
        sys.exit(1)

    # Build a mapping of group name -> (path, pattern)
    groups = {}
    for group in test_groups:
        name = group.get("name")
        path = group.get("path")
        pattern = group.get("pattern")

        if name and path and pattern:
            groups[name] = {"path": path, "pattern": pattern}

    return groups


def expand_pattern(base_path: str, pattern: str, root_dir: Path) -> Set[Path]:
    """Expand a test pattern to actual file paths."""
    matched_files = set()

    # Split pattern by spaces (multiple patterns)
    patterns = pattern.split()

    for pat in patterns:
        # Handle wildcard patterns
        if "*" in pat:
            # Construct the full glob pattern
            full_pattern = f"{base_path}/{pat}"
            for match in root_dir.glob(full_pattern):
                if match.is_file():
                    matched_files.add(match.relative_to(root_dir))
        else:
            # Direct file reference or subdirectory pattern
            if "/" in pat:
                # Subdirectory pattern like "datasets/test_*.mojo"
                full_pattern = f"{base_path}/{pat}"
                for match in root_dir.glob(full_pattern):
                    if match.is_file():
                        matched_files.add(match.relative_to(root_dir))
            else:
                # Direct file
                full_path = root_dir / base_path / pat
                if full_path.is_file():
                    matched_files.add(full_path.relative_to(root_dir))

    return matched_files


def check_coverage(
    test_files: List[Path], ci_groups: Dict[str, Dict[str, str]], root_dir: Path
) -> Tuple[Set[Path], Dict[str, Set[Path]]]:
    """
    Check which test files are covered by CI matrix.

    Returns:
        (uncovered_files, group_coverage_map)
    """
    all_covered = set()
    coverage_by_group = {}

    for group_name, group_info in ci_groups.items():
        covered = expand_pattern(group_info["path"], group_info["pattern"], root_dir)
        coverage_by_group[group_name] = covered
        all_covered.update(covered)

    uncovered = set(test_files) - all_covered

    return uncovered, coverage_by_group


def main():
    """Main validation logic."""
    # Determine repository root (script is in scripts/)
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent

    print("=" * 70)
    print("Test Coverage Validation")
    print("=" * 70)
    print()

    # Find all test files
    print("🔍 Finding all test_*.mojo files...")
    test_files = find_test_files(repo_root)
    print(f"   Found {len(test_files)} test files")
    print()

    # Parse CI workflow
    workflow_file = repo_root / ".github" / "workflows" / "comprehensive-tests.yml"
    print(f"📋 Parsing CI workflow: {workflow_file.relative_to(repo_root)}")

    if not workflow_file.exists():
        print(f"❌ Workflow file not found: {workflow_file}", file=sys.stderr)
        sys.exit(1)

    ci_groups = parse_ci_matrix(workflow_file)
    print(f"   Found {len(ci_groups)} test groups in CI matrix")
    print()

    # Check coverage
    print("🔬 Analyzing coverage...")
    uncovered, coverage_by_group = check_coverage(test_files, ci_groups, repo_root)

    # Report results
    print()
    print("=" * 70)
    print("Coverage Report")
    print("=" * 70)
    print()

    if not uncovered:
        print("✅ All test files are covered by CI!")
        print()
        print(f"   Total test files: {len(test_files)}")
        print(f"   Covered by {len(ci_groups)} test groups")
        print()

        # Show coverage breakdown
        print("Coverage by test group:")
        for group_name in sorted(coverage_by_group.keys()):
            count = len(coverage_by_group[group_name])
            print(f"   • {group_name}: {count} test(s)")

        return 0

    # Report uncovered files
    print(f"❌ Found {len(uncovered)} uncovered test file(s):")
    print()

    for test_file in sorted(uncovered):
        print(f"   • {test_file}")

    print()
    print("=" * 70)
    print("Recommendations")
    print("=" * 70)
    print()
    print("Add missing test files to .github/workflows/comprehensive-tests.yml")
    print("by updating the appropriate test group or creating a new one.")
    print()
    print("Example test groups to consider:")
    print()

    # Suggest groups based on uncovered paths
    suggestions = {}
    for test_file in sorted(uncovered):
        parts = test_file.parts
        if len(parts) >= 2:
            suggested_group = parts[1]  # e.g., "shared", "configs", etc.
            if suggested_group not in suggestions:
                suggestions[suggested_group] = []
            suggestions[suggested_group].append(test_file)

    for group, files in sorted(suggestions.items()):
        print(f'  - name: "{group.title()}"')
        print(f'    path: "{files[0].parent}"')
        print(f'    pattern: "test_*.mojo"')
        print()

    return 1


if __name__ == "__main__":
    sys.exit(main())
