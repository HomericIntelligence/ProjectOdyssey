# Agent Configuration Optimization Guide

## Overview

This document provides a comprehensive strategy for reducing agent configuration duplication by approximately 40% through shared templates, tool groups, and prompt inheritance patterns. The goal is to improve maintainability, consistency, and discoverability while making it easier to add new agents to the system.

## Problem Statement

### Current State

The ML Odyssey project has 38 agent configurations in `.claude/agents/` with significant duplication across multiple dimensions:

1. **Tool Specifications** - Same tool lists repeated across similar agent types
2. **Prompt Sections** - Identical sections duplicated (Documentation Location, Constraints, etc.)
3. **Delegation Patterns** - Similar escalation rules across agent levels
4. **Validation Rules** - Repeated constraints and checks
5. **Mojo Language Patterns** - Same Mojo guidelines duplicated across implementation agents

### Quantified Duplication

Based on analysis of agent configurations:

- **Documentation Location Section**: Appears in 35+ agents (95+ lines each)
- **Constraints Section**: Appears in 38 agents (40+ lines each)
- **Mojo Language Patterns**: Appears in 15+ agents (200+ lines each)
- **Tool Specifications**: Common combinations repeated 10-20 times
- **Escalation Rules**: Similar patterns across all levels

**Estimated Duplication**: 40% of total agent configuration content

### Impact

- **Maintenance Overhead**: Changes require updates to 10-20+ files
- **Inconsistency Risk**: Manual duplication leads to drift
- **Onboarding Difficulty**: Hard to understand common patterns
- **Change Resistance**: Fear of breaking agents reduces improvements

## Duplication Analysis

### Category 1: Structural Sections (35% of duplication)

These sections appear nearly identically across most agents:

#### Documentation Location Rules

**Duplication**: 35 agents × 95 lines = 3,325 lines

**Pattern**:

```markdown
## Documentation Location

**All outputs must go to `/notes/issues/<issue-number>/README.md`**

### Before Starting Work

1. **Verify GitHub issue number** is provided
2. **Check if `/notes/issues/<issue-number>/` exists**
3. **If directory doesn't exist**: Create it with README.md
4. **If no issue number provided**: STOP and escalate

### Documentation Rules

- ✅ Write ALL findings to `/notes/issues/<issue-number>/README.md`
- ✅ Link to comprehensive docs in `/notes/review/` and `/agents/`
- ✅ Keep issue-specific content focused and concise
- ❌ Do NOT write documentation outside `/notes/issues/<issue-number>/`
- ❌ Do NOT duplicate comprehensive documentation
- ❌ Do NOT start work without a GitHub issue number
```

**Opportunity**: Extract to shared template, reference with single line

#### Minimal Changes Principle

**Duplication**: 38 agents × 40 lines = 1,520 lines

**Pattern**:

```markdown
## Constraints

### Minimal Changes Principle

**Make the SMALLEST change that solves the problem.**

- ✅ Touch ONLY files directly related to issue requirements
- ✅ Make focused changes that directly address the issue
- ✅ Prefer 10-line fixes over 100-line refactors
- ❌ Do NOT refactor unrelated code
- ❌ Do NOT add features beyond issue requirements
```

**Opportunity**: Extract to shared constraint template

#### Pull Request Creation

**Duplication**: 30+ agents × 50 lines = 1,500 lines

**Pattern**:

```markdown
## Pull Request Creation

See [CLAUDE.md](../../CLAUDE.md#git-workflow) for complete instructions.

**Quick Summary**: Commit changes, push branch, create PR with
`gh pr create --issue <issue-number>`, verify issue is linked.

### Verification

After creating PR:

1. **Verify** the PR is linked to the issue
2. **Confirm** link appears in issue's "Development" section
3. **If link missing**: Edit PR description to add "Closes #<issue-number>"
```

**Opportunity**: Single reference to CLAUDE.md section

### Category 2: Language-Specific Guidelines (30% of duplication)

#### Mojo Language Patterns

**Duplication**: 15 agents × 200 lines = 3,000 lines

**Pattern**: Complete Mojo guidelines including fn vs def, struct vs class, memory management, SIMD patterns

**Opportunity**: Reference mojo-language-review-specialist.md instead of duplicating

