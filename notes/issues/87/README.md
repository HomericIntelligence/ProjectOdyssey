# Issue #87: [Plan] Create Base Config - Design and Documentation

## Objective

Create the foundational `magic.toml` configuration file with project metadata for the ML Odyssey repository, establishing a minimal valid configuration that can be expanded in later phases.

## Deliverables

- Comprehensive design specification for `magic.toml` structure
- Project metadata section definition
- Documentation of configuration schema and conventions
- Planning for future extensibility (dependencies and channels)
- Implementation guidelines for the minimal valid configuration

## Success Criteria

- [ ] Configuration file structure defined for repository root
- [ ] Project metadata fields specified with appropriate values
- [ ] Valid TOML file schema documented
- [ ] Clear explanatory comments planned throughout
- [ ] Future expansion points identified
- [ ] Validation requirements specified

## References

- [Foundation Plan](../../plan/01-foundation/plan.md) - Repository foundation overview
- [Magic TOML Plan](../../plan/01-foundation/02-configuration-files/01-magic-toml/plan.md) - Magic configuration strategy
- [Create Base Config Plan](../../plan/01-foundation/02-configuration-files/01-magic-toml/01-create-base-config/plan.md) - Component requirements
- [CLAUDE.md](../../../CLAUDE.md) - Project conventions and guidelines

## Planning Documentation

### 1. Configuration File Overview

**Purpose**: `magic.toml` is the package manager configuration file for Mojo/MAX projects, similar to `package.json` for Node.js or `pyproject.toml` for Python. It defines project metadata, dependencies, channels, and environment configuration.

**Location**: Repository root (`/home/user/ml-odyssey/magic.toml`)

