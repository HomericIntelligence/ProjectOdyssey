---
name: plan-create-component
description: Create new component plan following Template 1 format and integrate into hierarchy. Use when adding new components to the plan structure.
---

# Create Component Plan Skill

Create new component plans in hierarchy.

## When to Use

- Adding new component
- Extending existing section
- New subsection needed
- Modifying plan structure

## Workflow

### 1. Create Plan

```bash
# Use plan generator
./scripts/create_component_plan.sh "Component Name" "parent/path"

# Example
./scripts/create_component_plan.sh "Tensor Operations" "notes/plan/02-shared-library/01-core"
```text

### 2. Edit Plan

```bash
# Edit generated plan
vim notes/plan/02-shared-library/01-core/02-tensor-ops/plan.md

# Fill in
# - Overview
# - Inputs/Outputs
# - Steps
# - Success Criteria
```text

### 3. Update Parent

```bash
# Update parent's Child Plans section
vim notes/plan/02-shared-library/01-core/plan.md

# Add
# - [02-tensor-ops/plan.md](02-tensor-ops/plan.md)
```text

### 4. Regenerate Issues

```bash
# Regenerate GitHub issues
python3 scripts/regenerate_github_issues.py --section 02-shared-library
```text

## Template 1 Format

All components must follow 9-section format:

1. Title
1. Overview
1. Parent Plan
1. Child Plans
1. Inputs
1. Outputs
1. Steps
1. Success Criteria
1. Notes

See `phase-plan-generate` for complete template.

## Validation

```bash
# Validate new plan
./scripts/validate_plan.sh notes/plan/.../plan.md

# Check hierarchy
./scripts/validate_plan_hierarchy.sh
```text

See `plan-validate-structure` for validation details.