#### Script Language Selection

**Duplication**: 10 agents × 80 lines = 800 lines

**Pattern**: Same Mojo-first philosophy duplicated across implementation agents

**Opportunity**: Extract to shared implementation guidelines

### Category 3: Tool Specifications (20% of duplication)

Common tool combinations repeated across agent types:

#### Code Review Tools

**Pattern**: `Read,Write,Edit,Grep,Glob,Task,Bash`

**Used by**: 12 review specialist agents

#### Implementation Tools

**Pattern**: `Read,Write,Edit,Grep,Glob,Task`

**Used by**: 8 implementation agents

#### Documentation Tools

**Pattern**: `Read,Write,Edit,Grep,Glob`

**Used by**: 6 documentation agents

**Opportunity**: Define tool groups, reference by name

### Category 4: Workflow Patterns (15% of duplication)

#### Delegation Patterns

**Duplication**: Similar delegation rules across levels

**Pattern**:

```markdown
### Delegates To

- [Agent Name](./agent-name.md) - specific tasks

### Coordinates With

- [Agent Name](./agent-name.md) - coordination

### Skip-Level Guidelines

For standard patterns, see [delegation-rules.md](../delegation-rules.md)
```

**Opportunity**: Template-based delegation with role-specific overrides

## Proposed Solutions

### Solution 1: Shared Templates

Create reusable configuration templates in `.claude/templates/`:

```text
.claude/templates/
├── sections/
│   ├── documentation-location.md
│   ├── constraints-minimal-changes.md
│   ├── pull-request-creation.md
│   ├── escalation-triggers.md
│   └── success-criteria.md
├── guidelines/
│   ├── mojo-language-patterns.md
│   ├── script-language-selection.md
│   └── test-prioritization.md
└── tool-groups/
    ├── code-review-tools.yaml
    ├── implementation-tools.yaml
    ├── documentation-tools.yaml
    └── testing-tools.yaml
```

#### Usage Pattern

**Before** (95 lines duplicated):

```markdown
## Documentation Location

**All outputs must go to `/notes/issues/<issue-number>/README.md`**

### Before Starting Work
...
[95 lines of documentation rules]
```

**After** (1 line reference):

```markdown
## Documentation Location

{{template:sections/documentation-location.md}}
```

### Solution 2: Tool Groups

Define named tool groups in YAML format:

#### `.claude/templates/tool-groups/implementation-tools.yaml`

```yaml
name: implementation-tools
description: Standard tools for implementation agents
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Task
model: sonnet
```

#### `.claude/templates/tool-groups/code-review-tools.yaml`

```yaml
name: code-review-tools
description: Extended tools for code review specialists
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Task
  - Bash
model: sonnet
```

#### Usage in Agent Configs

**Before**:

```yaml
---
name: implementation-specialist
tools: Read,Write,Edit,Grep,Glob,Task
model: sonnet
---
```

**After**:

```yaml
---
name: implementation-specialist
tool-group: implementation-tools
---
```

### Solution 3: Prompt Inheritance

Create base prompts for each agent level with role-specific overrides:

#### Base Prompts

**`.claude/templates/base/level-3-specialist.md`**:

```markdown
# {{agent-name}}

## Role

Level 3 Component Specialist responsible for {{role-description}}.

## Documentation Location

{{template:sections/documentation-location.md}}

## Constraints

{{template:sections/constraints-minimal-changes.md}}

## Pull Request Creation

{{template:sections/pull-request-creation.md}}

## Escalation Triggers

{{template:sections/escalation-triggers.md}}

## Success Criteria

{{template:sections/success-criteria.md}}
```

#### Agent-Specific Overrides

**`.claude/agents/implementation-specialist.md`**:

```yaml
---
name: implementation-specialist
base-template: level-3-specialist
tool-group: implementation-tools
overrides:
  role-description: "breaking down complex components into implementable functions and classes"
  additional-guidelines: mojo-language-patterns
---

## Responsibilities

### Component Breakdown

- Break components into functions and classes
- Design class hierarchies and traits
...

{{template:guidelines/mojo-language-patterns.md}}
```

### Solution 4: Delegation Pattern Templates

Create reusable delegation patterns by role level:

