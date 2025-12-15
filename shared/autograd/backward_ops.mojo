"""Backward operation implementations for automatic differentiation.

This module provides re-exports of backward operation implementations
from the tape module. It serves as an interface for accessing the
backward pass implementations used by GradientTape.

The backward functions are organized by operation type:
- Arithmetic operations: add, subtract, multiply, divide, negation
- Reduction operations: sum, mean
- Matrix operations: matmul
- Activation functions: relu, sigmoid, tanh

Design Note:
    This module re-exports functions defined in tape.mojo to provide
    a clean interface for backward pass implementations.

References:
    - GradientTape: Main tape implementation in tape.mojo
    - shared.core: Lower-level backward pass implementations
"""

# Re-export from tape module - the actual implementations live there
# to avoid circular imports and ensure proper type resolution
from .tape import (
    GradientTape,
)

# All backward implementations are accessed via GradientTape methods
# This module exists for documentation and future extensibility
