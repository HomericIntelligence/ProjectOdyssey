---
name: gh-implement-issue
description: End-to-end implementation workflow for a GitHub issue including branch creation, implementation, testing, and PR creation. Use when starting work on an issue from scratch.
---

# Implement GitHub Issue Skill

This skill provides a complete workflow for implementing a GitHub issue from start to finish.

## When to Use

- User asks to implement an issue (e.g., "implement issue #42")
- Starting work on a new issue
- Need structured workflow from branch to PR
- Want to follow best practices end-to-end

## Complete Workflow

### Phase 1: Setup (Plan)

```bash
# Run complete workflow
./scripts/implement_issue.sh <issue-number>
```text

This executes:

1. **Fetch issue details** from GitHub
1. **Create branch** with naming convention
1. **Create worktree** (optional)
1. **Generate documentation** in `/notes/issues/<number>/`

### Phase 2: Implementation

1. **Read issue requirements** carefully
1. **Write tests first** (TDD)
1. **Implement functionality**
1. **Run tests** and verify passing
1. **Update documentation** as needed

### Phase 3: Quality Checks

```bash
# Run all quality checks
./scripts/check_quality.sh

# This runs
# - mojo format (if Mojo code)
# - pre-commit hooks
# - tests
# - linters
```text

### Phase 4: Commit and PR

```bash
# Create commit with proper message
./scripts/create_commit.sh <issue-number>

# Push and create PR
./scripts/create_pr.sh <issue-number>
```text

## Step-by-Step Guide

### 1. Start Implementation

```bash
./scripts/implement_issue.sh 42
```text

Output:

```text
✅ Issue #42: Add tensor operations
✅ Branch created: 42-add-tensor-ops
✅ Documentation: /notes/issues/42/README.md
✅ Ready to implement
```text

### 2. Read Requirements

```bash
# View issue details
gh issue view 42

# Read documentation
cat /notes/issues/42/README.md
```text

### 3. Implement with TDD

```bash
# Generate test file
mojo-test-generate tensor_ops

# Write tests
# Implement code to pass tests
# Refactor
```text

### 4. Quality Check

```bash
# Format code
mojo format src/**/*.mojo

# Run tests
mojo test tests/

# Pre-commit
pre-commit run --all-files
```text

### 5. Create PR

```bash
# Commit changes
git add .
git commit -m "feat(tensor): add tensor operations

Implements basic tensor operations including:
- Addition
- Multiplication
- Matrix multiplication

Closes #42"

# Push and create PR
git push -u origin 42-add-tensor-ops
gh pr create --issue 42
```text

## Branch Naming Convention

Format: `<issue-number>-<description>`

Examples:

- `42-add-tensor-ops`
- `73-fix-memory-leak`
- `105-update-docs`

## Commit Message Format

Follow conventional commits:

```text
<type>(<scope>): <description>

<body>

Closes #<issue-number>
```text

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

## Documentation Requirements

Every issue needs `/notes/issues/<number>/README.md`:

```markdown
# Issue #42: Add Tensor Operations

## Objective
Implement basic tensor operations

## Deliverables
- src/tensor_ops.mojo
- tests/test_tensor_ops.mojo

## Success Criteria
- [ ] Tests passing
- [ ] Documentation complete

## Implementation Notes
- Used SIMD for performance
- Added edge case handling
```text

## Error Handling

- **Issue not found**: Verify issue number
- **Branch exists**: Delete old branch or use different name
- **Tests fail**: Fix code before creating PR
- **CI fails**: Address issues before merge

## Verification Checklist

Before creating PR:

- [ ] Issue requirements met
- [ ] Tests written and passing
- [ ] Code formatted (mojo format)
- [ ] Pre-commit hooks pass
- [ ] Documentation updated
- [ ] Commit message follows convention
- [ ] PR linked to issue

## Examples

### Implement feature:

```bash
./scripts/implement_issue.sh 42
# ... make changes
./scripts/create_pr.sh 42
```text

### Implement bugfix:

```bash
./scripts/implement_issue.sh 73
# ... fix bug and add test
./scripts/create_pr.sh 73
```text

## Scripts Available

- `scripts/implement_issue.sh` - Start issue implementation
- `scripts/check_quality.sh` - Run quality checks
- `scripts/create_commit.sh` - Create formatted commit
- `scripts/create_pr.sh` - Push and create PR
- `scripts/verify_ready.sh` - Verify ready for PR

## Templates

- `templates/issue_readme.md` - Issue documentation template
- `templates/commit_message.txt` - Commit message template

See CLAUDE.md for complete development workflow and best practices.