#### `.claude/templates/delegation/level-3-specialist.md`

```markdown
## Delegation

### Delegates To

{{delegates-to}}

### Coordinates With

{{coordinates-with}}

### Skip-Level Guidelines

For standard delegation patterns, escalation rules, and skip-level guidelines,
see [delegation-rules.md](../delegation-rules.md#skip-level-delegation).

**Quick Summary**: Follow hierarchy for all non-trivial work. Skip-level
delegation is acceptable only for truly trivial fixes (< 20 lines, no design decisions).
```

#### Usage

```yaml
overrides:
  delegates-to: |
    - [Implementation Engineer](./implementation-engineer.md) - Function implementations
    - [Senior Implementation Engineer](./senior-implementation-engineer.md) - Complex components
  coordinates-with: |
    - [Test Specialist](./test-specialist.md) - TDD coordination
    - [Documentation Specialist](./documentation-specialist.md) - API documentation
```

## Implementation Phases

### Phase 1: Extract Common Patterns (Week 1-2)

**Goal**: Identify and document all reusable patterns

**Tasks**:

1. Analyze all 38 agent configurations
2. Extract common sections to `.claude/templates/sections/`
3. Define tool groups in `.claude/templates/tool-groups/`
4. Document language-specific guidelines in `.claude/templates/guidelines/`
5. Create base templates for each agent level

**Deliverables**:

- Complete template library in `.claude/templates/`
- Documentation of template usage patterns
- Mapping of agents to templates

**Success Criteria**:

- All common patterns identified and extracted
- Templates cover 90%+ of duplication
- Clear documentation for template usage

### Phase 2: Create Template Processing System (Week 3-4)

**Goal**: Build automation to process templates into agent configs

**Tasks**:

1. Create template processor script (Python or Mojo)
2. Implement YAML tool group resolver
3. Add template validation (check all references exist)
4. Create regeneration script for all agents
5. Add CI check to validate template consistency

**Deliverables**:

- `scripts/process_agent_templates.py` - Template processor
- `scripts/validate_agent_configs.py` - Configuration validator
- `.github/workflows/validate-agents.yml` - CI validation
- Documentation for template syntax

**Success Criteria**:

- Templates process correctly to valid agent configs
- CI catches invalid template references
- Regeneration preserves agent-specific content

### Phase 3: Migrate Existing Agents (Week 5-8)

**Goal**: Convert all 38 agents to use template system

**Approach**: Incremental migration by agent level

#### Week 5: Level 0-1 (Architect & Orchestrators)

- Chief Architect (1 agent)
- Section Orchestrators (6 agents)

#### Week 6: Level 2 (Design & Review)

- Design Agents (3 agents)
- Review Specialists (12 agents)

#### Week 7: Level 3 (Specialists)

- Domain Specialists (8 agents)

#### Week 8: Level 4-5 (Engineers)

- Engineers (6 agents)
- Junior Engineers (2 agents)

**Process for Each Agent**:

1. Extract agent-specific content
2. Identify applicable templates
3. Create new config with template references
4. Regenerate full agent config
5. Validate against original (should be identical)
6. Update agent config
7. Test agent activation and delegation

**Success Criteria**:

- All 38 agents migrated to template system
- No functionality regression
- Configuration size reduced by ~40%
- All tests pass

### Phase 4: Add Validation and Tooling (Week 9-10)

**Goal**: Ensure template consistency and prevent duplication regression

**Tasks**:

1. Add pre-commit hook to validate agent configs
2. Create linter for template syntax
3. Add CI check to detect duplication
4. Create template coverage report
5. Document template contribution guidelines

**Deliverables**:

- Pre-commit hook for agent validation
- Template linter with clear error messages
- CI duplication detection (fail if >10% duplication)
- Template coverage report showing usage
- Contribution guide for new templates

**Success Criteria**:

- Pre-commit catches invalid configs before commit
- CI prevents duplication regression
- Clear feedback on template errors
- Easy to add new templates

## Benefits

### 1. Reduced Maintenance Overhead

**Before**: Update 35 files to change documentation location rules

**After**: Update 1 template file, regenerate all agents

**Time Savings**: 95% reduction in maintenance time for common changes

### 2. Consistent Agent Behavior

