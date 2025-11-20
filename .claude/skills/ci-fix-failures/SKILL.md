---
name: ci-fix-failures
description: Diagnose and fix CI/CD failures by analyzing logs, reproducing locally, and applying fixes. Use when CI checks fail on pull requests.
---

# Fix CI Failures Skill

Diagnose and fix CI/CD failures systematically.

## When to Use

- CI checks fail on PR
- Workflow runs fail
- Tests pass locally but fail in CI
- Need to debug CI issues

## Diagnosis Workflow

### 1. Check CI Status

```bash
# View PR checks
gh pr checks <pr-number>

# View specific run
gh run view <run-id>

# Get failed logs
gh run view <run-id> --log-failed
```text

### 2. Identify Failure

```bash
# Download logs
gh run download <run-id>

# Or view online
gh run view <run-id> --web
```text

### 3. Reproduce Locally

```bash
# Run same commands as CI
./scripts/reproduce_ci.sh <run-id>
```text

## Common Failures

### 1. Pre-commit Failures

```text
Trailing whitespace....Failed
```text

### Fix:

```bash
pre-commit run --all-files
git add .
git commit --amend --no-edit
git push --force-with-lease
```text

### 2. Test Failures

```text
test_tensor_add....FAILED
```text

### Fix:

```bash
# Run tests locally
mojo test tests/

# Fix failing test
# Re-run to verify
# Push fix
```text

### 3. Linting Failures

```text
Markdown lint....Failed
```text

### Fix:

```bash
npx markdownlint-cli2 --fix "**/*.md"
git add .
git commit -m "fix: markdown linting"
git push
```text

### 4. Build Failures

```text
Error: Cannot find module
```text

### Fix:

```bash
# Check dependencies
# Update imports
# Re-build locally
# Push fix
```text

## Fixing Workflow

```bash
# 1. Get failure logs
./scripts/get_ci_logs.sh <pr-number>

# 2. Reproduce locally
./scripts/reproduce_ci_failure.sh

# 3. Fix issue
# ... make changes

# 4. Verify fix
./scripts/run_ci_locally.sh

# 5. Push fix
git add .
git commit -m "fix: address CI failure"
git push

# 6. Verify CI passes
gh pr checks <pr-number> --watch
```text

## Scripts

- `scripts/get_ci_logs.sh` - Download CI logs
- `scripts/reproduce_ci_failure.sh` - Reproduce locally
- `scripts/run_ci_locally.sh` - Run CI checks locally
- `scripts/fix_common_ci_issues.sh` - Auto-fix common issues

## Prevention

- Run pre-commit before pushing
- Run tests locally
- Check formatting
- Review CI logs regularly

See `.github/workflows/` for workflow definitions.
