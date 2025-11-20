---
name: quality-run-linters
description: Run all configured linters including mojo format, markdownlint, and pre-commit hooks. Use before committing code to ensure quality standards are met.
---

# Run Linters Skill

This skill runs all configured linters to ensure code quality standards.

## When to Use

- User asks to run linters (e.g., "run all linters")
- Before committing code
- CI/CD quality checks
- Pre-PR validation
- Troubleshooting quality issues

## Configured Linters

### 1. Mojo Format

Formats Mojo code files:

```bash
mojo format src/**/*.mojo
```text

### 2. Markdownlint

Lints markdown files:

```bash
npx markdownlint-cli2 "**/*.md"
```text

### 3. Pre-commit Hooks

Runs all pre-commit hooks:

```bash
pre-commit run --all-files
```text

Includes:

- Trailing whitespace removal
- End-of-file fixer
- YAML validation
- Large file check
- Mixed line ending fix

## Usage

### Run All Linters

```bash
# Run all linters with one command
./scripts/run_all_linters.sh

# This runs
# 1. mojo format
# 2. markdownlint
# 3. pre-commit hooks
```text

### Run Specific Linter

```bash
# Mojo only
./scripts/run_linters.sh --mojo

# Markdown only
./scripts/run_linters.sh --markdown

# Pre-commit only
./scripts/run_linters.sh --precommit
```text

### Fix Mode vs Check Mode

```bash
# Fix mode (auto-fix issues)
./scripts/run_linters.sh --fix

# Check mode (report only, no changes)
./scripts/run_linters.sh --check
```text

## Linter Details

### Mojo Format

### What it checks:

- Indentation (4 spaces)
- Line length
- Spacing around operators
- Blank line consistency

**Auto-fix**: Yes

```bash
# Fix formatting
mojo format src/tensor.mojo

# Check only
mojo format --check src/tensor.mojo
```text

### Markdownlint

### What it checks:

- Code blocks have language specified
- Blank lines around code blocks/lists/headings
- Line length (120 chars)
- Consistent heading style

**Auto-fix**: Partial

```bash
# Lint markdown
npx markdownlint-cli2 "**/*.md"

# Fix some issues
npx markdownlint-cli2 --fix "**/*.md"
```text

### Pre-commit Hooks

### What it checks:

- Trailing whitespace
- File ends with newline
- YAML syntax
- Large files
- Mixed line endings

**Auto-fix**: Yes (most checks)

```bash
# Run all hooks
pre-commit run --all-files

# Run specific hook
pre-commit run trailing-whitespace --all-files
```text

## Common Issues

### Mojo Format Failures

```text
Error: Syntax error in file.mojo
```text

**Fix**: Correct syntax errors before formatting

### Markdown Linting Failures

```text
MD040: Code blocks should have language specified
```text

**Fix**: Add language to code blocks (` ```python `)

```text
MD031: Code blocks should be surrounded by blank lines
```text

**Fix**: Add blank lines before and after code blocks

### Pre-commit Failures

```text
Trailing whitespace found
```text

**Fix**: Pre-commit auto-fixes this, just re-commit

## CI Integration

Linters run automatically in CI:

```yaml
- name: Run Linters
  run: |
    pre-commit run --all-files
    mojo format --check src/**/*.mojo
```text

## Workflow Integration

### Before Commit

```bash
# Run linters
./scripts/run_all_linters.sh

# If fixes made, stage changes
git add .

# Commit
git commit -m "message"
```text

### Pre-commit Hook (Automatic)

```bash
# Hooks run automatically on commit
git commit -m "message"
# Pre-commit runs, fixes issues, and aborts if needed
# If fixed, re-commit
git commit -m "message"
```text

### Before PR

```bash
# Verify all linters pass
./scripts/run_all_linters.sh --check

# If issues, fix them
./scripts/run_all_linters.sh --fix

# Commit fixes
git add .
git commit -m "fix: address linting issues"
```text

## Examples

### Run all linters:

```bash
./scripts/run_all_linters.sh
```text

### Check without fixing:

```bash
./scripts/run_all_linters.sh --check
```text

### Run specific linter:

```bash
./scripts/run_linters.sh --mojo
```text

### Fix markdown issues:

```bash
npx markdownlint-cli2 --fix "**/*.md"
```text

## Scripts Available

- `scripts/run_all_linters.sh` - Run all linters
- `scripts/run_linters.sh` - Run specific linters
- `scripts/check_linters.sh` - Check mode (no fixes)

## Error Handling

### Linter Fails in CI

1. **Run locally**: `./scripts/run_all_linters.sh`
1. **Review errors**: Check what failed
1. **Fix issues**: Auto-fix or manual
1. **Re-run**: Verify passing
1. **Commit**: Push fixes

### False Positives

If linter reports false positive:

- Check configuration (`.markdownlint.yaml`, `.pre-commit-config.yaml`)
- Add exception if justified
- Document why exception needed

## Configuration Files

- `.pre-commit-config.yaml` - Pre-commit hooks
- `.markdownlint.yaml` - Markdown linting rules
- `mojo.toml` - Mojo configuration (if exists)

## Best Practices

1. **Run before commit** - Always run linters locally first
1. **Auto-fix when possible** - Use fix mode to save time
1. **Understand errors** - Don't blindly ignore warnings
1. **Keep updated** - Update linter versions regularly
1. **CI enforcement** - Ensure CI runs all linters

See `.pre-commit-config.yaml` for complete linter configuration.
