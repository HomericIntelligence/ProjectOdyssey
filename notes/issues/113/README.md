# Issue #113: [Plan] Add Python Dependencies - Design and Documentation

## Objective

Add Python dependencies to pyproject.toml for development, testing, and optional features. This includes runtime
dependencies, development tools, and optional dependencies for specific features. The planning phase will define
detailed specifications, design the architecture, and document dependency organization strategy.

## Deliverables

- Detailed specifications for Python dependency groups
- Runtime dependency specifications
- Development dependency specifications
- Testing dependency specifications
- Documentation dependency specifications
- Dependency version strategy and constraints documentation
- Optional dependency groups design

## Success Criteria

- [ ] All necessary Python dependencies are identified and categorized
- [ ] Dependencies are organized into appropriate groups (runtime, dev, test, docs)
- [ ] Version constraints are specified where needed with clear rationale
- [ ] Optional dependencies are properly grouped by feature
- [ ] Dependency selection follows YAGNI and minimal dependency principles
- [ ] Documentation explains dependency choices and version constraints

## References

- Source Plan: `/notes/plan/01-foundation/02-configuration-files/02-pyproject-toml/02-add-python-deps/plan.md`
- Parent Component: #123 (Pyproject TOML)
- Related Issues:
  - #114 ([Test] Add Python Dependencies)
  - #115 ([Impl] Add Python Dependencies)
  - #116 ([Package] Add Python Dependencies)
  - #117 ([Cleanup] Add Python Dependencies)

## Implementation Notes

*(To be filled during implementation)*

## Design Decisions

### Dependency Groups

Python dependencies will be organized into the following groups:

#### 1. Runtime Dependencies (`[project.dependencies]`)

**Purpose**: Core dependencies required to run the application/library.

**Strategy**:

- Minimal set following YAGNI principle
- Only include dependencies that are truly required at runtime
- Consider Mojo's stdlib capabilities before adding Python dependencies
- Current status: TBD during implementation (likely minimal or empty for Mojo-first project)

**Examples** (if needed):

- Configuration parsing (if not using stdlib)
- Logging utilities (if extending beyond stdlib)

#### 2. Development Dependencies (`[project.optional-dependencies.dev]`)

**Purpose**: Tools needed during development but not for runtime.

**Strategy**:

- Include code quality tools (formatters, linters)
- Include type checking tools
- Include development utilities

**Examples**:

- `ruff` - Fast Python linter and formatter
- `mypy` - Static type checker
- `pre-commit` - Git hook framework
- Development utilities as needed

#### 3. Testing Dependencies (`[project.optional-dependencies.test]`)

**Purpose**: Dependencies required to run tests.

**Strategy**:

- Include testing framework and utilities
- Include test coverage tools
- Include test fixtures and utilities

**Examples**:

- `pytest` - Testing framework
- `pytest-cov` - Coverage reporting
- `pytest-xdist` - Parallel test execution
- Mock/fixture libraries as needed

#### 4. Documentation Dependencies (`[project.optional-dependencies.docs]`)

**Purpose**: Tools for generating and building documentation.

**Strategy**:

- Include documentation generation tools
- Include theme and plugin dependencies
- Keep separate from dev dependencies for clean builds

**Examples** (if documentation generation is needed):

- `mkdocs` or `sphinx` - Documentation generators
- Themes and plugins as needed
- Markdown processors if required

### Version Strategy

**Approach**: Balanced between flexibility and reproducibility.

**Guidelines**:

1. **Minimum Version Constraints**: Use `>=` for most dependencies to allow flexibility
   - Example: `pytest>=7.0.0`
   - Rationale: Allows users to benefit from patches and minor updates

2. **Upper Bounds for Breaking Changes**: Use `<` for dependencies with known breaking changes
   - Example: `somelib>=1.0.0,<2.0.0`
   - Rationale: Prevents automatic installation of incompatible versions

3. **Exact Pins**: Use `==` only for critical dependencies with known issues
   - Example: `critical-lib==1.2.3`
   - Rationale: Use sparingly, only when necessary

4. **Version File**: Consider using a separate `requirements.txt` or lock file for CI/CD
   - Rationale: Provides reproducible builds while allowing flexibility

**Rationale**:

- Follows modern Python packaging best practices
- Balances stability with flexibility
- Allows users to resolve conflicts in their environments
- Supports both development and production use cases

### Optional Dependencies

**Structure**: Group optional dependencies by feature or use case.

**Groups**:

1. `dev` - Development tools (formatters, linters, type checkers)
2. `test` - Testing framework and utilities
3. `docs` - Documentation generation (if needed)
4. `all` - Meta-group including all optional dependencies for convenience

**Installation Examples**:

```bash
# Install with development tools
pip install -e ".[dev]"

# Install with testing dependencies
pip install -e ".[test]"

# Install everything
pip install -e ".[all]"
```

**Rationale**:

- Separates concerns (dev vs test vs docs)
- Allows users to install only what they need
- Follows Python packaging conventions
- Supports different use cases (development, CI, documentation builds)

### Dependency Selection Criteria

**Principles**:

1. **YAGNI** - Only add dependencies when actually needed
2. **Minimize Dependencies** - Fewer dependencies = fewer security/maintenance issues
3. **Prefer Standard Library** - Use Python/Mojo stdlib when possible
4. **Prefer Mojo** - Check Mojo capabilities before adding Python dependencies
5. **Well-Maintained** - Choose actively maintained projects with good community support
6. **License Compatibility** - Ensure compatible licenses (prefer MIT, Apache 2.0, BSD)

**Evaluation Checklist**:

- [ ] Is this dependency truly necessary? (YAGNI)
- [ ] Can we use stdlib instead?
- [ ] Can we implement this functionality in Mojo?
- [ ] Is the package actively maintained?
- [ ] Does it have good documentation?
- [ ] Is the license compatible?
- [ ] What are the transitive dependencies?

### Integration with Pixi

**Consideration**: The project uses Pixi for environment management.

**Strategy**:

- Maintain `pyproject.toml` for standard Python packaging
- Coordinate with Pixi configuration to avoid duplication
- Ensure dependencies are compatible with both systems
- Document the relationship between `pyproject.toml` and `pixi.toml`

**Rationale**:

- Supports both Pixi users and standard Python packaging
- Maintains compatibility with Python ecosystem tools
- Provides flexibility for different deployment scenarios

## Next Steps

1. Review and approve this planning document
2. Create detailed dependency specifications in implementation phase (#115)
3. Coordinate with test phase (#114) for test dependency requirements
4. Update parent issue (#123) with completion status
5. Ensure consistency with Pixi configuration