**Format**: TOML (Tom's Obvious, Minimal Language) - human-readable configuration format

### 2. Base Configuration Structure

```toml
# ML Odyssey - Magic Package Manager Configuration
# This file defines the project metadata and package management settings
# for the Mojo/MAX development environment.

[project]
# Project metadata section - defines basic information about the project
name = "ml-odyssey"
version = "0.1.0"
description = "A Mojo-based AI research platform for reproducing classic research papers"
authors = ["ML Odyssey Contributors"]
readme = "README.md"
license = "MIT"
homepage = "https://github.com/mvillmow/ml-odyssey"
repository = "https://github.com/mvillmow/ml-odyssey"

[project.urls]
# Additional project URLs for documentation and tracking
"Documentation" = "https://github.com/mvillmow/ml-odyssey/tree/main/docs"
"Bug Tracker" = "https://github.com/mvillmow/ml-odyssey/issues"
"Changelog" = "https://github.com/mvillmow/ml-odyssey/blob/main/CHANGELOG.md"

# Note: Dependencies section will be added in Issue #88
# [dependencies]
# max = "^24.5.0"
# python = ">=3.11"

# Note: Channels section will be added in Issue #89
# [channels]
# default = ["conda-forge", "https://conda.modular.com/max"]
```

### 3. Field Specifications

#### Project Section

| Field | Type | Required | Description | Example Value |
|-------|------|----------|-------------|---------------|
| `name` | string | Yes | Package/project name (lowercase, hyphens allowed) | `"ml-odyssey"` |
| `version` | string | Yes | Semantic version (MAJOR.MINOR.PATCH) | `"0.1.0"` |
| `description` | string | Yes | Brief project description (<200 chars) | `"A Mojo-based AI research platform..."` |
| `authors` | array | No | List of authors/contributors | `["ML Odyssey Contributors"]` |
| `readme` | string | No | Path to README file | `"README.md"` |
| `license` | string | No | License identifier (SPDX format) | `"MIT"` |
| `homepage` | string | No | Project homepage URL | `"https://github.com/..."` |
| `repository` | string | No | Source repository URL | `"https://github.com/..."` |

#### Project URLs Section

Optional section for additional project links. Common entries:
- Documentation
- Bug Tracker
- Changelog
- Discussions
- Funding

### 4. Design Decisions

#### 4.1 Version Strategy
- Start with `0.1.0` indicating pre-release/development status
- Follow semantic versioning: MAJOR.MINOR.PATCH
- Update MINOR for feature additions (new papers)
- Update PATCH for bug fixes and small improvements

#### 4.2 Naming Conventions
- Use lowercase with hyphens for project name
- Match GitHub repository name for consistency
- Keep description concise but informative

#### 4.3 Author Attribution
- Use generic "ML Odyssey Contributors" initially
- Can expand to specific names as project grows
- Follows open-source contribution model

#### 4.4 License Selection
- MIT License chosen for maximum compatibility
- Allows both academic and commercial use
- Simple and permissive for research platform

### 5. Validation Requirements

#### TOML Syntax Validation
- Valid TOML 1.0.0 syntax
- Proper string quoting
- Correct array syntax for authors
- Valid URL formats

#### Content Validation
- Version must follow semantic versioning pattern
- URLs must be valid and accessible
- License must be valid SPDX identifier
- Name must contain only lowercase letters, numbers, hyphens

#### Magic-Specific Requirements
- File must be named exactly `magic.toml`
- Must be located at repository root
- Project section is mandatory
- Name and version fields are required

### 6. Implementation Guidelines

#### Step 1: Create File
```bash
touch /home/user/ml-odyssey/magic.toml
```

#### Step 2: Add Header Comments
- Explain file purpose
- Note that it's for Magic package manager
- Reference documentation

#### Step 3: Add Project Section
- Start with required fields (name, version)
- Add description for clarity
- Include optional metadata fields

#### Step 4: Add Project URLs
- Include GitHub repository link
- Add documentation link
- Include issue tracker for bug reports

#### Step 5: Add Placeholder Comments
- Note where dependencies will be added (Issue #88)
- Note where channels will be added (Issue #89)
- Explain expansion strategy

### 7. Testing Strategy

#### Manual Testing
1. Validate TOML syntax using online validator
2. Check field completeness against specification
3. Verify URLs are accessible
4. Confirm semantic version format

#### Automated Testing
1. Use TOML parsing library to validate structure
2. Check required fields presence
3. Validate field types and formats
4. Test with Magic CLI (when available)

### 8. Future Expansion Points

#### Dependencies (Issue #88)
```toml
[dependencies]
max = "^24.5.0"
python = ">=3.11"
numpy = "^1.24.0"
matplotlib = "^3.7.0"
```

#### Channels (Issue #89)
```toml
[channels]
default = ["conda-forge", "https://conda.modular.com/max"]
```

#### Additional Sections (Future)
- `[tool.magic]` - Tool-specific settings
- `[build]` - Build configuration
- `[scripts]` - Custom scripts/commands
- `[features]` - Optional features

### 9. Migration from Pixi

**Current State**: Repository uses `pixi.toml` for package management

**Migration Strategy**:
1. Create `magic.toml` alongside `pixi.toml` (this issue)
2. Mirror essential configuration from pixi
3. Test both systems work in parallel
4. Gradually transition to Magic as primary
5. Eventually deprecate pixi.toml

**Key Differences**:
- Magic is Modular's official package manager for Mojo
- Better integration with MAX ecosystem
- Designed specifically for ML/AI workflows
- Native support for Mojo packages

### 10. Documentation Requirements

#### Inline Comments
- Explain each section purpose
- Document non-obvious field choices
- Reference related documentation
- Note future expansion points

#### README Updates
After implementation, update main README.md to:
- Mention Magic as package manager
- Include installation instructions
- Reference magic.toml for configuration

#### Developer Guide
Create or update developer documentation to:
- Explain magic.toml structure
- Document how to add dependencies
- Provide troubleshooting tips
- Include common configuration patterns

## Implementation Notes

**Phase**: Planning (Issue #87 - Current)
**Next Phase**: Test (Issue #90), Implementation (Issue #91), Package (Issue #92)

### Key Considerations

1. **Minimal Valid Configuration**: Focus on smallest valid magic.toml that Magic will accept
2. **Clear Documentation**: Every field and section should have explanatory comments
3. **Future-Proof Design**: Structure should accommodate future additions without breaking changes
4. **Compatibility**: Ensure configuration doesn't conflict with existing pixi.toml
5. **Best Practices**: Follow TOML and Magic conventions consistently

### Open Questions

1. Should we include optional fields in base config or add them later?
   - **Decision**: Include common optional fields (authors, license, etc.) for completeness
   
2. How to handle version synchronization with pixi.toml?
   - **Decision**: Maintain same version in both files during transition period
   
3. Should we specify Python version in base config?
   - **Decision**: No, add dependencies in Issue #88 as planned

### Success Validation

The planning phase is complete when:
- ✅ Complete specification for magic.toml structure
- ✅ All fields documented with types and examples
- ✅ Validation requirements clearly defined
- ✅ Implementation steps outlined
- ✅ Future expansion strategy documented
- ✅ Migration path from pixi.toml considered

## Next Steps

1. **Issue #90: [Test] Create Base Config** - Write tests for configuration validation
2. **Issue #91: [Implementation] Create Base Config** - Create actual magic.toml file
3. **Issue #92: [Package] Create Base Config** - Integrate into development workflow
4. **Issue #93: [Cleanup] Create Base Config** - Polish and optimize

---

**Last Updated**: 2025-11-15
**Status**: Planning Complete ✅
