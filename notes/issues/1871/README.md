# Issue #1871: Add Concurrent GitHub API Calls with ThreadPoolExecutor

## Overview

Implement parallel issue creation using ThreadPoolExecutor to speed up bulk issue creation operations.

## Current Behavior

`scripts/create_issues.py` creates issues sequentially, taking 2+ seconds per issue due to rate limiting. Creating 100 issues takes 3-4 minutes.

## Proposed Solution

Use `ThreadPoolExecutor` to create multiple issues concurrently while respecting rate limits:

```python
from concurrent.futures import ThreadPoolExecutor, as_completed

def create_issues_concurrent(components: List[Component], max_workers: int = 5):
    """Create issues concurrently using thread pool."""
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(create_single_issue, comp): comp
            for comp in components
        }

        for future in as_completed(futures):
            component = futures[future]
            try:
                issue_number = future.result()
                logging.info(f"Created issue #{issue_number} for {component.name}")
            except Exception as e:
                logging.error(f"Failed to create issue for {component.name}: {e}")
```

## Implementation Details

- Add `--workers N` argument (default: 5)
- Coordinate with smart rate limiting (#1870)
- Add progress bar showing concurrent progress
- Handle failures gracefully with retry logic
- Update resume functionality for concurrent mode

## Benefits

- 5x faster issue creation (100 issues in <1 minute)
- Better resource utilization
- Maintains rate limit safety
- Configurable concurrency level

## Trade-offs

- More complex error handling
- Requires coordination with rate limiting
- Log output may be interleaved
- Resume state management more complex

## Status

**DEFERRED** - Marked for follow-up PR

Depends on #1870 (smart rate limiting) for optimal performance.

## Related Issues

Part of Wave 2 tooling improvements from continuous improvement session.
