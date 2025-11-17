"""Arithmetic operations for ExTensor with broadcasting support.

Implements element-wise arithmetic operations following NumPy-style broadcasting.
"""

from .extensor import ExTensor
from .broadcasting import broadcast_shapes, compute_broadcast_strides


fn add(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise addition with broadcasting.

    Args:
        a: First tensor
        b: Second tensor

    Returns:
        A new tensor containing a + b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = zeros(DynamicVector[Int](3, 4), DType.float32)
        var b = ones(DynamicVector[Int](3, 4), DType.float32)
        var c = add(a, b)  # Shape (3, 4), all ones
    """
    # Check dtype compatibility
    if a.dtype() != b.dtype():
        raise Error("Cannot add tensors with different dtypes")

    # Compute broadcast shape
    let result_shape = broadcast_shapes(a.shape(), b.shape())

    # Create result tensor
    var result = ExTensor(result_shape, a.dtype())

    # Compute broadcast strides
    let strides_a = compute_broadcast_strides(a.shape(), result_shape)
    let strides_b = compute_broadcast_strides(b.shape(), result_shape)

    # Perform element-wise addition
    # TODO: Implement efficient broadcasting iteration and add operation
    # For now, this is a placeholder
    result._fill_zero()

    return result^


fn subtract(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise subtraction with broadcasting.

    Args:
        a: First tensor
        b: Second tensor

    Returns:
        A new tensor containing a - b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = ones(DynamicVector[Int](3, 4), DType.float32)
        var b = ones(DynamicVector[Int](3, 4), DType.float32)
        var c = subtract(a, b)  # Shape (3, 4), all zeros
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot subtract tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement subtraction
    result._fill_zero()

    return result^


fn multiply(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise multiplication with broadcasting.

    Args:
        a: First tensor
        b: Second tensor

    Returns:
        A new tensor containing a * b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = full(DynamicVector[Int](3, 4), 2.0, DType.float32)
        var b = full(DynamicVector[Int](3, 4), 3.0, DType.float32)
        var c = multiply(a, b)  # Shape (3, 4), all 6.0
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot multiply tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement multiplication
    result._fill_zero()

    return result^


fn divide(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise division with broadcasting.

    Args:
        a: First tensor (numerator)
        b: Second tensor (denominator)

    Returns:
        A new tensor containing a / b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Note:
        Division by zero follows IEEE 754 semantics for floating-point types:
        - x / 0.0 where x > 0 -> +inf
        - x / 0.0 where x < 0 -> -inf
        - 0.0 / 0.0 -> NaN

    Examples:
        var a = full(DynamicVector[Int](3, 4), 6.0, DType.float32)
        var b = full(DynamicVector[Int](3, 4), 2.0, DType.float32)
        var c = divide(a, b)  # Shape (3, 4), all 3.0
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot divide tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement division
    result._fill_zero()

    return result^


fn floor_divide(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise floor division with broadcasting.

    Args:
        a: First tensor (numerator)
        b: Second tensor (denominator)

    Returns:
        A new tensor containing a // b (floor division)

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = full(DynamicVector[Int](3, 4), 7.0, DType.float32)
        var b = full(DynamicVector[Int](3, 4), 2.0, DType.float32)
        var c = floor_divide(a, b)  # Shape (3, 4), all 3.0
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot floor divide tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement floor division
    result._fill_zero()

    return result^


fn modulo(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise modulo with broadcasting.

    Args:
        a: First tensor
        b: Second tensor (modulus)

    Returns:
        A new tensor containing a % b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = full(DynamicVector[Int](3, 4), 7.0, DType.int32)
        var b = full(DynamicVector[Int](3, 4), 3.0, DType.int32)
        var c = modulo(a, b)  # Shape (3, 4), all 1
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot compute modulo for tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement modulo
    result._fill_zero()

    return result^


fn power(a: ExTensor, b: ExTensor) raises -> ExTensor:
    """Element-wise exponentiation with broadcasting.

    Args:
        a: Base tensor
        b: Exponent tensor

    Returns:
        A new tensor containing a ** b

    Raises:
        Error if shapes are not broadcast-compatible or dtypes don't match

    Examples:
        var a = full(DynamicVector[Int](3, 4), 2.0, DType.float32)
        var b = full(DynamicVector[Int](3, 4), 3.0, DType.float32)
        var c = power(a, b)  # Shape (3, 4), all 8.0
    """
    if a.dtype() != b.dtype():
        raise Error("Cannot compute power for tensors with different dtypes")

    let result_shape = broadcast_shapes(a.shape(), b.shape())
    var result = ExTensor(result_shape, a.dtype())

    # TODO: Implement power
    result._fill_zero()

    return result^


# TODO: Implement dunder methods on ExTensor struct:
# fn __add__(self, other: ExTensor) -> ExTensor
# fn __sub__(self, other: ExTensor) -> ExTensor
# fn __mul__(self, other: ExTensor) -> ExTensor
# fn __truediv__(self, other: ExTensor) -> ExTensor
# fn __floordiv__(self, other: ExTensor) -> ExTensor
# fn __mod__(self, other: ExTensor) -> ExTensor
# fn __pow__(self, other: ExTensor) -> ExTensor
#
# And reflected variants (__radd__, __rsub__, etc.)
# And in-place variants (__iadd__, __isub__, etc.)
