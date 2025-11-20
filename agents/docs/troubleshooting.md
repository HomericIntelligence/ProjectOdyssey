# Troubleshooting Guide - Agent System

<!-- markdownlint-disable MD051 -->

## Table of Contents

- [Common Issues and Solutions](#common-issues-and-solutions)
- [Error Message Guide](#error-message-guide)
- [Debugging Agent Behavior](#debugging-agent-behavior)
- [Performance Tips](#performance-tips)
- [FAQ](#faq)

## Common Issues and Solutions

### Issue 1: Wrong Agent Invoked

### Symptoms

- Claude invokes an agent that doesn't match your need
- The agent seems confused about what to do
- Response is off-topic or at wrong level of detail

### Common Causes

- Request was ambiguous
- Multiple agents match the description
- Agent description overlap

### Solutions

#### Solution A: Explicitly name the agent

```text
"Actually, use the [specific agent name] for this task"
```text

Example:

```text
"Actually, use the senior implementation engineer - this requires advanced Mojo expertise"
```text

#### Solution B: Be more specific in your request

Instead of: "Fix the code"
Use: "Profile and optimize the convolution performance" (invokes Performance Specialist)

Instead of: "Update the docs"
Use: "Write comprehensive API documentation with examples" (invokes Documentation Writer)

#### Solution C: Start at higher level and let it delegate

```text
"Use the [section] orchestrator to coordinate this work"
```text

Example:

```text
"Use the shared library orchestrator to coordinate adding batch normalization"
```text

### Prevention

- Include keywords that match agent descriptions
- Specify scope (repository-wide, module, function)
- Mention required expertise (SIMD, testing, documentation)

---

### Issue 2: Agent Seems Stuck or Blocked

### Symptoms

- Agent reports it can't proceed
- Agent asks for information repeatedly
- Agent reports missing prerequisites
- Work has stalled

### Common Causes

- Missing specifications or requirements
- Dependencies not ready
- Insufficient authority for decision
- Resource conflicts

### Solutions

#### Solution A: Escalate to higher level

```text
"Escalate this to the [higher level agent]"
```text

Example:

```text
Junior Engineer stuck → "Escalate to Implementation Engineer"
Implementation Engineer stuck → "Escalate to Implementation Specialist"
Specialist stuck → "Escalate to Architecture Design Agent"
```text

#### Solution B: Provide missing information

If agent asks for specifications:

```text
"Here are the requirements: [detailed specifications]"
```text

If agent needs decisions:

```text
"Use approach X because [rationale]"
```text

#### Solution C: Check prerequisites

```text
"What prerequisites are missing? Let's address them first."
```text

Then delegate to appropriate agent to handle prerequisites.

#### Solution D: Resolve resource conflicts

If multiple agents need same resource:

```text
"Coordinate with [other agent] on [resource]. Use separate worktrees."
```text

### Prevention

- Complete Plan phase before Test/Implementation phases
- Use git worktrees for parallel work
- Ensure specifications are complete before delegating
- Check dependencies before starting work

---

### Issue 3: Don't Know Which Agent to Use

### Symptoms

- Task is complex or multi-faceted
- Unclear who has the right expertise
- Multiple agents seem relevant
- New to the agent system

### Common Causes

- Task complexity
- Unfamiliarity with hierarchy
- Task crosses multiple domains

### Solutions

#### Solution A: Start with an orchestrator

For repository-wide tasks:

```text
"Use the chief architect to evaluate this"
```text

For section-specific tasks:

```text
"Use the [section] orchestrator to coordinate this"
```text

Examples:

```text
"Use the shared library orchestrator to add this feature"
"Use the papers orchestrator to implement this research paper"
"Use the CI/CD orchestrator to set up testing"
```text

#### Solution B: Describe the task naturally and let auto-selection work

```text
Just say what you want:
"I need to optimize the matrix multiplication performance"
→ Auto-invokes Performance Specialist

"Write comprehensive tests for the training loop"
→ Auto-invokes Test Specialist
```text

#### Solution C: Check the agent catalog

```bash
# View catalog
cat agents/docs/agent-catalog.md

# Or check quick reference
cat agents/hierarchy.md
```text

#### Solution D: Use decision tree

```text
Is this about:
- Which paper to implement? → Chief Architect
- Repository section? → Section Orchestrator
- Module design? → Module Design Agent
- Component planning? → Component Specialist
- Writing code? → Implementation Engineer
- Writing tests? → Test Engineer
- Writing docs? → Documentation Writer
- Performance? → Performance Specialist/Engineer
- Security? → Security Design Agent/Specialist
```text

### Prevention

- Familiarize yourself with [agent-catalog.md](agent-catalog.md)
- Review [hierarchy.md](../hierarchy.md) visual diagram
- Start with orchestrators when uncertain

---

### Issue 4: Agents Not Coordinating

### Symptoms

- Duplicate work
- Conflicting implementations
- Integration failures
- Merge conflicts
- Mismatched expectations

### Common Causes

- Lack of communication
- No shared specifications
- Working in silos
- No coordination protocol

### Solutions

#### Solution A: Use orchestrator for coordination

```text
"Use the [appropriate orchestrator/specialist] to coordinate between these agents"
```text

Example:

```text
"Use the implementation specialist to coordinate between test and implementation engineers"
```text

#### Solution B: Establish shared specifications

```text
"Create detailed specifications that both [agent A] and [agent B] will follow"
```text

Example:

```text
"Architecture design agent: Create interface specification for both test and implementation engineers"
```text

#### Solution C: Use git worktrees for isolation

```text
"Assign separate worktrees:
- Test Engineer → worktrees/issue-63-test-[component]/
- Implementation Engineer → worktrees/issue-64-impl-[component]/
- Documentation Writer → worktrees/issue-65-docs-[component]/"
```text

#### Solution D: Implement handoff protocol

```text
"[Agent A]: When you complete [task], create handoff document for [Agent B]
Include: what was done, artifacts created, next steps, important notes"
```text

### Prevention

- Always complete Plan phase before parallel execution
- Use specifications as single source of truth
- Implement clear handoff protocols
- Use git worktrees for parallel work
- Regular status updates to orchestrators

---

### Issue 5: Mojo-Specific Problems

### Symptoms

- Code doesn't compile
- SIMD operations not working
- Memory management issues
- Type errors
- Lifetime/ownership errors

### Common Causes

- Incorrect Mojo syntax
- Misunderstanding of Mojo features
- Wrong agent for Mojo complexity level

### Solutions

#### Solution A: Use appropriate expertise level

For advanced Mojo (SIMD, lifetimes, traits):

```text
"Use the senior implementation engineer - this requires advanced Mojo knowledge"
```text

For standard Mojo:

```text
"Use the implementation engineer"
```text

For simple Mojo:

```text
"Use the junior implementation engineer"
```text

#### Solution B: Ask for Mojo-specific review

```text
"Review this Mojo code for:
- Ownership and lifetime correctness
- SIMD vectorization opportunities
- Memory safety issues
- Type system usage"
```text

#### Solution C: Escalate to architecture level

For design issues:

```text
"Escalate to architecture design agent - we need to redesign this Mojo API"
```text

#### Solution D: Check Mojo documentation

```bash
# Reference Mojo docs
https://docs.modular.com/mojo/manual/

# Check Mojo examples in codebase
cat papers/lenet5/src/*.mojo
```text

### Prevention

- Use senior engineers for complex Mojo
- Design Mojo APIs at architecture level
- Review Mojo code with experienced agents
- Follow Mojo best practices from design phase

---

### Issue 6: Tests Failing

### Symptoms

- Unit tests failing
- Integration tests failing
- Tests pass locally but fail in CI
- Flaky tests

### Common Causes

- Implementation doesn't match specification
- Test assumptions incorrect
- Environment differences
- Race conditions
- Floating-point precision issues

### Solutions

#### Solution A: TDD coordination

```text
"Test Engineer and Implementation Engineer: Coordinate on this failure
- Test Engineer: Verify test is correct
- Implementation Engineer: Verify implementation matches spec
- Both: Discuss and resolve discrepancy"
```text

#### Solution B: Debug systematically

```text
"Test Engineer: Debug this test failure:
1. Isolate the failing assertion
2. Check test assumptions
3. Verify expected vs actual values
4. Report findings to Implementation Engineer"
```text

#### Solution C: Check for environment issues

```text
"Verify tests pass in:
- Local development environment
- CI environment
- Clean environment

Identify environment-specific issues"
```text

#### Solution D: Review specifications

```text
"Escalate to Component Specialist:
The specification may be ambiguous or incorrect
Test and implementation engineers have different interpretations"
```text

### Prevention

- Use TDD: tests written before/during implementation
- Clear specifications from planning phase
- Regular test runs, not just at end
- Coordinate test and implementation engineers
- Handle floating-point precision appropriately

### Issue 7: Documentation Incomplete or Unclear

### Symptoms

- Missing docstrings
- Unclear API documentation
- No usage examples
- Outdated documentation

### Common Causes

- Documentation not prioritized
- Documentation created after code (not during)
- No documentation review process
- Specifications not documented

### Solutions

#### Solution A: Assign documentation specialist

```text
"Documentation Specialist: Create comprehensive documentation plan for [component]
Include: API docs, examples, tutorials, README updates"
```text

#### Solution B: Parallel documentation with implementation

```text
"During implementation phase:
- Implementation Engineer: Write code with docstrings
- Documentation Writer: Create API docs and examples in parallel
- Both work in separate worktrees, merge in packaging phase"
```text

#### Solution C: Documentation review

```text
"Documentation Specialist: Review all documentation for:
- Completeness
- Clarity
- Correct examples
- Up-to-date with code"
```text

#### Solution D: Generate from code

```text
"Junior Documentation Engineer:
- Extract docstrings into API documentation
- Generate reference documentation
- Format consistently"
```text

### Prevention

- Include documentation in Plan phase
- Write docstrings during implementation
- Assign Documentation Writer in parallel with Implementation
- Review documentation in Cleanup phase

---

### Issue 8: Performance Not Meeting Requirements

### Symptoms

- Code is slower than expected
- Performance regressions detected
- Not utilizing SIMD effectively
- Memory bandwidth issues

### Common Causes

- No performance requirements in plan
- Not using SIMD optimization
- Poor memory access patterns
- Not profiling before optimizing

### Solutions

#### Solution A: Performance planning

```text
"Performance Specialist: Create performance optimization plan:
1. Define performance requirements
2. Design benchmarks
3. Identify optimization opportunities
4. Plan SIMD vectorization"
```text

#### Solution B: Profile first

```text
"Performance Engineer: Profile current implementation:
1. Identify bottlenecks
2. Measure CPU usage, memory bandwidth
3. Check SIMD utilization
4. Report findings"
```text

#### Solution C: Optimize with senior engineer

```text
"Senior Implementation Engineer: Implement SIMD optimizations:
- Vectorize hot loops
- Improve memory access patterns
- Use compile-time computation (@parameter)
- Leverage Mojo's zero-cost abstractions"
```text

#### Solution D: Validate improvements

```text
"Performance Engineer: Benchmark optimizations:
1. Compare before/after performance
2. Verify correctness maintained
3. Check for regressions in other areas
4. Document improvements"
```text

### Prevention

- Define performance requirements in Plan phase
- Include Performance Specialist in design
- Use SIMD from the start for hot paths
- Profile early and often
- Benchmark all optimizations

---

### Issue 9: Merge Conflicts

### Symptoms

- Git merge conflicts
- Conflicting changes from parallel worktrees
- Integration failures during packaging phase

### Common Causes

- Insufficient coordination
- No shared specifications
- Modifying same code areas
- Not using worktrees properly

### Solutions

#### Solution A: Resolve at packaging phase

```text
"Implementation Specialist (in packaging worktree):
1. Merge test branch
2. Merge implementation branch
3. Merge documentation branch
4. Resolve conflicts carefully
5. Run full test suite
6. Verify integration"
```text

#### Solution B: Coordinate on interfaces

```text
"Before parallel execution:
Architecture Design Agent: Define clear interfaces
All engineers: Follow interface specifications exactly
This prevents conflicting changes"
```text

#### Solution C: Use cherry-pick for dependencies

```text
"If Implementation depends on Test fixtures:
cd worktrees/issue-64-impl/
git cherry-pick <commit-from-test-branch>"
```text

#### Solution D: Escalate significant conflicts

```text
"If conflicts are fundamental (not just textual):
Escalate to Architecture Design Agent
May need to redesign interfaces or split work differently"
```text

### Prevention

- Complete architecture design before parallel work
- Clear interface definitions
- Proper worktree separation
- Coordinate on shared code areas
- Regular integration testing

---

### Issue 10: Agent Exceeding Scope

### Symptoms

- Junior Engineer making architectural decisions
- Implementation Engineer selecting technology stack
- Engineer refactoring entire modules
- Agent doing work outside its level

### Common Causes

- Unclear scope boundaries
- Agent not understanding hierarchy
- Missing escalation when scope exceeded

### Solutions

#### Solution A: Remind of scope

```text
"[Agent name]: This decision is outside your scope.
Your scope: [specific scope]
This decision requires: [higher level agent]
Please escalate."
```text

Example:

```text
"Implementation Engineer: Technology stack selection is outside your scope.
Your scope: Implement functions following specifications
This decision requires: Chief Architect
Please escalate if you need technology decisions."
```text

#### Solution B: Review agent hierarchy

```text
"Refer to agents/hierarchy.md for scope boundaries:
Level 0: Repository-wide
Level 1: Section-wide
Level 2: Module-wide
Level 3: Component-wide
Level 4: Function/class
Level 5: Lines/boilerplate"
```text

#### Solution C: Reset and delegate properly

```text
"Let's restart this task with proper delegation:
[Appropriate higher-level agent]: Create specifications
[Original agent]: Implement following those specifications"
```text

### Prevention

- Clear specifications from higher levels
- Agents understand their scope boundaries
- Escalation culture for out-of-scope decisions
- Review agents/delegation-rules.md

---

## Error Message Guide

### "Cannot proceed without specification"

**Meaning**: Agent needs more detailed requirements

### Action

```text
Option 1: Provide specifications
"Here are the detailed requirements: [specs]"

Option 2: Create specifications
"[Higher level agent]: Create specifications for [task]"
```text

### "This decision exceeds my authority"

**Meaning**: Decision requires higher-level agent

### Action

```text
"Escalate to [appropriate higher-level agent]"
```text

### Decision authority reference

- Level 0: System-wide architecture
- Level 1: Section organization
- Level 2: Module design
- Level 3: Component approach
- Level 4: Function implementation
- Level 5: Code formatting

### "Blocker: [description]"

**Meaning**: Agent is blocked and cannot proceed

### Action

```text
1. Review blocker description
2. Determine if agent can resolve or needs escalation
3. If escalation needed:
   "Escalate this blocker to [superior agent]"
4. If resolvable:
   "Here's how to resolve: [solution]"
```text

### "Conflict with [other agent]"

**Meaning**: Agents have disagreement or conflict

### Action

```text
"Escalate to common superior:
Both [Agent A] and [Agent B] report to [Superior]
[Superior]: Review conflict and make decision"
```text

### "Integration test failing"

**Meaning**: Components don't integrate correctly

### Action

```text
1. Check if interfaces match specification:
   "Architecture Design Agent: Review interface specification"

2. Debug integration:
   "Integration Design Agent: Debug integration between [A] and [B]"

3. Fix implementation:
   "Implementation Engineers: Update implementations to match spec"
```text

### "Performance requirement not met"

**Meaning**: Code doesn't meet performance targets

### Action

```text
"Performance Specialist: Create optimization plan
Performance Engineer: Profile and identify bottlenecks
Senior Implementation Engineer: Implement optimizations
Performance Engineer: Validate improvements"
```text

### "Memory safety issue detected"

**Meaning**: Potential buffer overflow, memory leak, or use-after-free

### Action

```text
"Security Design Agent: Review for memory safety
Senior Implementation Engineer: Fix memory safety issue
Use Mojo ownership system correctly:
- Proper lifetimes
- Correct use of owned vs borrowed
- RAII patterns for cleanup"
```text

### "Test coverage insufficient"

**Meaning**: Tests don't cover enough code paths

### Action

```text
"Test Specialist: Identify coverage gaps
Test Engineer: Add tests for:
- Uncovered code paths
- Edge cases
- Error conditions
Target: [X]% coverage"
```text

---

## Debugging Agent Behavior

### How to Debug Agent Invocation

### Check which agent was invoked

```text
Agent should introduce itself:
"I'm the [Agent Name], responsible for [role]"
```text

### If wrong agent invoked

```text
"Actually, I need [correct agent name] for this"
```text

### Understand why agent was selected

- Agents are selected based on description field in config
- Check: `.claude/agents/[agent-name].md` description field
- Improve future requests with keywords from descriptions

### How to Debug Delegation Issues

### Check delegation path

```text
"Show me the delegation path for this task:
Who delegates to whom?"
```text

Expected pattern:

```text
Level 0/1 Orchestrator
  → Level 2 Design Agent
    → Level 3 Specialist
      → Level 4 Engineer
        → Level 5 Junior (if needed)
```text

### Verify delegation is appropriate

- Each level should add detail, not skip steps
- Specialists should coordinate, not micromanage
- Engineers should execute, not decide architecture

### Fix broken delegation

```text
"Let's restart with proper delegation:
[Level N agent]: Create specifications
[Level N+1 agent]: Implement following specs"
```text

### How to Debug Coordination Issues

### Check for coordination

```text
"Are [Agent A] and [Agent B] coordinating on [shared resource]?"
```text

### Establish coordination protocol

```text
"[Agent A] and [Agent B]: Coordinate on [resource]
- Agree on interface before implementing
- Share status updates
- Use separate worktrees
- Merge carefully in packaging phase"
```text

### Review coordination patterns

```bash
cat notes/review/orchestration-patterns.md
cat agents/delegation-rules.md
```text

### How to Debug Worktree Issues

### Check worktree setup

```bash
git worktree list
```text

Expected:

```text
worktrees/issue-62-plan-[component]/
worktrees/issue-63-test-[component]/
worktrees/issue-64-impl-[component]/
worktrees/issue-65-pkg-[component]/
worktrees/issue-66-cleanup-[component]/
```text

### Verify agent assignments

```text
Each worktree should have clear ownership:
- issue-63-test → Test Engineer
- issue-64-impl → Implementation Engineer
- issue-65-pkg → Documentation Writer
- etc.
```text

### Fix worktree conflicts

```text
Option 1: Cherry-pick commits
"cd worktrees/issue-64-impl/
 git cherry-pick <commit-hash>"

Option 2: Coordinate through specs
"Use specifications as single source of truth
 Implement independently in each worktree"
```text

---

## Performance Tips

### Optimize Agent Selection

### Be specific in requests

```text
❌ "Make it faster"
✓ "Profile and optimize the convolution layer using SIMD vectorization"
```text

### Include expertise keywords

```text
Keywords for Performance: "optimize", "SIMD", "profile", "benchmark"
Keywords for Testing: "test", "TDD", "coverage", "edge cases"
Keywords for Architecture: "design", "architecture", "interface", "structure"
```text

### Optimize Delegation

### Start at right level

```text
❌ Chief Architect → Junior Engineer (skipping levels)
✓ Chief Architect → Orchestrator → Design Agent → Specialist → Engineer
```text

### Use parallel delegation

```text
After Plan phase:
Specialist delegates to:
├─> Test Engineer (parallel)
├─> Implementation Engineer (parallel)
└─> Documentation Writer (parallel)
```text

### Optimize Worktree Usage

### One worktree per phase

```text
✓ Separate worktrees for Test, Impl, Docs
✓ Clean separation, no conflicts
✓ Parallel execution
```text

### Minimal cross-worktree dependencies

```text
✓ Use specifications, not shared code
✓ Cherry-pick only when absolutely necessary
✓ Integrate in packaging phase
```text

### Optimize Coordination

### Clear specifications reduce coordination overhead

```text
Time spent on specs in Plan phase
= Time saved in coordination during Implementation
```text

### Handoff protocols

```text
Standard handoff format reduces questions and back-and-forth
See agents/delegation-rules.md for templates
```text

### Optimize SIMD Usage (Mojo-Specific)

### Plan SIMD from architecture phase

```text
Architecture Design Agent:
"Design data layout for SIMD vectorization"

Performance Specialist:
"Specify SIMD vectorization for hot loops"

Senior Implementation Engineer:
"Implement with SIMD from the start"
```text

### Don't retrofit SIMD

```text
❌ Write scalar code, then optimize later
✓ Design for SIMD, implement SIMD from start
```text

---

## FAQ

### General Questions

### Q: How do I know which agent to use?

A: Three approaches:

1. Describe task naturally, let auto-selection work
1. Use [agent-catalog.md](agent-catalog.md) to find the right agent
1. Start with an orchestrator and let them delegate

### Q: Can I switch agents mid-task?

A: Yes! Just explicitly invoke a different agent:

```text
"Actually, use [different agent] for this"
```text

### Q: What if an agent makes a mistake?

A: Provide feedback and ask for correction:

```text
"This implementation has a bug: [description]
Please fix it."
```text

Or escalate:

```text
"Escalate to [higher level] for review"
```text

### Q: How do I see all available agents?

A:

```bash
ls .claude/agents/         # See all agent configs
cat agents/docs/agent-catalog.md  # Read agent catalog
cat agents/hierarchy.md    # See visual hierarchy
```text

### Hierarchy Questions

### Q: Why use a hierarchy instead of one agent?

A: Benefits:

- Specialization: Experts handle their domain
- Scope management: Right level of detail for task
- Parallel execution: Multiple agents work simultaneously
- Scalability: Clear organization as project grows

### Q: Can I skip levels in the hierarchy?

A: No, don't skip levels:

```text
❌ Chief Architect → Junior Engineer
✓ Chief Architect → Orchestrator → Design Agent → Specialist → Engineer → Junior
```text

Skipping levels causes:

- Missing specifications
- Unclear scope
- Poor quality work

### Q: What if I only have a simple task?

A: For truly simple tasks, use lower-level agents directly:

```text
"Junior Implementation Engineer: Create getter/setter methods"
```text

But most tasks benefit from at least minimal planning.

### Delegation Questions

### Q: How do I know when to escalate?

A: Escalate when:

- Decision exceeds your authority
- Blocked by missing prerequisites
- Conflict with peer agent
- Quality standards at risk
- Scope is unclear

### Q: How do agents coordinate?

A: Three ways:

1. Vertical: Superior delegates to subordinates, subordinates report up
1. Horizontal: Peers coordinate directly (Test ↔ Implementation)
1. Through specs: Shared specifications from planning phase

### Q: What's the handoff protocol?

A: See [delegation-rules.md](../delegation-rules.md) for template:

```markdown
## Task Handoff

From: [Agent Name]
To: [Next Agent Name]
Work Completed: [...]
Artifacts Produced: [...]
Next Steps: [...]
Notes: [...]
```text

### Mojo-Specific Questions

### Q: Which agents know Mojo?

A:

- **Advanced Mojo**: Senior Implementation Engineer, Performance Specialist
- **Standard Mojo**: Implementation Engineer, Architecture Design Agent
- **Simple Mojo**: Junior Implementation Engineer

### Q: When should I use SIMD?

A: SIMD for:

- Loops over arrays (vectorize[])
- Element-wise operations
- Performance-critical paths
- Tensor operations

Not SIMD for:

- Control flow heavy code
- I/O operations
- Simple utilities

### Q: How do I handle Mojo-Python interop?

A:

```text
1. Chief Architect: Decide which parts Mojo vs Python
2. Integration Design Agent: Design FFI interfaces
3. Implementation Engineers: Implement both sides
4. Test Engineer: Create integration tests
```text

### Workflow Questions

### Q: What's the 5-phase workflow?

A:

1. **Plan**: Levels 0-2 create specifications (sequential)
1. **Test**: Write tests (parallel)
1. **Implementation**: Write code (parallel)
1. **Packaging**: Integrate and document (parallel)
1. **Cleanup**: Review and refactor (sequential)

### Q: Can Test and Implementation run in parallel?

A: Yes! That's the design:

```text
After Plan completes:
├─> Test Engineer (in worktrees/issue-63-test/)
├─> Implementation Engineer (in worktrees/issue-64-impl/)
└─> Documentation Writer (in worktrees/issue-65-docs/)

All work in parallel, merge in Packaging phase
```text

### Q: What are git worktrees?

A: Worktrees allow multiple branches checked out simultaneously:

```bash
git worktree add worktrees/issue-63-test 63-test-component
git worktree add worktrees/issue-64-impl 64-impl-component
```text

Each agent works in their own worktree, no conflicts.

### Troubleshooting Questions

### Q: Tests failing, what do I do?

A:

```text
1. Test Engineer: Verify test is correct
2. Implementation Engineer: Verify implementation matches spec
3. Both coordinate to identify discrepancy
4. If spec is wrong: Escalate to Component Specialist
```text

### Q: Performance not meeting requirements?

A:

```text
1. Performance Specialist: Create optimization plan
2. Performance Engineer: Profile code
3. Senior Implementation Engineer: Implement optimizations
4. Performance Engineer: Validate improvements
```text

### Q: Documentation is outdated?

A:

```text
1. Documentation Specialist: Create update plan
2. Documentation Writer: Update docs
3. Implementation Engineer: Review for accuracy
```text

### Configuration Questions

### Q: How do I create a new agent?

A:

1. Choose appropriate level (0-5)
1. Use template from `agents/templates/`
1. Customize for your need
1. Place in `.claude/agents/`
1. Test with explicit invocation

### Q: Can I modify existing agents?

A: Yes, edit `.claude/agents/[agent-name].md`

Changes take effect immediately (Claude Code reloads configs)

### Q: Where can I find agent templates?

A:

```bash
ls agents/templates/
```text

Templates for each level (0-5) available.

---

## Getting More Help

### Documentation Resources

- **Quick Start**: [quick-start.md](quick-start.md)
- **Complete Onboarding**: [onboarding.md](onboarding.md)
- **Agent Catalog**: [agent-catalog.md](agent-catalog.md)
- **Visual Hierarchy**: [../hierarchy.md](../hierarchy.md)
- **Delegation Rules**: [../delegation-rules.md](../delegation-rules.md)
- **Orchestration Patterns**: [/notes/review/orchestration-patterns.md](../../notes/review/orchestration-patterns.md)

### Configuration Files

```bash
# View all agents
ls .claude/agents/

# View specific agent
cat .claude/agents/[agent-name].md

# View templates
ls agents/templates/

# View specific template
cat agents/templates/level-[0-5]-*.md
```text

### Escalation Path

If you can't resolve an issue:

1. **First**: Check this troubleshooting guide
1. **Second**: Review relevant documentation
1. **Third**: Ask an orchestrator to coordinate
1. **Fourth**: Escalate to Chief Architect for strategic issues

### Debugging Checklist

When something goes wrong:

- [ ] Identified which agent was involved
- [ ] Checked agent's scope and responsibilities
- [ ] Reviewed relevant specifications
- [ ] Checked for coordination issues
- [ ] Verified worktree setup
- [ ] Consulted troubleshooting guide
- [ ] Escalated if needed

---

**Remember**: Most issues are resolved by:

1. Clear communication
1. Proper delegation
1. Using the right agent for the task
1. Following the 5-phase workflow
1. Leveraging git worktrees for parallel work

Good luck! The agent system is designed to help you succeed.
