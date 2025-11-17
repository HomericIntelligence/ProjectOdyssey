"""ExTensor package - Extensible Tensors for ML Odyssey.

This package provides a comprehensive tensor implementation with:
- Dynamic shapes and arbitrary dimensions (0D to N-D)
- Multiple data types (float16/32/64, int8/16/32/64, uint8/16/32/64, bool)
- NumPy-style broadcasting
- 150+ operations from Array API Standard 2024
- SIMD-optimized element-wise operations
- Memory-safe via Mojo's ownership system

Examples:
    from extensor import ExTensor, zeros, ones

    # Create tensors
    let a = zeros((3, 4), DType.float32)
    let b = ones((3, 4), DType.float32)

    # Arithmetic with broadcasting
    let c = a + b

    # Matrix multiplication
    let x = zeros((3, 4), DType.float32)
    let y = zeros((4, 5), DType.float32)
    let z = x @ y  # Matrix multiplication
"""

# Core tensor type
from .extensor import ExTensor

# Creation operations
from .extensor import zeros, ones, full, empty

# TODO: Export other operation categories as they are implemented
# from .arithmetic import add, subtract, multiply, divide
# from .matrix import matmul, transpose
# from .reduction import sum, mean, max, min
# etc.
