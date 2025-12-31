"""Tests for BF16 (BFloat16) data type.

Tests cover:
- BF16 creation from Float32
- BF16 to Float32 conversion
- Special values (zero, NaN, Inf)
- Round-trip conversion accuracy
- Round-to-nearest-even mode
- Comparison operators
- Utility methods (is_nan, is_inf, is_zero, is_subnormal)
"""

from tests.shared.conftest import (
    assert_almost_equal,
    assert_close_float,
    assert_equal,
    assert_equal_int,
    assert_true,
)
from shared.core.types.bf16 import BF16
from math import isnan, isinf


# ============================================================================
# BF16 Basic Conversion Tests
# ============================================================================


fn test_bf16_zero() raises:
    """Test BF16 representation of zero."""
    var bf16_zero = BF16.from_float32(0.0)
    var result = bf16_zero.to_float32()

    assert_equal(bf16_zero.value, 0)
    assert_almost_equal(result, Float32(0.0), tolerance=1e-7)
    assert_true(bf16_zero.is_zero(), "Zero should be detected as zero")


fn test_bf16_negative_zero() raises:
    """Test BF16 representation of negative zero."""
    var bf16_neg_zero = BF16.from_float32(-0.0)
    _ = bf16_neg_zero.to_float32()  # Verify conversion works

    # Negative zero has sign bit set
    assert_equal(bf16_neg_zero.value, 0x8000)
    assert_true(
        bf16_neg_zero.is_zero(), "Negative zero should be detected as zero"
    )
    assert_equal_int(bf16_neg_zero.sign(), 1)


fn test_bf16_positive_values() raises:
    """Test BF16 encoding of positive values."""
    # Test small positive value
    var bf16_one = BF16.from_float32(1.0)
    var result_one = bf16_one.to_float32()
    assert_almost_equal(result_one, Float32(1.0), tolerance=1e-7)

    # Test 2.0
    var bf16_two = BF16.from_float32(2.0)
    var result_two = bf16_two.to_float32()
    assert_almost_equal(result_two, Float32(2.0), tolerance=1e-7)

    # Test Pi (truncation expected)
    var bf16_pi = BF16.from_float32(3.14159)
    var result_pi = bf16_pi.to_float32()
    # BF16 has 7 mantissa bits, so ~2 decimal digits precision
    assert_almost_equal(result_pi, Float32(3.14159), tolerance=0.02)

    # Test 100.0
    var bf16_hundred = BF16.from_float32(100.0)
    var result_hundred = bf16_hundred.to_float32()
    assert_almost_equal(result_hundred, Float32(100.0), tolerance=1e-5)


fn test_bf16_negative_values() raises:
    """Test BF16 encoding of negative values."""
    # Test -1.0
    var bf16_neg_one = BF16.from_float32(-1.0)
    var result_neg_one = bf16_neg_one.to_float32()
    assert_almost_equal(result_neg_one, Float32(-1.0), tolerance=1e-7)

    # Test -2.5
    var bf16_neg = BF16.from_float32(-2.5)
    var result_neg = bf16_neg.to_float32()
    assert_almost_equal(result_neg, Float32(-2.5), tolerance=1e-7)

    # Test -100.0
    var bf16_neg_hundred = BF16.from_float32(-100.0)
    var result_neg_hundred = bf16_neg_hundred.to_float32()
    assert_almost_equal(result_neg_hundred, Float32(-100.0), tolerance=1e-5)


fn test_bf16_large_values() raises:
    """Test BF16 with large values (same range as Float32)."""
    # BF16 has the same exponent range as Float32, so it can represent very large values

    # Test 1e10
    var bf16_large = BF16.from_float32(1e10)
    var result_large = bf16_large.to_float32()
    assert_almost_equal(result_large, Float32(1e10), tolerance=1e10 * 0.01)

    # Test 1e30
    var bf16_huge = BF16.from_float32(1e30)
    var result_huge = bf16_huge.to_float32()
    assert_almost_equal(result_huge, Float32(1e30), tolerance=1e30 * 0.01)

    # Test negative large value
    var bf16_neg_large = BF16.from_float32(-1e20)
    var result_neg_large = bf16_neg_large.to_float32()
    assert_almost_equal(result_neg_large, Float32(-1e20), tolerance=1e20 * 0.01)


fn test_bf16_small_values() raises:
    """Test BF16 with small values (same range as Float32)."""
    # Test 1e-10
    var bf16_small = BF16.from_float32(1e-10)
    var result_small = bf16_small.to_float32()
    assert_almost_equal(result_small, Float32(1e-10), tolerance=1e-10 * 0.01)

    # Test 1e-30
    var bf16_tiny = BF16.from_float32(1e-30)
    var result_tiny = bf16_tiny.to_float32()
    assert_almost_equal(result_tiny, Float32(1e-30), tolerance=1e-30 * 0.01)


