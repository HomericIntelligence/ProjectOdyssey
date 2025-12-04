"""Tests for ExTensor core properties and functionality.

Tests fundamental ExTensor properties including shape, dtype, numel, strides,
contiguity, and basic tensor operations that should work with current implementation.
"""

# Import ExTensor and operations
from shared.core import ExTensor, zeros, ones, full, arange, eye
from shared.core.extensor import zeros_like, ones_like, full_like, linspace

# Import test helpers
from tests.shared.conftest import (
    assert_true,
    assert_false,
    assert_dtype,
    assert_numel,
    assert_dim,
    assert_equal_int,
    assert_value_at,
)

# Import tensor assertions from shared testing fixtures
from shared.testing.fixtures import (
    assert_tensor_shape,
    assert_tensor_dtype,
    assert_tensor_all_finite,
    assert_tensor_not_all_zeros,
)


# ============================================================================
# Test shape property
# ============================================================================

fn test_shape_1d() raises:
    """Test shape property for 1D tensor."""
    var shape = List[Int]()
    shape.append(10)
    var t = ones(shape, DType.float32)

    var s = t.shape()
    assert_equal_int(len(s), 1, "1D tensor should have 1 dimension in shape")
    assert_equal_int(s[0], 10, "First dimension should be 10")


fn test_shape_2d() raises:
    """Test shape property for 2D tensor."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    var s = t.shape()
    assert_equal_int(len(s), 2, "2D tensor should have 2 dimensions")
    assert_equal_int(s[0], 3, "First dimension should be 3")
    assert_equal_int(s[1], 4, "Second dimension should be 4")


fn test_shape_3d() raises:
    """Test shape property for 3D tensor."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    var s = t.shape()
    assert_equal_int(len(s), 3, "3D tensor should have 3 dimensions")
    assert_equal_int(s[0], 2, "Dim 0 should be 2")
    assert_equal_int(s[1], 3, "Dim 1 should be 3")
    assert_equal_int(s[2], 4, "Dim 2 should be 4")


fn test_shape_scalar() raises:
    """Test shape property for scalar (0D) tensor."""
    var shape = List[Int]()
    var t = full(shape, 42.0, DType.float32)

    var s = t.shape()
    assert_equal_int(len(s), 0, "Scalar tensor should have 0 dimensions")


# ============================================================================
# Test dtype property
# ============================================================================

fn test_dtype_float32() raises:
    """Test dtype property for float32 tensor."""
    var shape = List[Int]()
    shape.append(5)
    var t = ones(shape, DType.float32)

    assert_dtype(t, DType.float32, "Should be float32")


fn test_dtype_float64() raises:
    """Test dtype property for float64 tensor."""
    var shape = List[Int]()
    shape.append(5)
    var t = ones(shape, DType.float64)

    assert_dtype(t, DType.float64, "Should be float64")


fn test_dtype_int32() raises:
    """Test dtype property for int32 tensor."""
    var shape = List[Int]()
    shape.append(5)
    var t = zeros(shape, DType.int32)

    assert_dtype(t, DType.int32, "Should be int32")


fn test_dtype_int64() raises:
    """Test dtype property for int64 tensor."""
    var shape = List[Int]()
    shape.append(5)
    var t = zeros(shape, DType.int64)

    assert_dtype(t, DType.int64, "Should be int64")


fn test_dtype_bool() raises:
    """Test dtype property for bool tensor."""
    var shape = List[Int]()
    shape.append(5)
    var t = zeros(shape, DType.bool)

    assert_dtype(t, DType.bool, "Should be bool")


# ============================================================================
# Test numel property
# ============================================================================

fn test_numel_1d() raises:
    """Test numel for 1D tensor."""
    var shape = List[Int]()
    shape.append(10)
    var t = ones(shape, DType.float32)

    assert_numel(t, 10, "1D tensor with 10 elements")


