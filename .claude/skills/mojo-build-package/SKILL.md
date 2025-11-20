---
name: mojo-build-package
description: Build Mojo packages (.mojopkg files) for distribution and reuse. Use when creating distributable Mojo libraries or when packaging phase requires building packages.
---

# Mojo Build Package Skill

This skill builds Mojo packages (`.mojopkg` files) for distribution and modular reuse.

## When to Use

- User asks to build a package (e.g., "build the tensor package")
- Package phase of development workflow
- Creating distributable libraries
- Preparing for package installation
- Building modular components

## What is a Mojo Package

A `.mojopkg` file is Mojo's compiled package format:

- **Pre-compiled** - Faster loading than source
- **Distributable** - Share without source code
- **Modular** - Import as module
- **Versioned** - Supports versioning

## Usage

### Build Single Package

```bash
# Build package from source directory
mojo package src/tensor -o packages/tensor.mojopkg

# Build with specific name
./scripts/build_package.sh tensor
```text

### Build All Packages

```bash
# Build all packages in src/
./scripts/build_all_packages.sh
```text

### Package Structure

```text
src/tensor/
├── __init__.mojo          # Package entry point
├── operations.mojo        # Module
├── types.mojo             # Module
└── utils.mojo             # Module

# Builds to
packages/tensor.mojopkg    # Compiled package
```text

## Package Organization

### Source Layout

```text
src/
├── tensor/                # Package: tensor
│   ├── __init__.mojo
│   └── ops.mojo
├── nn/                    # Package: nn (neural network)
│   ├── __init__.mojo
│   ├── layers.mojo
│   └── activations.mojo
└── utils/                 # Package: utils
    ├── __init__.mojo
    └── helpers.mojo
```text

### Built Packages

```text
packages/
├── tensor.mojopkg
├── nn.mojopkg
└── utils.mojopkg
```text

## Package Entry Point

Every package needs `__init__.mojo`:

```mojo
# src/tensor/__init__.mojo
"""Tensor operations package."""

from .operations import add, multiply, matmul
from .types import Tensor

# Re-export for package API
__all__ = ["Tensor", "add", "multiply", "matmul"]
```text

## Build Configuration

### Package Metadata

Create `package.toml` (optional):

```toml
[package]
name = "tensor"
version = "0.1.0"
description = "Tensor operations library"
authors = ["ML Odyssey Team"]

[dependencies]
# Package dependencies
```text

### Build Script

```bash
./scripts/build_package.sh <package-name>

# This
# 1. Validates source structure
# 2. Runs mojo package command
# 3. Verifies output
# 4. Optionally runs tests
```text

## Using Built Packages

### Import Package

```mojo
from tensor import Tensor, add

fn main():
    let t = Tensor[DType.float32, 2](10, 10)
    let result = add(t, t)
```text

### Install Package (Future)

```bash
# When package manager available
mojo install packages/tensor.mojopkg
```text

## Error Handling

### Build Errors

```text
Error: Cannot build package 'tensor'
  Missing __init__.mojo
```text

**Fix:** Add `__init__.mojo` to package directory

### Circular Dependencies

```text
Error: Circular dependency detected
  tensor -> nn -> tensor
```text

**Fix:** Refactor to break circular dependency

### Missing Exports

```text
Error: Name 'Tensor' not exported
```text

**Fix:** Add to `__all__` in `__init__.mojo`

## Package Testing

After building, verify package works:

```bash
# Test package imports
./scripts/test_package.sh tensor

# This creates temporary test file
from tensor import Tensor
fn test():
    let t = Tensor()  # Verify can import and use
```text

## CI Integration

```yaml
- name: Build Packages
  run: ./scripts/build_all_packages.sh

- name: Test Packages
  run: ./scripts/test_all_packages.sh
```text

## Distribution

### Create Archive

```bash
# Create distributable archive
./scripts/create_package_archive.sh

# Creates
# ml-odyssey-packages-v0.1.0.tar.gz
#   ├── packages/
#   │   ├── tensor.mojopkg
#   │   ├── nn.mojopkg
#   │   └── utils.mojopkg
#   ├── README.md
#   └── LICENSE
```text

## Examples

### Build single package:

```bash
./scripts/build_package.sh tensor
```text

### Build all packages:

```bash
./scripts/build_all_packages.sh
```text

### Build and test:

```bash
./scripts/build_package.sh tensor --test
```text

### Create distribution:

```bash
./scripts/create_package_archive.sh v0.1.0
```text

## Scripts Available

- `scripts/build_package.sh` - Build single package
- `scripts/build_all_packages.sh` - Build all packages
- `scripts/test_package.sh` - Test package imports
- `scripts/create_package_archive.sh` - Create distribution archive
- `scripts/clean_packages.sh` - Clean built packages

## Templates

- `templates/package_init.mojo` - Package **init**.mojo template
- `templates/package_toml.toml` - Package metadata template

## Best Practices

1. **Clear API** - Export only public interface in `__init__.mojo`
1. **Version packages** - Use semantic versioning
1. **Test imports** - Verify package can be imported after build
1. **Documentation** - Document package API
1. **Minimal dependencies** - Keep dependencies minimal
1. **Stable interface** - Avoid breaking changes

See CLAUDE.md for package phase workflow and requirements.
