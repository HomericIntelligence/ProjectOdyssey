# Issue #1864: Fix Bare Exception Handlers Across Codebase

## Overview

Replace 80+ bare `except:` clauses with specific exception types to improve error handling and debuggability.

## Problem

Bare `except:` clauses catch all exceptions including system exceptions (KeyboardInterrupt, SystemExit), making debugging difficult and hiding bugs.

## Scope

Approximately 80+ instances found across:

- `shared/utils/config.mojo` (6 instances)
- `shared/utils/io.mojo` (9 instances)
- `tests/` directory (40+ instances)
- `benchmarks/` directory (3 instances)
- `scripts/` directory (3 instances)

## Solution

Replace each `except:` with appropriate specific exception types:

### Example Transformations

```python
# Before
try:
    value = config.get("key")
except:
    value = default

# After
try:
    value = config.get("key")
except (KeyError, AttributeError) as e:
    logging.debug(f"Config key not found: {e}")
    value = default
```

## Files to Fix

1. **scripts/validate_links.py** (line 72)
   - Change to: `except (ValueError, TypeError)`

1. **scripts/check_readmes.py** (line 163)
   - Change to: `except (OSError, UnicodeDecodeError) as e`

1. **scripts/batch_planning_docs.py** (line 120)
   - Change to: `except (OSError, JSONDecodeError) as e`

1. **scripts/merge_issue_reports.py** (line 89)
   - Change to: `except (FileNotFoundError, PermissionError) as e`

## Implementation Strategy

1. Identify what exceptions each block actually handles
1. Add specific exception types
1. Add logging for caught exceptions
1. Test each fix to ensure no behavior changes
1. Add linting rule to prevent future bare except clauses

## Testing

For each file:

1. Run existing tests before changes
1. Make exception type specific
1. Run tests again to verify no regressions
1. Add test case for the specific exception if needed

## Benefits

- Easier debugging (specific exceptions logged)
- Won't accidentally catch system exceptions
- Better error messages
- Code quality improvement

## Status

**DEFERRED** - Marked for follow-up PR

Large scope (80+ instances) requires careful testing of each change.

## Related Issues

Part of Wave 2 tooling improvements from continuous improvement session.
Originally identified in security audit as lower-priority issue.