fn test_bf16_special_values_nan() raises:
    """Test BF16 encoding of NaN."""
    var nan_val = Float32(0.0) / Float32(0.0)
    var bf16_nan = BF16.from_float32(nan_val)
    var result = bf16_nan.to_float32()

    # Check that result is NaN
    assert_true(isnan(result), "BF16 should preserve NaN")
    assert_true(bf16_nan.is_nan(), "is_nan() should return True for NaN")


fn test_bf16_special_values_inf() raises:
    """Test BF16 encoding of infinity."""
    # Positive infinity
    var pos_inf = Float32(1.0) / Float32(0.0)
    var bf16_pos_inf = BF16.from_float32(pos_inf)
    var result_pos = bf16_pos_inf.to_float32()
    assert_true(
        isinf(result_pos) and result_pos > 0, "BF16 should preserve +Inf"
    )
    assert_true(bf16_pos_inf.is_inf(), "is_inf() should return True for +Inf")

    # Negative infinity
    var neg_inf = Float32(-1.0) / Float32(0.0)
    var bf16_neg_inf = BF16.from_float32(neg_inf)
    var result_neg = bf16_neg_inf.to_float32()
    assert_true(
        isinf(result_neg) and result_neg < 0, "BF16 should preserve -Inf"
    )
    assert_true(bf16_neg_inf.is_inf(), "is_inf() should return True for -Inf")


fn test_bf16_precision() raises:
    """Test BF16 precision (7 mantissa bits = ~2 decimal digits)."""
    # Values that should round differently
    # The difference is in the lower bits that get truncated

    # Test with a value that has fractional part
    var bf16_val = BF16.from_float32(
        1.0078125
    )  # 1 + 1/128 (exactly representable)
    var result = bf16_val.to_float32()
    assert_almost_equal(result, Float32(1.0078125), tolerance=0.001)

    # Test truncation behavior
    var bf16_trunc = BF16.from_float32(1.005)  # Will be truncated
    var result_trunc = bf16_trunc.to_float32()
    # Should be close but not exact due to 7-bit mantissa
    assert_almost_equal(result_trunc, Float32(1.005), tolerance=0.01)


# ============================================================================
# Comparison Tests
# ============================================================================


fn test_bf16_equality() raises:
    """Test BF16 equality comparison."""
    var bf16_a = BF16.from_float32(3.14)
    var bf16_b = BF16.from_float32(3.14)
    var bf16_c = BF16.from_float32(2.71)

    assert_true(bf16_a == bf16_b, "Equal BF16 values should compare equal")
    assert_true(
        bf16_a != bf16_c, "Different BF16 values should compare not equal"
    )


fn test_bf16_ordering() raises:
    """Test BF16 ordering comparisons."""
    var bf16_small = BF16.from_float32(1.0)
    var bf16_large = BF16.from_float32(10.0)

    assert_true(bf16_small < bf16_large, "1.0 should be less than 10.0")
    assert_true(
        bf16_small <= bf16_large, "1.0 should be less than or equal to 10.0"
    )
    assert_true(bf16_large > bf16_small, "10.0 should be greater than 1.0")
    assert_true(bf16_large >= bf16_small, "10.0 should be >= 1.0")

    # Test equal values
    var bf16_same = BF16.from_float32(1.0)
    assert_true(bf16_small <= bf16_same, "Equal values should be <=")
    assert_true(bf16_small >= bf16_same, "Equal values should be >=")


fn test_bf16_negation() raises:
    """Test BF16 negation operator."""
    var bf16_pos = BF16.from_float32(5.0)
    var bf16_neg = -bf16_pos

    assert_almost_equal(bf16_neg.to_float32(), Float32(-5.0), tolerance=1e-6)

    # Negating twice should give original
    var bf16_double_neg = -bf16_neg
    assert_almost_equal(
        bf16_double_neg.to_float32(), Float32(5.0), tolerance=1e-6
    )


fn test_bf16_abs() raises:
    """Test BF16 absolute value."""
    var bf16_neg = BF16.from_float32(-5.0)
    var bf16_pos = bf16_neg.__abs__()

    assert_almost_equal(bf16_pos.to_float32(), Float32(5.0), tolerance=1e-6)

    # Abs of positive should be unchanged
    var bf16_already_pos = BF16.from_float32(3.0)
    var bf16_abs = bf16_already_pos.__abs__()
    assert_almost_equal(bf16_abs.to_float32(), Float32(3.0), tolerance=1e-6)