**Before**: Manual duplication leads to subtle differences between agents

**After**: Templates ensure identical behavior where intended

**Quality Improvement**: Eliminates consistency bugs from copy-paste errors

### 3. Easier to Add New Agents

**Before**: Copy existing agent, manually update all sections, risk missing changes

**After**: Select appropriate base template, define role-specific overrides, regenerate

**Complexity Reduction**: New agent creation time reduced by 60%

### 4. Better Discoverability

**Before**: Common patterns scattered across 38 files

**After**: All patterns documented in `.claude/templates/` with clear purpose

**Learning Improvement**: New developers can quickly understand agent patterns

### 5. Type Safety and Validation

**Before**: No validation until agent activation

**After**: CI validates all template references and tool groups before merge

**Error Prevention**: Catches configuration errors at development time

## Migration Strategy

### Backwards Compatibility

During migration, support both old and new formats:

1. **Hybrid Processing**: Template processor checks for `{{template:` markers
2. **Fallback**: If no templates, use content as-is
3. **Gradual Migration**: Convert agents incrementally without breaking system
4. **Validation**: Ensure generated configs match original behavior

### Testing Approach

For each migrated agent:

1. **Config Equality**: Generated config should match original (excluding whitespace)
2. **Activation Test**: Agent activates with same triggers
3. **Delegation Test**: Agent delegates to same sub-agents
4. **Tool Test**: Agent has access to same tools
5. **Integration Test**: Agent completes sample tasks successfully

### Rollback Plan

If issues arise during migration:

1. Keep original configs in `.claude/agents.backup/`
2. Template processor can restore original configs
3. CI allows bypassing template validation temporarily
4. Clear documentation of rollback process

## Template Syntax Specification

### Basic Template Inclusion

```markdown
{{template:path/to/template.md}}
```

Includes entire template file at marker location.

### Template with Variables

```markdown
{{template:base/specialist.md | role="Implementation" | level=3}}
```

Includes template with variable substitution.

### Conditional Inclusion

```markdown
{{if has-mojo-guidelines}}
{{template:guidelines/mojo-language-patterns.md}}
{{endif}}
```

Includes template only if condition is true.

### Tool Group Reference

```yaml
---
tool-group: implementation-tools
---
```

Expands to tools list from `.claude/templates/tool-groups/implementation-tools.yaml`.

### Override Blocks

```markdown
## Responsibilities

{{override:responsibilities}}

[Agent-specific content here]

{{end-override}}
```

Marks sections that should not be replaced by templates.

## Validation Rules

### Template Validation

1. All `{{template:*}}` references must point to existing files
2. All variables in templates must be provided
3. Tool groups must exist in tool-groups directory
4. No circular template inclusions
5. Generated configs must pass YAML frontmatter validation

### Agent Config Validation

1. Must have valid YAML frontmatter
2. Tool group or tools list must be specified
3. Required sections must be present (Role, Responsibilities, etc.)
4. All agent references must point to existing agents
5. Delegation patterns must follow hierarchy

### CI Checks

1. **Template Consistency**: All templates used correctly
2. **No Duplication**: Generated configs have <10% duplication
3. **Agent Activation**: All agents can be activated
4. **Delegation Integrity**: All delegation chains are valid
5. **Tool Availability**: All tool references are valid

## Examples

### Example 1: Implementation Specialist Migration

**Before** (535 lines with duplication):

```markdown
---
name: implementation-specialist
tools: Read,Write,Edit,Grep,Glob,Task
model: sonnet
---

# Implementation Specialist

## Role

Level 3 Component Specialist...

## Documentation Location

**All outputs must go to...**
[95 lines]

## Constraints

### Minimal Changes Principle
[40 lines]

## Mojo Language Patterns
[200 lines]

## Pull Request Creation
[50 lines]

...
```

**After** (245 lines, 54% reduction):

