# ML Odyssey Examples

Complete, runnable examples demonstrating ML Odyssey's features and patterns.

## Overview

This directory contains standalone Mojo code examples referenced throughout the documentation. Each example is:

- **Complete**: Includes all necessary imports and code
- **Runnable**: Can be executed directly with `pixi run mojo run`
- **Documented**: Has clear docstrings explaining what it demonstrates
- **Tested**: Designed to compile and run without errors

## Directory Structure

```text
examples/
├── getting-started/     # Beginner tutorials and quickstart examples
├── mojo-patterns/       # Mojo-specific patterns and idioms
├── custom-layers/       # Building custom neural network components
└── performance/         # Optimization and performance techniques
```

## Getting Started

### Running Examples

```bash
# Run any example
pixi run mojo run examples/getting-started/quickstart_example.mojo

# Or navigate to examples directory first
cd examples
pixi run mojo run getting-started/quickstart_example.mojo
```

### Example Categories

#### 1. Getting Started

Introduction to ML Odyssey basics:

- **`quickstart_example.mojo`** - Simple neural network creation and training
- **`first_model_model.mojo`** - 3-layer digit classifier model
- **`first_model_train.mojo`** - Complete training script with callbacks

**Documentation**: [Getting Started Guide](../docs/getting-started/quickstart.md)

#### 2. Mojo Patterns

Mojo-specific ML patterns:

- **`trait_example.mojo`** - Trait-based design (Module, Optimizer)
- **`ownership_example.mojo`** - Ownership and borrowing patterns
- **`simd_example.mojo`** - SIMD vectorization for performance

**Documentation**: [Mojo Patterns Guide](../docs/core/mojo-patterns.md)

#### 3. Custom Layers

Building custom neural network components:

- **`prelu_activation.mojo`** - Parametric ReLU with learnable parameters
- **`attention_layer.mojo`** - Multi-head self-attention mechanism
- **`focal_loss.mojo`** - Custom loss function for imbalanced data

**Documentation**: [Custom Layers Guide](../docs/advanced/custom-layers.md)

#### 4. Performance

Optimization techniques:

- **`simd_optimization.mojo`** - SIMD for ReLU, batch norm, matmul
- **`memory_optimization.mojo`** - In-place operations and buffer reuse

**Documentation**: [Performance Guide](../docs/advanced/performance.md)

## Example File Structure

Each example follows this template:

```mojo
"""Example: [Category] - [Topic]

Brief description of what this example demonstrates.

Usage:
    pixi run mojo run examples/[category]/[filename].mojo

See documentation: docs/[path]/[doc-file].md
"""

from shared.core import ...  # Imports

# Implementation
struct/fn ...

fn main() raises:
    """Entry point with demonstration code."""
    # Example usage with explanatory comments
    print("Example complete!")
```

## Contributing Examples

When adding new examples:

1. **Follow the template** - Use consistent structure
2. **Add docstrings** - Explain what the example demonstrates
3. **Keep it focused** - One concept per example
4. **Make it runnable** - Include all necessary code
5. **Link to docs** - Reference the related documentation
6. **Test it** - Verify it compiles and runs

## Example Usage Patterns

### Pattern 1: Simple Execution

```bash
pixi run mojo run examples/getting-started/quickstart_example.mojo
```

### Pattern 2: With Custom Data

Modify examples to use your own data:

```mojo
# In the example file
var X_train = load_your_data()  # Replace placeholder
var y_train = load_your_labels()
```

### Pattern 3: Building On Examples

Use examples as starting points:

```bash
cp examples/getting-started/quickstart_example.mojo my_model.mojo
# Edit my_model.mojo with your changes
pixi run mojo run my_model.mojo
```

## Documentation Links

Each example references its documentation:

- Getting Started: [docs/getting-started/](../docs/getting-started/)
- Core Concepts: [docs/core/](../docs/core/)
- Advanced Topics: [docs/advanced/](../docs/advanced/)

## Common Issues

### Import Errors

If you see import errors:

```bash
# Ensure you're in the repository root
cd /path/to/ml-odyssey

# Verify shared library exists
ls shared/

# Run from repository root
pixi run mojo run examples/getting-started/quickstart_example.mojo
```

### Placeholder Data

Many examples use placeholder data (`Tensor.randn()`) for demonstration. Replace with real data for actual use:

```mojo
# Example placeholder (for demonstration)
var X_train = Tensor.randn(1000, 784)

# Replace with real data (for actual use)
var X_train = load_mnist_data()
```

## See Also

- [Documentation Index](../docs/index.md) - Full documentation
- [Quickstart Guide](../docs/getting-started/quickstart.md) - Get started in 5 minutes
- [Project Structure](../docs/core/project-structure.md) - Repository organization
- [Testing Strategy](../docs/core/testing-strategy.md) - Testing your code

## License

See [LICENSE](../LICENSE) for licensing information.
