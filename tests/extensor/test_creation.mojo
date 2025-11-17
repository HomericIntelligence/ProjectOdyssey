"""Tests for ExTensor creation operations.

Tests all tensor creation functions including zeros, ones, full, arange,
from_array, eye, linspace, and empty with various shapes and dtypes.
"""

from sys import DType
from testing import assert_equal, assert_true, assert_false

# Import ExTensor and creation operations
# from extensor import ExTensor, zeros, ones, full, empty
# TODO: Uncomment once module structure is finalized

# Import test helpers
from ..helpers.assertions import (
    assert_true,
    assert_false,
    assert_equal_int,
    assert_equal_float,
    assert_close_float,
)


# ============================================================================
# Test zeros()
# ============================================================================

fn test_zeros_1d_float32() raises:
    """Test creating 1D tensor of zeros with float32."""
    # TODO: Implement once zeros() is available
    # let t = zeros((5,), DType.float32)
    # assert_equal_int(t.dim(), 1)
    # assert_equal_int(t.numel(), 5)
    # # Verify all values are zero
    # for i in range(5):
    #     assert_equal_float(t._data[i], 0.0)
    pass


fn test_zeros_2d_int64() raises:
    """Test creating 2D tensor of zeros with int64."""
    # TODO: Implement once zeros() supports multiple dtypes
    pass


fn test_zeros_3d_float64() raises:
    """Test creating 3D tensor of zeros with float64."""
    # TODO: Implement once zeros() is available
    pass


fn test_zeros_empty_shape() raises:
    """Test creating 0D scalar tensor of zeros."""
    # TODO: Implement once zeros() supports 0D tensors
    pass


fn test_zeros_large_shape() raises:
    """Test creating zeros with very large shape."""
    # TODO: Implement once zeros() is available
    pass


# ============================================================================
# Test ones()
# ============================================================================

fn test_ones_1d_float32() raises:
    """Test creating 1D tensor of ones with float32."""
    # TODO: Implement once ones() is available
    pass


fn test_ones_2d_int32() raises:
    """Test creating 2D tensor of ones with int32."""
    # TODO: Implement once ones() supports multiple dtypes
    pass


fn test_ones_3d_float64() raises:
    """Test creating 3D tensor of ones with float64."""
    # TODO: Implement once ones() is available
    pass


# ============================================================================
# Test full()
# ============================================================================

fn test_full_positive_value() raises:
    """Test creating tensor filled with positive value."""
    # TODO: Implement once full() is available
    pass


fn test_full_negative_value() raises:
    """Test creating tensor filled with negative value."""
    # TODO: Implement once full() is available
    pass


fn test_full_zero_value() raises:
    """Test creating tensor filled with zero (should match zeros)."""
    # TODO: Implement once full() is available
    pass


fn test_full_large_value() raises:
    """Test creating tensor filled with large value."""
    # TODO: Implement once full() is available
    pass


# ============================================================================
# Test empty()
# ============================================================================

fn test_empty_allocates_memory() raises:
    """Test that empty() allocates memory without initialization."""
    # TODO: Implement once empty() is available
    # Verify tensor is created with correct shape
    # Don't check values (they are undefined)
    pass


fn test_empty_1d() raises:
    """Test creating empty 1D tensor."""
    # TODO: Implement once empty() is available
    pass


fn test_empty_2d() raises:
    """Test creating empty 2D tensor."""
    # TODO: Implement once empty() is available
    pass


# ============================================================================
# Test arange()
# ============================================================================

fn test_arange_basic() raises:
    """Test arange with start, stop, step=1."""
    # TODO: Implement once arange() is available
    # let t = arange(0, 10, 1, DType.int32)
    # assert_equal_int(t.numel(), 10)
    # for i in range(10):
    #     assert_equal_int(t._data[i], i)
    pass


fn test_arange_step_2() raises:
    """Test arange with step > 1."""
    # TODO: Implement once arange() is available
    pass


fn test_arange_step_fractional() raises:
    """Test arange with fractional step."""
    # TODO: Implement once arange() is available
    pass


fn test_arange_reverse() raises:
    """Test arange with negative step (reverse order)."""
    # TODO: Implement once arange() is available
    pass


fn test_arange_float() raises:
    """Test arange with float dtype."""
    # TODO: Implement once arange() is available
    pass


# ============================================================================
# Test from_array()
# ============================================================================

fn test_from_array_1d() raises:
    """Test creating tensor from 1D array."""
    # TODO: Implement once from_array() is available
    pass


fn test_from_array_2d() raises:
    """Test creating tensor from 2D nested array."""
    # TODO: Implement once from_array() is available
    pass


fn test_from_array_3d() raises:
    """Test creating tensor from 3D nested array."""
    # TODO: Implement once from_array() is available
    pass


# ============================================================================
# Test eye()
# ============================================================================