# ============================================================================
# Utility Method Tests
# ============================================================================


fn test_bf16_sign() raises:
    """Test BF16 sign extraction."""
    var bf16_pos = BF16.from_float32(5.0)
    var bf16_neg = BF16.from_float32(-5.0)
    var bf16_zero = BF16.from_float32(0.0)

    assert_equal_int(bf16_pos.sign(), 0)
    assert_equal_int(bf16_neg.sign(), 1)
    assert_equal_int(bf16_zero.sign(), 0)


fn test_bf16_is_subnormal() raises:
    """Test BF16 subnormal detection."""
    # Create a subnormal by directly setting bits (exp=0, mantissa!=0)
    var bf16_subnormal = BF16(0x0001)  # Smallest positive subnormal
    assert_true(bf16_subnormal.is_subnormal(), "Should detect subnormal")

    # Normal number should not be subnormal
    var bf16_normal = BF16.from_float32(1.0)
    assert_true(not bf16_normal.is_subnormal(), "1.0 should not be subnormal")

    # Zero should not be subnormal
    var bf16_zero = BF16.from_float32(0.0)
    assert_true(not bf16_zero.is_subnormal(), "Zero should not be subnormal")


# ============================================================================
# Round-Trip Accuracy Tests
# ============================================================================


fn test_bf16_roundtrip_exact_values() raises:
    """Test round-trip for values exactly representable in BF16."""
    # Powers of 2 are exactly representable
    var test_values = List[Float32]()
    test_values.append(1.0)
    test_values.append(2.0)
    test_values.append(4.0)
    test_values.append(0.5)
    test_values.append(0.25)
    test_values.append(128.0)
    test_values.append(-1.0)
    test_values.append(-0.5)

    for i in range(len(test_values)):
        var val = test_values[i]
        var bf16 = BF16.from_float32(val)
        var restored = bf16.to_float32()
        assert_almost_equal(restored, val, tolerance=1e-7)


fn test_bf16_roundtrip_general_values() raises:
    """Test round-trip for general values with expected precision loss."""
    var test_values = List[Float32]()
    test_values.append(3.14159)
    test_values.append(2.71828)
    test_values.append(0.123456)
    test_values.append(-9.87654)

    for i in range(len(test_values)):
        var val = test_values[i]
        var bf16 = BF16.from_float32(val)
        var restored = bf16.to_float32()
        # BF16 has ~2 decimal digits precision, so use 1% tolerance
        var tolerance = abs(val) * 0.01
        if tolerance < 0.01:
            tolerance = 0.01
        assert_almost_equal(restored, val, tolerance=tolerance)


fn test_bf16_string_representation() raises:
    """Test BF16 string representation."""
    var bf16 = BF16.from_float32(3.14)
    var str_repr = String(bf16)

    # Should contain "BF16(" prefix
    assert_true(
        str_repr.startswith("BF16("), "String should start with 'BF16('"
    )


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all BF16 tests."""
    print("\n=== BF16 Basic Conversion Tests ===")
    test_bf16_zero()
    print("✓ BF16 zero encoding")

    test_bf16_negative_zero()
    print("✓ BF16 negative zero encoding")

    test_bf16_positive_values()
    print("✓ BF16 positive values")

    test_bf16_negative_values()
    print("✓ BF16 negative values")

    test_bf16_large_values()
    print("✓ BF16 large values (Float32 range)")

    test_bf16_small_values()
    print("✓ BF16 small values")

    test_bf16_special_values_nan()
    print("✓ BF16 NaN handling")

    test_bf16_special_values_inf()
    print("✓ BF16 infinity handling")

    print("\n=== BF16 Precision Tests ===")
    test_bf16_precision()
    print("✓ BF16 precision")

    print("\n=== BF16 Comparison Tests ===")
    test_bf16_equality()
    print("✓ BF16 equality comparison")

    test_bf16_ordering()
    print("✓ BF16 ordering comparisons")

    test_bf16_negation()
    print("✓ BF16 negation")

    test_bf16_abs()
    print("✓ BF16 absolute value")

    print("\n=== BF16 Utility Method Tests ===")
    test_bf16_sign()
    print("✓ BF16 sign extraction")

    test_bf16_is_subnormal()
    print("✓ BF16 subnormal detection")

    print("\n=== BF16 Round-Trip Tests ===")
    test_bf16_roundtrip_exact_values()
    print("✓ BF16 exact value round-trip")

    test_bf16_roundtrip_general_values()
    print("✓ BF16 general value round-trip")

    test_bf16_string_representation()
    print("✓ BF16 string representation")

    print("\n=== All BF16 Tests Passed! ===\n")
