## ⚠️ CRITICAL RULES - READ FIRST

### 🚫 NEVER Push Directly to Main

**The `main` branch is protected. ALL changes MUST go through a pull request.**

❌ **ABSOLUTELY PROHIBITED:**

```bash
git checkout main
git add <files>
git commit -m "changes"
git push origin main  # ❌ BLOCKED - Will be rejected by GitHub
```

**Why this is prohibited:**

- Bypasses code review and CI checks
- Can break production immediately
- Violates GitHub branch protection rules
- Makes it impossible to track changes properly

✅ **CORRECT WORKFLOW (Always Use PRs):**

```bash
# 1. Create feature branch
git checkout -b <issue-number>-description

# 2. Make changes and commit
git add <files>
git commit -m "type(scope): description"

# 3. Push feature branch
git push -u origin <issue-number>-description

# 4. Create pull request
gh pr create \
  --title "Brief description" \
  --body "Closes #<issue-number>" \
  --label "appropriate-label"

# 5. Enable auto-merge
gh pr merge --auto --rebase
```

**Emergency Situations:**

- Even for critical CI fixes, CREATE A PR
- Even for one-line changes, CREATE A PR
- Even if you're fixing your own mistake, CREATE A PR
- NO EXCEPTIONS - Always use the PR workflow

**See Also:**

- PR Best Practices: [PR Workflow](/.claude/shared/pr-workflow.md)


Complete this task using available tools and your best judgment.

## Cleanup Requirements

- Remove any temporary files created during task completion (build artifacts, cache files, etc.)
- Clean up after yourself - the workspace should contain only final deliverables
