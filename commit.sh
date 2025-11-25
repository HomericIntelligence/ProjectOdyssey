#!/bin/bash
cd /home/mvillmow/worktrees/1971-export-schedulers
git add shared/training/schedulers/__init__.mojo
git commit -m "fix(training): export scheduler classes from schedulers package

Added exports for StepLR, CosineAnnealingLR, and WarmupLR classes from
the schedulers module. These classes were defined but not exported from
the package __init__, causing import failures in test files.

This fixes Training: Optimizers & Schedulers test group failures.

Closes #1971

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