```yaml
---
name: implementation-specialist
base-template: level-3-specialist
tool-group: implementation-tools
overrides:
  role-description: "breaking down complex components into implementable functions"
  additional-guidelines:
    - mojo-language-patterns
  delegates-to: |
    - [Implementation Engineer](./implementation-engineer.md)
    - [Senior Implementation Engineer](./senior-implementation-engineer.md)
  coordinates-with: |
    - [Test Specialist](./test-specialist.md)
    - [Documentation Specialist](./documentation-specialist.md)
---

# Implementation Specialist

## Role

{{template:base/level-3-role.md}}

## Responsibilities

### Component Breakdown

- Break components into functions and classes
- Design class hierarchies and traits
- Define function signatures
- Plan implementation approach

### Implementation Planning

- Create detailed implementation plans
- Assign tasks to Implementation Engineers
- Coordinate TDD with Test Specialist
- Review code quality

{{template:sections/documentation-location.md}}
{{template:guidelines/mojo-language-patterns.md}}
{{template:sections/constraints-minimal-changes.md}}
{{template:sections/pull-request-creation.md}}
{{template:sections/escalation-triggers.md}}
```

### Example 2: New Agent Creation

Creating a new "Performance Optimization Specialist" agent:

```yaml
---
name: performance-optimization-specialist
base-template: level-3-specialist
tool-group: implementation-tools
additional-tools:
  - Bash  # For benchmarking
overrides:
  role-description: "optimizing performance-critical code paths"
  additional-guidelines:
    - mojo-language-patterns
    - performance-optimization
  delegates-to: |
    - [Performance Engineer](./performance-engineer.md) - Optimization tasks
  coordinates-with: |
    - [Implementation Specialist](./implementation-specialist.md) - Code review
    - [Test Specialist](./test-specialist.md) - Performance testing
---

# Performance Optimization Specialist

## Role

{{template:base/level-3-role.md}}

## Responsibilities

### Performance Analysis

- Profile code to identify bottlenecks
- Analyze algorithm complexity
- Benchmark current performance

### Optimization Strategy

- Design optimization approach
- Prioritize optimization work
- Validate performance improvements

### SIMD Optimization

{{template:guidelines/simd-optimization.md}}

{{template:sections/documentation-location.md}}
{{template:guidelines/mojo-language-patterns.md}}
{{template:sections/constraints-minimal-changes.md}}
{{template:sections/pull-request-creation.md}}
```

**Result**: New agent created with ~80% less manual work

## Metrics and Success Tracking

### Quantitative Metrics

1. **Lines of Code**:
   - Before: ~20,000 lines across 38 agents
   - Target: ~12,000 lines (40% reduction)
   - Measured: Total lines in `.claude/agents/`

2. **Duplication Percentage**:
   - Before: 40% estimated
   - Target: <10%
   - Measured: Copy-paste detection tools

3. **Maintenance Time**:
   - Before: Average 2 hours to update common pattern
   - Target: <15 minutes
   - Measured: Time tracking for common changes

4. **New Agent Creation**:
   - Before: 4 hours to create new agent
   - Target: <90 minutes
   - Measured: Time tracking for new agents

### Qualitative Metrics

1. **Consistency**: No configuration drift between similar agents
2. **Discoverability**: Clear documentation of all patterns
3. **Confidence**: Developers comfortable updating configurations
4. **Onboarding**: New developers can understand system in <1 day

## Future Enhancements

### Phase 5 Ideas (Beyond Initial Implementation)

1. **Visual Template Editor**: Web UI for creating/editing templates
2. **Template Marketplace**: Share templates across projects
3. **AI-Powered Template Suggestions**: Recommend templates for new agents
4. **Live Template Preview**: See generated config in real-time
5. **Template Versioning**: Track template changes over time
6. **Cross-Project Templates**: Share templates between ML Odyssey projects

## Related Documentation

- [Agent Hierarchy](../../agents/hierarchy.md) - Visual agent hierarchy
- [Delegation Rules](../../agents/delegation-rules.md) - Agent coordination patterns
- [Skills-Agents Integration](./skills-agents-integration-matrix.md) - Skills usage by agents
- [Agent Configuration Schema](../../agents/templates/agent-schema.yaml) - Config validation

## Conclusion

This optimization strategy provides a clear path to reducing agent configuration duplication by 40% while improving maintainability, consistency, and discoverability. The phased approach allows incremental migration with backwards compatibility, and the template system makes it significantly easier to add new agents and update common patterns.

The benefits extend beyond just line count reduction - the real value is in reducing cognitive load, preventing errors, and making the agent system more approachable for new contributors.
