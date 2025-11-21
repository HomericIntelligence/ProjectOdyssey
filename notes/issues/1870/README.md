# Issue #1870: Implement Smart Rate Limiting for GitHub API Calls

## Overview

Replace hardcoded `time.sleep(2)` with intelligent rate limiting based on actual GitHub API rate limit status.

## Current Behavior

`scripts/create_issues.py` line 649 uses hardcoded 2-second sleep after every API call, which is inefficient and slows down issue creation unnecessarily.

## Proposed Solution

Implement `smart_rate_limit_sleep()` function that:

- Checks actual GitHub API rate limit via `gh api rate_limit`
- Sleeps only when necessary based on remaining calls
- Uses exponential backoff when rate limit is low
- No sleep when rate limit is healthy (>100 remaining)

## Implementation Approach

```python
def check_github_rate_limit() -> Tuple[int, float]:
    """Check GitHub API rate limit status."""
    result = subprocess.run(
        ["gh", "api", "rate_limit"],
        capture_output=True,
        text=True
    )
    data = json.loads(result.stdout)
    remaining = data["resources"]["core"]["remaining"]
    reset_time = data["resources"]["core"]["reset"]
    return remaining, reset_time

def smart_rate_limit_sleep():
    """Sleep only if necessary based on rate limit."""
    remaining, reset_time = check_github_rate_limit()

    if remaining < 10:
        # Critical - wait until reset
        wait_time = max(0, reset_time - time.time())
        if wait_time > 0:
            logging.warning(f"Rate limit critical, waiting {wait_time:.0f}s")
            time.sleep(min(wait_time, 60))
    elif remaining < 100:
        # Low - exponential backoff
        backoff = (100 - remaining) / 20
        time.sleep(backoff)
    # Otherwise no sleep - rate limit is healthy
```

## Benefits

- Faster issue creation when rate limit is healthy
- Intelligent backoff when rate limit is low
- Prevents rate limit exhaustion
- Better user experience

## Status

**DEFERRED** - Marked for follow-up PR

## Related Issues

Part of Wave 2 tooling improvements from continuous improvement session.
