# [Documentation] Create Plan File Generation Guide

## Labels

`documentation`, `planning`

## Summary

Create comprehensive documentation that explains how to generate plan files for the GitHub issue automation system. Currently, the plan file format is documented in CLAUDE.md but is not easily discoverable or tutorial-style, creating a barrier to entry for contributors.

## Problem Statement

A reviewer noted: *"it's not super clear how to generate a plan file. Some documentation on what is required in order for create_issues.py to parse it would be super helpful."*

**Current state:**

- Plan file format exists (Template 1: 9 sections)
- Format is documented in CLAUDE.md but scattered
- No tutorial-style guide
- No template file to copy
- No annotated examples

**Impact:** Contributors cannot easily create new plan files or understand what `create_issues.py` requires.

## Objective

Make plan file creation accessible to anyone unfamiliar with the project by providing:

1. Step-by-step tutorial
2. Copyable template
3. Annotated examples (simple and complex)
4. Clear requirements documentation
5. Troubleshooting guide

## Deliverables

1. **Comprehensive guide** at `notes/review/plan-file-guide.md` covering:
   - What plan files are and why they exist
   - The 9-section Template 1 format
   - How `create_issues.py` parses plan files
   - Step-by-step instructions for creating a new plan
   - Common pitfalls and how to avoid them

2. **Template file** at `.templates/plan-template.md`:
   - All 9 sections with placeholder content
   - Inline comments explaining each section
   - Examples of valid values

3. **Example plan files** at `examples/plan-files/`:
   - `simple-component.md` - Minimal valid plan (leaf node)
   - `complex-component.md` - Plan with child plans
   - `section-plan.md` - Top-level section plan

4. **README update**:
   - Add "Creating Plan Files" section linking to the guide
   - Add quick-start example

5. **scripts/README.md update**:
   - Document plan file requirements for `create_issues.py`
   - Link to comprehensive guide

## Success Criteria

- [ ] Someone unfamiliar with the project can create a valid plan file using only the guide
- [ ] Guide covers all 9 Template 1 sections with explanations
- [ ] Template can be copied and filled in without referencing other docs
- [ ] Examples demonstrate simple and complex cases
- [ ] `create_issues.py` requirements are clearly documented
- [ ] Common errors have troubleshooting guidance

## Technical Requirements

**Plan file structure (Template 1):**

1. Component Name (heading)
2. Overview (2-3 sentences)
3. Parent Plan (relative link or "None")
4. Child Plans (list with relative links or "None")
5. Inputs (prerequisites)
6. Outputs (deliverables)
7. Steps (numbered list)
8. Success Criteria (checklist)
9. Notes (additional context)

**What create_issues.py expects:**

- Valid markdown structure
- All 9 sections present
- Relative paths for links (not absolute)
- Proper heading hierarchy
- Success criteria as checklist items
- Location in `notes/plan/` hierarchy

## Implementation Notes

**Style guidance:**

- Follow blog post style: conversational but precise
- Include "Why" explanations, not just "How"
- Use real examples from the project where possible
- Anticipate user questions and address proactively

**Structure:**

```markdown
# Plan File Generation Guide

## What Are Plan Files?
[Brief explanation of purpose and role in the system]

## The Template 1 Format
[Detailed explanation of 9 sections]

## Quick Start
[Minimal example to get started immediately]

## Step-by-Step Tutorial
[Comprehensive walkthrough]

## Requirements for create_issues.py
[What the parser expects]

## Examples
[Links to example files with annotations]

## Troubleshooting
[Common errors and solutions]

## FAQ
[Anticipated questions]
```

## References

- CLAUDE.md (existing Template 1 documentation)
- scripts/README.md (existing create_issues.py documentation)
- notes/blog/11-7-2025.md (style reference)

## Estimated Effort

**Medium** - Primarily documentation and examples

- Guide writing: 2-3 hours
- Template creation: 30 minutes
- Example files: 1-2 hours
- README updates: 30 minutes
- Review and refinement: 1 hour

**Total: ~5-7 hours**

## Acceptance Testing

1. Hand guide to someone unfamiliar with the project
2. Ask them to create a valid plan file without additional help
3. Run their plan file through `create_issues.py --dry-run`
4. Verify successful parsing and issue generation

## Dependencies

None - Pure documentation task

## Follow-up Tasks

- Consider adding validation script to check plan file format
- Consider adding `scripts/generate_plan_template.py` to auto-create plan files
- Update agent prompts to reference the guide

---

**Priority**: HIGH - Directly impacts usability and contributor onboarding