fn test_numel_2d() raises:
    """Test numel for 2D tensor."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_numel(t, 12, "2D tensor with 12 elements (3*4)")


fn test_numel_3d() raises:
    """Test numel for 3D tensor."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_numel(t, 24, "3D tensor with 24 elements (2*3*4)")


fn test_numel_scalar() raises:
    """Test numel for scalar tensor."""
    var shape = List[Int]()
    var t = full(shape, 1.0, DType.float32)

    assert_numel(t, 1, "Scalar tensor has 1 element")


fn test_numel_empty() raises:
    """Test numel for empty tensor."""
    var shape = List[Int]()
    shape.append(0)
    var t = zeros(shape, DType.float32)

    assert_numel(t, 0, "Empty tensor has 0 elements")


# ============================================================================
# Test stride calculations
# ============================================================================

fn test_strides_1d() raises:
    """Test stride calculation for 1D tensor."""
    var shape = List[Int]()
    shape.append(10)
    var t = ones(shape, DType.float32)

    var strides = List[Int](t._strides)
    assert_equal_int(len(strides), 1, "1D tensor should have 1 stride")
    assert_equal_int(strides[0], 1, "1D stride should be 1")


fn test_strides_2d_row_major() raises:
    """Test stride calculation for 2D tensor (row-major)."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    var strides = List[Int](t._strides)
    assert_equal_int(len(strides), 2, "2D tensor should have 2 strides")
    assert_equal_int(strides[0], 4, "Outer stride should be 4 (row length)")
    assert_equal_int(strides[1], 1, "Inner stride should be 1")


fn test_strides_3d_row_major() raises:
    """Test stride calculation for 3D tensor (row-major)."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    var strides = List[Int](t._strides)
    assert_equal_int(len(strides), 3, "3D tensor should have 3 strides")
    assert_equal_int(strides[0], 12, "Stride 0 should be 12 (3*4)")
    assert_equal_int(strides[1], 4, "Stride 1 should be 4")
    assert_equal_int(strides[2], 1, "Stride 2 should be 1")


# ============================================================================
# Test contiguity
# ============================================================================

fn test_contiguous_new_tensor() raises:
    """Test that newly created tensors are contiguous."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_true(t.is_contiguous(), "Newly created tensor should be contiguous")


fn test_contiguous_1d() raises:
    """Test that 1D tensors are contiguous."""
    var shape = List[Int]()
    shape.append(100)
    var t = arange(0.0, 100.0, 1.0, DType.float32)

    assert_true(t.is_contiguous(), "1D tensor should be contiguous")


fn test_contiguous_scalar() raises:
    """Test that scalar tensors are contiguous."""
    var shape = List[Int]()
    var t = full(shape, 5.0, DType.float32)

    assert_true(t.is_contiguous(), "Scalar tensor should be contiguous")


# ============================================================================
# Test dimension queries
# ============================================================================

fn test_dim_1d() raises:
    """Test dim for 1D tensor."""
    var shape = List[Int]()
    shape.append(10)
    var t = ones(shape, DType.float32)

    assert_dim(t, 1, "1D tensor should have dim=1")


fn test_dim_2d() raises:
    """Test dim for 2D tensor."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_dim(t, 2, "2D tensor should have dim=2")