fn test_eye_square() raises:
    """Test creating square identity matrix."""
    # TODO: Implement once eye() is available
    # let t = eye(5, DType.float32)
    # assert_equal_int(t.dim(), 2)
    # assert_equal_int(t.numel(), 25)
    # # Check diagonal is 1, off-diagonal is 0
    pass


fn test_eye_rectangular() raises:
    """Test creating rectangular identity matrix."""
    # TODO: Implement once eye() is available
    pass


fn test_eye_offset_diagonal() raises:
    """Test creating identity matrix with offset diagonal (k parameter)."""
    # TODO: Implement once eye() supports k parameter
    pass


# ============================================================================
# Test linspace()
# ============================================================================

fn test_linspace_basic() raises:
    """Test linspace with basic range."""
    # TODO: Implement once linspace() is available
    # let t = linspace(0.0, 10.0, 11, DType.float32)
    # assert_equal_int(t.numel(), 11)
    # for i in range(11):
    #     assert_close_float(t._data[i], float(i))
    pass


fn test_linspace_negative_range() raises:
    """Test linspace with negative start/stop."""
    # TODO: Implement once linspace() is available
    pass


fn test_linspace_small_num() raises:
    """Test linspace with small number of points."""
    # TODO: Implement once linspace() is available
    pass


fn test_linspace_large_num() raises:
    """Test linspace with large number of points."""
    # TODO: Implement once linspace() is available
    pass


# ============================================================================
# Test dtype support
# ============================================================================

fn test_creation_float16() raises:
    """Test creation operations with float16 dtype."""
    # TODO: Implement once all creation ops support float16
    pass


fn test_creation_float32() raises:
    """Test creation operations with float32 dtype."""
    # TODO: Implement - this is the primary dtype for testing
    pass


fn test_creation_float64() raises:
    """Test creation operations with float64 dtype."""
    # TODO: Implement once all creation ops support float64
    pass


fn test_creation_int8() raises:
    """Test creation operations with int8 dtype."""
    # TODO: Implement once all creation ops support int8
    pass


fn test_creation_int32() raises:
    """Test creation operations with int32 dtype."""
    # TODO: Implement once all creation ops support int32
    pass


fn test_creation_uint8() raises:
    """Test creation operations with uint8 dtype."""
    # TODO: Implement once all creation ops support uint8
    pass


fn test_creation_bool() raises:
    """Test creation operations with bool dtype."""
    # TODO: Implement once all creation ops support bool
    pass


# ============================================================================
# Test edge cases
# ============================================================================

fn test_creation_0d_scalar() raises:
    """Test creating 0D scalar tensor."""
    # TODO: Implement once creation ops support 0D tensors
    # let t = zeros((), DType.float32)
    # assert_equal_int(t.dim(), 0)
    # assert_equal_int(t.numel(), 1)
    pass


fn test_creation_very_large_1d() raises:
    """Test creating very large 1D tensor."""
    # TODO: Implement once creation ops are available
    # let t = zeros((1000000,), DType.float32)
    # assert_equal_int(t.numel(), 1000000)
    pass


fn test_creation_high_dimensional() raises:
    """Test creating tensor with many dimensions (e.g., 8D)."""
    # TODO: Implement once creation ops support arbitrary dimensions
    # let t = zeros((2, 2, 2, 2, 2, 2, 2, 2), DType.float32)
    # assert_equal_int(t.dim(), 8)
    # assert_equal_int(t.numel(), 256)
    pass


# ============================================================================
# Main test runner
# ============================================================================

fn main() raises:
    """Run all creation operation tests."""
    print("Running ExTensor creation operation tests...")

    # zeros() tests
    test_zeros_1d_float32()
    test_zeros_2d_int64()
    test_zeros_3d_float64()
    test_zeros_empty_shape()
    test_zeros_large_shape()

    # ones() tests
    test_ones_1d_float32()
    test_ones_2d_int32()
    test_ones_3d_float64()

    # full() tests
    test_full_positive_value()
    test_full_negative_value()
    test_full_zero_value()
    test_full_large_value()

    # empty() tests
    test_empty_allocates_memory()
    test_empty_1d()
    test_empty_2d()

    # arange() tests
    test_arange_basic()
    test_arange_step_2()
    test_arange_step_fractional()
    test_arange_reverse()
    test_arange_float()

    # from_array() tests
    test_from_array_1d()
    test_from_array_2d()
    test_from_array_3d()

    # eye() tests
    test_eye_square()
    test_eye_rectangular()
    test_eye_offset_diagonal()

    # linspace() tests
    test_linspace_basic()
    test_linspace_negative_range()
    test_linspace_small_num()
    test_linspace_large_num()

    # dtype tests
    test_creation_float16()
    test_creation_float32()
    test_creation_float64()
    test_creation_int8()
    test_creation_int32()
    test_creation_uint8()
    test_creation_bool()

    # Edge case tests
    test_creation_0d_scalar()
    test_creation_very_large_1d()
    test_creation_high_dimensional()

    print("All creation operation tests completed!")
