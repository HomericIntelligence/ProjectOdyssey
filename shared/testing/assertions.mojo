"""Custom assertion utilities for ML Odyssey testing.

Provides tensor-specific assertion functions that wrap Mojo's standard testing
module and add custom validations for neural network testing.

Functions:
    assert_true: Assert a condition is true.
    assert_equal: Assert two values are equal.
    assert_equal_int: Assert two integers are equal.
    assert_almost_equal: Assert two floats are approximately equal.
    assert_shape: Assert tensor has expected shape.

Example:
    from shared.testing.assertions import assert_equal, assert_almost_equal
    from shared.core import ExTensor, ones

    fn test_tensor_creation():
        var tensor = ones(List[Int](32, 10), DType.float32)
        assert_shape(tensor, List[Int](32, 10), "Wrong shape")
        assert_almost_equal(tensor._get_float64(0), 1.0, 1e-6, "Expected 1.0")
"""

from testing import assert_equal as mojo_assert_equal
from testing import assert_true as mojo_assert_true
from shared.core import ExTensor


# ============================================================================
# Basic Assertions (Wrapping Mojo's testing module)
# ============================================================================


fn assert_true(condition: Bool, message: String) raises:
    """Assert that a condition is true.

    Args:
        condition: Boolean condition to check.
        message: Error message if assertion fails.

    Raises:
        Error if condition is False.

    Example:
        assert_true(5 > 3, "5 should be greater than 3")
    """
    if not condition:
        raise Error(message)


fn assert_equal(actual: Int, expected: Int, message: String) raises:
    """Assert that two integers are equal.

    Args:
        actual: Actual integer value.
        expected: Expected integer value.
        message: Error message if assertion fails.

    Raises:
        Error if actual != expected.

    Example:
        assert_equal(42, 42, "Values should match")
    """
    if actual != expected:
        raise Error(message)


fn assert_equal(actual: String, expected: String, message: String) raises:
    """Assert that two strings are equal.

    Args:
        actual: Actual string value.
        expected: Expected string value.
        message: Error message if assertion fails.

    Raises:
        Error if actual != expected.

    Example:
        assert_equal("hello", "hello", "Strings should match")
    """
    if actual != expected:
        raise Error(message)


# ============================================================================
# Floating Point Assertions
# ============================================================================


fn assert_almost_equal(
    actual: Float64,
    expected: Float64,
    tolerance: Float64,
    message: String
) raises:
    """Assert that two floats are approximately equal within tolerance.

    Uses absolute difference for comparison: |actual - expected| <= tolerance.

    Args:
        actual: Actual float value.
        expected: Expected float value.
        tolerance: Maximum allowed difference.
        message: Error message if assertion fails.

    Raises:
        Error if |actual - expected| > tolerance.

    Example:
        assert_almost_equal(0.99999999, 1.0, 1e-6, "Values should be close")
    """
    var diff = abs(actual - expected)
    if diff > tolerance:
        raise Error(message)


fn assert_almost_equal(
    actual: Float32,
    expected: Float32,
    tolerance: Float64,
    message: String
) raises:
    """Assert that two Float32 values are approximately equal within tolerance.

    Converts Float32 values to Float64 for comparison to handle precision properly.

    Args:
        actual: Actual Float32 value.
        expected: Expected Float32 value.
        tolerance: Maximum allowed difference.
        message: Error message if assertion fails.

    Raises:
        Error if |actual - expected| > tolerance.

    Example:
        var f32_val: Float32 = 0.5
        assert_almost_equal(f32_val, Float32(0.5), 1e-6, "Values should match")
    """
    var actual_f64 = Float64(actual)
    var expected_f64 = Float64(expected)
    var diff = abs(actual_f64 - expected_f64)
    if diff > tolerance:
        raise Error(message)


# ============================================================================
# Tensor Assertions
# ============================================================================


fn assert_shape(tensor: ExTensor, expected_shape: List[Int], message: String) raises:
    """Assert that tensor has expected shape.

    Validates both:
    - Number of dimensions.
    - Size of each dimension.

    Args:
        tensor: Tensor to check.
        expected_shape: Expected shape as list of dimensions.
        message: Error message if assertion fails.

    Raises:
        Error if shape doesn't match.

    Example:
        var tensor = ones(List[Int](32, 10), DType.float32)
        assert_shape(tensor, List[Int](32, 10), "Wrong shape")
    """
    # Check number of dimensions
    if len(tensor._shape) != len(expected_shape):
        raise Error(message)

    # Check each dimension
    for i in range(len(expected_shape)):
        if tensor._shape[i] != expected_shape[i]:
            raise Error(message)
