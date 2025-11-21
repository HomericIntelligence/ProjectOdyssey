# Issue #1585: Create Agent System Usage Examples

## Overview

Create comprehensive examples documentation showing how to use the agent system for common development tasks.

## Problem

New contributors lack clear examples of:

- How to invoke agents for different tasks
- What agents to use when
- How agents coordinate and delegate
- Best practices for agent usage

## Proposed Content

Create `agents/docs/examples.md` with:

### Example Categories

1. **Planning a New Feature**
   - Using chief-architect
   - Breaking down work
   - Creating plan files

1. **Implementing a Component**
   - Using orchestrators
   - Delegating to specialists
   - Following 5-phase workflow

1. **Code Review**
   - Using code-review-orchestrator
   - Routing to specialists
   - Addressing feedback

1. **Testing**
   - Using test-specialist
   - TDD workflow
   - Running tests

1. **Documentation**
   - Using documentation-specialist
   - Writing ADRs
   - Updating guides

### Each Example Shows

- Initial prompt/request
- Agent selection rationale
- Expected output
- Follow-up steps
- Common pitfalls

## Benefits

- Faster onboarding
- Better agent usage
- Fewer mistakes
- Clearer expectations

## Status

**DEFERRED** - Marked for follow-up PR

Requires real-world examples from actual development work.

## Related Issues

Part of Wave 5 enhancement from continuous improvement session.
