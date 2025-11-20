---
name: phase-package
description: Create distributable packages including .mojopkg files, archives, and installation procedures. Use during package phase to prepare components for distribution and reuse.
---

# Package Phase Coordination Skill

This skill coordinates the package phase to create distributable artifacts.

## When to Use

- User asks to package components (e.g., "create package for tensor module")
- Package phase of 5-phase workflow
- Preparing for distribution
- Creating reusable components

## Package Types

### 1. Mojo Packages (.mojopkg)

Compiled Mojo modules:

```bash
./scripts/package_mojo_module.sh tensor
# Creates: packages/tensor.mojopkg
```text

### 2. Distribution Archives

Tar/zip archives for tooling and documentation:

```bash
./scripts/create_distribution.sh ml-odyssey-v0.1.0
# Creates: dist/ml-odyssey-v0.1.0.tar.gz
```text

### 3. Installation Procedures

Scripts and documentation for installation:

```bash
./scripts/create_installer.sh tensor
# Creates: install_tensor.sh, INSTALL.md
```text

## Workflow

### 1. Build Packages

```bash
# Build all Mojo packages
./scripts/build_all_packages.sh

# Build specific package
./scripts/build_package.sh tensor
```text

### 2. Create Archives

```bash
# Create distribution archive
./scripts/create_archive.sh v0.1.0

# Includes
# - packages/*.mojopkg
# - README.md
# - LICENSE
# - INSTALL.md
# - examples/
```text

### 3. Test Installation

```bash
# Test in clean environment
./scripts/test_installation.sh packages/tensor.mojopkg

# Verifies
# - Package can be imported
# - Dependencies resolved
# - Examples work
```text

### 4. Create CI Workflow

```bash
# Generate packaging workflow
./scripts/create_packaging_workflow.sh

# Creates: .github/workflows/package.yml
```text

## Package Structure

### Mojo Package Layout

```text
src/tensor/
├── __init__.mojo      # Package entry point
├── ops.mojo           # Operations module
└── types.mojo         # Type definitions

# Builds to
packages/tensor.mojopkg
```text

### Distribution Archive Layout

```text
ml-odyssey-v0.1.0/
├── packages/
│   ├── tensor.mojopkg
│   ├── nn.mojopkg
│   └── utils.mojopkg
├── examples/
│   ├── tensor_demo.mojo
│   └── nn_demo.mojo
├── README.md
├── LICENSE
└── INSTALL.md
```text

## Quality Checks

Before finalizing package:

- [ ] Package builds successfully
- [ ] Can be imported in clean environment
- [ ] Examples run correctly
- [ ] Documentation included
- [ ] License file present
- [ ] Version tagged correctly

## Error Handling

- **Build failures**: Fix source code issues
- **Import errors**: Check **init**.mojo exports
- **Missing dependencies**: Document in package metadata
- **Installation failures**: Test and fix installer

## Examples

### Package Mojo module:

```bash
./scripts/package_mojo_module.sh tensor
```text

### Create distribution:

```bash
./scripts/create_distribution.sh v0.1.0
```text

### Test package:

```bash
./scripts/test_package.sh tensor.mojopkg
```text

## Scripts Available

- `scripts/package_mojo_module.sh` - Build Mojo package
- `scripts/create_distribution.sh` - Create archive
- `scripts/create_installer.sh` - Generate installer
- `scripts/test_installation.sh` - Test package
- `scripts/create_packaging_workflow.sh` - Generate CI workflow

## Templates

- `templates/package_readme.md` - Package README template
- `templates/install_instructions.md` - Installation guide
- `templates/package_workflow.yml` - CI workflow template

See CLAUDE.md for package phase requirements and 5-phase workflow.
