"""Assertion helpers for ExTensor testing.

Provides comprehensive assertion functions for validating tensor properties,
values, shapes, dtypes, and numerical accuracy.

Note: These functions work with ExTensor through duck typing.
Import ExTensor in your test files before using these assertions.
"""

from math import abs as math_abs, isnan, isinf


fn assert_true(condition: Bool, message: String = "") raises:
    """Assert a condition is true.

    Args:
        condition: The condition to check
        message: Optional error message

    Raises:
        Error if condition is false
    """
    if not condition:
        if message:
            raise Error("Assertion failed: " + message)
        else:
            raise Error("Assertion failed")


fn assert_false(condition: Bool, message: String = "") raises:
    """Assert a condition is false.

    Args:
        condition: The condition to check
        message: Optional error message

    Raises:
        Error if condition is true
    """
    if condition:
        if message:
            raise Error("Assertion failed: " + message)
        else:
            raise Error("Assertion failed: expected false")


fn assert_equal_int(a: Int, b: Int, message: String = "") raises:
    """Assert two integers are equal.

    Args:
        a: First integer
        b: Second integer
        message: Optional error message

    Raises:
        Error if integers are not equal
    """
    if a != b:
        var msg = "Expected " + str(a) + " == " + str(b)
        if message:
            msg = message + ": " + msg
        raise Error(msg)


fn assert_equal_float(a: Float64, b: Float64, tolerance: Float64 = 1e-8, message: String = "") raises:
    """Assert two floats are equal within tolerance.

    Args:
        a: First float
        b: Second float
        tolerance: Numerical tolerance
        message: Optional error message

    Raises:
        Error if floats differ beyond tolerance
    """
    let diff = math_abs(a - b)
    if diff > tolerance:
        var msg = "Expected " + str(a) + " ≈ " + str(b) + " (diff=" + str(diff) + ")"
        if message:
            msg = message + ": " + msg
        raise Error(msg)


fn assert_close_float(
    a: Float64,
    b: Float64,
    rtol: Float64 = 1e-5,
    atol: Float64 = 1e-8,
    message: String = ""
) raises:
    """Assert two floats are numerically close.

    Uses the formula: |a - b| <= atol + rtol * |b|

    Args:
        a: First float
        b: Second float
        rtol: Relative tolerance
        atol: Absolute tolerance
        message: Optional error message

    Raises:
        Error if floats differ beyond tolerance
    """
    # Handle NaN and inf
    let a_is_nan = isnan(a)
    let b_is_nan = isnan(b)
    let a_is_inf = isinf(a)
    let b_is_inf = isinf(b)

    if a_is_nan and b_is_nan:
        return  # Both NaN, considered equal

    if a_is_nan or b_is_nan:
        var msg = "NaN mismatch: " + str(a) + " vs " + str(b)
        if message:
            msg = message + ": " + msg
        raise Error(msg)

    if a_is_inf or b_is_inf:
        if a != b:
            var msg = "Infinity mismatch: " + str(a) + " vs " + str(b)
            if message:
                msg = message + ": " + msg
            raise Error(msg)
        return

    # Check numeric closeness
    let diff = math_abs(a - b)
    let threshold = atol + rtol * math_abs(b)

    if diff > threshold:
        var msg = (
            "Values differ: " + str(a) + " vs " + str(b) + " (diff=" + str(diff) +
            ", threshold=" + str(threshold) + ")"
        )
        if message:
            msg = message + ": " + msg
        raise Error(msg)


# TODO: Add ExTensor-specific assertions once ExTensor is fully implemented
# These will include:
# - assert_equal(a: ExTensor, b: ExTensor)
# - assert_all_close(a: ExTensor, b: ExTensor, rtol, atol)
# - assert_shape(tensor: ExTensor, expected_shape)
# - assert_dtype(tensor: ExTensor, expected_dtype)
# - assert_numel(tensor: ExTensor, expected_numel)
# - assert_dim(tensor: ExTensor, expected_dim)
# - assert_contiguous(tensor: ExTensor)
# - assert_value_at(tensor: ExTensor, index, expected_value)
# - assert_all_values(tensor: ExTensor, expected_value)