fn test_dim_3d() raises:
    """Test dim for 3D tensor."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_dim(t, 3, "3D tensor should have dim=3")


fn test_dim_scalar() raises:
    """Test dim for scalar (0D) tensor."""
    var shape = List[Int]()
    var t = full(shape, 1.0, DType.float32)

    assert_dim(t, 0, "Scalar tensor should have dim=0")


# ============================================================================
# Test value access patterns
# ============================================================================

fn test_value_access_1d() raises:
    """Test accessing values in 1D tensor."""
    var t = arange(0.0, 5.0, 1.0, DType.float32)

    assert_value_at(t, 0, 0.0, 1e-6, "First element")
    assert_value_at(t, 2, 2.0, 1e-6, "Middle element")
    assert_value_at(t, 4, 4.0, 1e-6, "Last element")


fn test_value_access_2d_row_major() raises:
    """Test accessing values in 2D tensor (row-major order)."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    var t = arange(0.0, 6.0, 1.0, DType.float32)
    # Should be: [[0, 1, 2], [3, 4, 5]]

    assert_value_at(t, 0, 0.0, 1e-6, "Element [0,0]")
    assert_value_at(t, 2, 2.0, 1e-6, "Element [0,2]")
    assert_value_at(t, 3, 3.0, 1e-6, "Element [1,0]")
    assert_value_at(t, 5, 5.0, 1e-6, "Element [1,2]")


fn test_value_access_identity() raises:
    """Test accessing values in identity matrix."""
    var t = eye(3, 3, 0, DType.float32)

    # Diagonal elements should be 1.0
    assert_value_at(t, 0, 1.0, 1e-6, "Diagonal [0,0]")
    assert_value_at(t, 4, 1.0, 1e-6, "Diagonal [1,1]")
    assert_value_at(t, 8, 1.0, 1e-6, "Diagonal [2,2]")

    # Off-diagonal should be 0.0
    assert_value_at(t, 1, 0.0, 1e-6, "Off-diagonal [0,1]")
    assert_value_at(t, 3, 0.0, 1e-6, "Off-diagonal [1,0]")


# ============================================================================
# Test special tensor creation patterns
# ============================================================================

fn test_all_zeros_pattern() raises:
    """Test that zeros creates all zero values."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(3)
    var t = zeros(shape, DType.float32)

    for i in range(9):
        assert_value_at(t, i, 0.0, 1e-8, "All elements should be 0")


fn test_all_ones_pattern() raises:
    """Test that ones creates all one values."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(3)
    var t = ones(shape, DType.float32)

    for i in range(9):
        assert_value_at(t, i, 1.0, 1e-8, "All elements should be 1")


fn test_full_pattern() raises:
    """Test that full creates uniform values."""
    var shape = List[Int]()
    shape.append(2)
    shape.append(4)
    var t = full(shape, 7.5, DType.float32)

    for i in range(8):
        assert_value_at(t, i, 7.5, 1e-6, "All elements should be 7.5")


fn test_arange_sequential_pattern() raises:
    """Test that arange creates sequential values."""
    var t = arange(0.0, 10.0, 1.0, DType.float32)

    for i in range(10):
        assert_value_at(t, i, Float64(i), 1e-6, "Sequential values")


fn test_eye_identity_pattern() raises:
    """Test that eye creates proper identity pattern."""
    var t = eye(4, 4, 0, DType.float32)

    for i in range(4):
        for j in range(4):
            var idx = i * 4 + j
            if i == j:
                assert_value_at(t, idx, 1.0, 1e-6, "Diagonal should be 1")
            else:
                assert_value_at(t, idx, 0.0, 1e-6, "Off-diagonal should be 0")


# ============================================================================
# Test is_view property
# ============================================================================

fn test_is_view_false_for_new_tensors() raises:
    """Test that newly created tensors are not views."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)
    var t = ones(shape, DType.float32)

    assert_false(t._is_view, "Newly created tensor should not be a view")


# ============================================================================
# Test dtype size calculations
# ============================================================================

fn test_dtype_size_float32() raises:
    """Test dtype size for float32."""
    var shape = List[Int]()
    shape.append(1)
    var t = ones(shape, DType.float32)

    var size = t._get_dtype_size()
    assert_equal_int(size, 4, "float32 should be 4 bytes")


fn test_dtype_size_float64() raises:
    """Test dtype size for float64."""
    var shape = List[Int]()
    shape.append(1)
    var t = ones(shape, DType.float64)

    var size = t._get_dtype_size()
    assert_equal_int(size, 8, "float64 should be 8 bytes")


fn test_dtype_size_int32() raises:
    """Test dtype size for int32."""
    var shape = List[Int]()
    shape.append(1)
    var t = zeros(shape, DType.int32)

    var size = t._get_dtype_size()
    assert_equal_int(size, 4, "int32 should be 4 bytes")


# ============================================================================
# Test consolidated assertions from shared/testing/fixtures
# ============================================================================


fn test_properties_with_assert_tensor_shape() raises:
    """Test shape property validation with consolidated assertion."""
    var shape = List[Int]()
    shape.append(5)
    shape.append(6)
    var t = ones(shape, DType.float32)

    # Use consolidated assertion to validate shape
    var expected_shape = List[Int]()
    expected_shape.append(5)
    expected_shape.append(6)
    assert_true(assert_tensor_shape(t, expected_shape), "Shape should be (5, 6)")

    # Verify shape() method returns same result
    var shape_result = t.shape()
    assert_equal_int(shape_result[0], 5, "Shape[0] should be 5")
    assert_equal_int(shape_result[1], 6, "Shape[1] should be 6")


fn test_properties_with_assert_tensor_dtype() raises:
    """Test dtype property validation with consolidated assertion."""
    var shape = List[Int]()
    shape.append(4)
    var t_float32 = ones(shape, DType.float32)
    var t_float64 = zeros(shape, DType.float64)
    var t_int32 = zeros(shape, DType.int32)

    # Use consolidated assertions for dtype validation
    assert_true(assert_tensor_dtype(t_float32, DType.float32), "Should be float32")
    assert_true(assert_tensor_dtype(t_float64, DType.float64), "Should be float64")
    assert_true(assert_tensor_dtype(t_int32, DType.int32), "Should be int32")

    # Cross-validate with method
    assert_dtype(t_float32, DType.float32, "Method should confirm float32")
    assert_dtype(t_float64, DType.float64, "Method should confirm float64")


fn test_properties_validate_created_tensors() raises:
    """Test that created tensors are finite and properly initialized."""
    var shape = List[Int]()
    shape.append(3)
    shape.append(4)

    # Create tensors with different methods
    var t_zeros = zeros(shape, DType.float32)
    var t_ones = ones(shape, DType.float32)
    var t_full = full(shape, 2.5, DType.float32)

    # Verify all are finite
    assert_true(assert_tensor_all_finite(t_zeros), "Zeros should be finite")
    assert_true(assert_tensor_all_finite(t_ones), "Ones should be finite")
    assert_true(assert_tensor_all_finite(t_full), "Full should be finite")

    # Verify zero/non-zero content
    assert_true(not assert_tensor_not_all_zeros(t_zeros), "Zeros should be all zeros")
    assert_true(assert_tensor_not_all_zeros(t_ones), "Ones should not be all zeros")
    assert_true(assert_tensor_not_all_zeros(t_full), "Full(2.5) should not be all zeros")


fn test_arange_tensor_validation() raises:
    """Test arange tensor with consolidated assertions."""
    var t = arange(0.0, 5.0, 1.0, DType.float32)

    # Validate shape
    var expected_shape = List[Int]()
    expected_shape.append(5)
    assert_true(assert_tensor_shape(t, expected_shape), "arange should produce shape (5,)")

    # Validate dtype
    assert_true(assert_tensor_dtype(t, DType.float32), "arange should produce float32")

    # Validate all finite
    assert_true(assert_tensor_all_finite(t), "arange values should be finite")

    # Validate not all zeros
    assert_true(assert_tensor_not_all_zeros(t), "arange [0,1,2,3,4] should not be all zeros")


fn test_eye_tensor_validation() raises:
    """Test eye (identity) tensor with consolidated assertions."""
    var t = eye(3, 3, 0, DType.float64)

    # Validate shape
    var expected_shape = List[Int]()
    expected_shape.append(3)
    expected_shape.append(3)
    assert_true(assert_tensor_shape(t, expected_shape), "eye(3,3) should be 3x3")

    # Validate dtype
    assert_true(assert_tensor_dtype(t, DType.float64), "eye should preserve dtype")

    # Validate finiteness
    assert_true(assert_tensor_all_finite(t), "eye matrix should be finite")

    # Validate not all zeros (due to diagonal)
    assert_true(assert_tensor_not_all_zeros(t), "Identity matrix has non-zero diagonal")


fn test_dtype_consistency_with_consolidated_assertions() raises:
    """Test dtype consistency across shape transformations."""
    var shape_2d = List[Int]()
    shape_2d.append(4)
    shape_2d.append(4)
    var original = full(shape_2d, 1.0, DType.float64)

    # Verify original is correct dtype
    assert_true(assert_tensor_dtype(original, DType.float64), "Original should be float64")

    # Create related tensors
    var t_zeros_like = zeros_like(original)
    var t_ones_like = ones_like(original)

    # All should maintain dtype
    assert_true(assert_tensor_dtype(t_zeros_like, DType.float64), "zeros_like should preserve dtype")
    assert_true(assert_tensor_dtype(t_ones_like, DType.float64), "ones_like should preserve dtype")

    # Shapes should also be preserved
    var expected_shape = List[Int]()
    expected_shape.append(4)
    expected_shape.append(4)
    assert_true(assert_tensor_shape(t_zeros_like, expected_shape), "zeros_like should preserve shape")
    assert_true(assert_tensor_shape(t_ones_like, expected_shape), "ones_like should preserve shape")


# ============================================================================
# Main test runner
# ============================================================================

fn main() raises:
    """Run all property and core functionality tests."""
    print("Running ExTensor property and core functionality tests...")

    # Shape property tests
    print("  Testing shape property...")
    test_shape_1d()
    test_shape_2d()
    test_shape_3d()
    test_shape_scalar()

    # DType property tests
    print("  Testing dtype property...")
    test_dtype_float32()
    test_dtype_float64()
    test_dtype_int32()
    test_dtype_int64()
    test_dtype_bool()

    # Numel property tests
    print("  Testing numel property...")
    test_numel_1d()
    test_numel_2d()
    test_numel_3d()
    test_numel_scalar()
    test_numel_empty()

    # Stride tests
    print("  Testing stride calculations...")
    test_strides_1d()
    test_strides_2d_row_major()
    test_strides_3d_row_major()

    # Contiguity tests
    print("  Testing contiguity...")
    test_contiguous_new_tensor()
    test_contiguous_1d()
    test_contiguous_scalar()

    # Dimension tests
    print("  Testing dimension queries...")
    test_dim_1d()
    test_dim_2d()
    test_dim_3d()
    test_dim_scalar()

    # Value access tests
    print("  Testing value access patterns...")
    test_value_access_1d()
    test_value_access_2d_row_major()
    test_value_access_identity()

    # Pattern tests
    print("  Testing creation patterns...")
    test_all_zeros_pattern()
    test_all_ones_pattern()
    test_full_pattern()
    test_arange_sequential_pattern()
    test_eye_identity_pattern()

    # View property tests
    print("  Testing is_view property...")
    test_is_view_false_for_new_tensors()

    # DType size tests
    print("  Testing dtype size calculations...")
    test_dtype_size_float32()
    test_dtype_size_float64()
    test_dtype_size_int32()

    # Consolidated assertion tests
    print("  Testing consolidated assertions from shared/testing/fixtures...")
    test_properties_with_assert_tensor_shape()
    test_properties_with_assert_tensor_dtype()
    test_properties_validate_created_tensors()
    test_arange_tensor_validation()
    test_eye_tensor_validation()
    test_dtype_consistency_with_consolidated_assertions()

    print("All property and core functionality tests completed!")
