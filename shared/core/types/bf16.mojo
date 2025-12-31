"""BF16 (BFloat16) data type implementation.

This module implements BFloat16 format:
- 1 sign bit
- 8 exponent bits (bias = 127)
- 7 mantissa bits

BFloat16 has the same exponent range as Float32 but with reduced precision.
It is widely used for deep learning training due to its dynamic range matching Float32.
Supported range: approximately ±3.4e38 (same as Float32).

Key properties:
- Same exponent range as Float32 (no overflow issues during training)
- Less precision than Float16 (7 vs 10 mantissa bits)
- Commonly used in TPUs and modern GPU training

Example:
    ```mojo
    from shared.core.types.bf16 import BF16

    var x = BF16.from_float32(3.14159)
    var y = x.to_float32()
    ```
"""

from math import isnan, isinf


struct BF16(Copyable, Movable, Representable, Stringable):
    """16-bit brain floating point number.

    Memory layout (2 bytes):
    - Bit 15: Sign bit
    - Bits 14-7: Exponent (8 bits, bias = 127)
    - Bits 6-0: Mantissa (7 bits)

    Special values:
    - Zero: exp=0, mantissa=0
    - NaN: exp=255, mantissa!=0
    - Inf: exp=255, mantissa=0

    BFloat16 shares the same exponent range as Float32, making it ideal for
    training deep neural networks where dynamic range is more important than
    precision.
    """

    var value: UInt16

    fn __init__(out self, value: UInt16 = 0):
        """Initialize BF16 from raw UInt16 bits.

        Args:
            value: Raw 16-bit representation.
        """
        self.value = value

    @staticmethod
    fn from_float32(x: Float32) -> Self:
        """Convert Float32 to BF16 format.

        Args:
            x: Float32 value to convert.

        Returns:
            BF16 representation (with potential precision loss in mantissa).

        Note:
            Rounding is truncation (round-toward-zero).
        """
        # Handle special cases
        if isnan(x):
            # NaN: exp=255, mantissa!=0 (use 0x7FC0 for quiet NaN)
            return BF16(0x7FC0)

        if isinf(x):
            if x > 0:
                return BF16(0x7F80)  # +Inf: sign=0, exp=255, mantissa=0
            else:
                return BF16(0xFF80)  # -Inf: sign=1, exp=255, mantissa=0

        if x == 0.0:
            # Check for negative zero
            if x < 0.0 or (1.0 / x) < 0.0:
                return BF16(0x8000)  # -0
            return BF16(0)  # +0

        # Extract sign
        var sign: UInt16 = 0
        var abs_x = x
        if x < 0:
            sign = 1
            abs_x = -x

        # BF16 has the same exponent range as Float32
        # Max value: ~3.4e38, Min normal: ~1.18e-38

        # BF16 max value is approximately 3.4e38 (same as Float32)
        # Check for overflow (exp would be 255 which is Inf)
        if abs_x >= 3.4028235e38:
            # Return infinity
            return BF16((sign << 15) | 0x7F80)

        # BF16 min normal value is 2^-126 ≈ 1.18e-38
        var min_normal: Float32 = 1.1754944e-38
        if abs_x < min_normal:
            # Subnormal handling
            # Subnormal: exp=0, mantissa encodes value * 2^126 / 2^-7 = value * 2^133
            # But for BF16, subnormal min is 2^-126 * 2^-7 = 2^-133
            var min_subnormal: Float32 = min_normal / 128.0  # 2^-133
            if abs_x < min_subnormal:
                return BF16(sign << 15)  # Zero

            # Encode subnormal: mantissa = abs_x / min_normal * 128
            var mantissa = Int(abs_x / min_normal * 128.0)
            if mantissa > 127:
                mantissa = 127
            var bits = (sign << 15) | UInt16(mantissa)
            return BF16(bits)

        # Normal number encoding
        # Find exponent (log2 of abs_x)
        var exp_val = 0
        var scaled = abs_x

        # Scale to range [1, 2)
        while scaled >= 2.0:
            scaled /= 2.0
            exp_val += 1

        while scaled < 1.0:
            scaled *= 2.0
            exp_val -= 1

        # Apply bias (127 for BF16, same as Float32)
        var biased_exp = exp_val + 127

        # Clamp exponent to valid range [1, 254]
        if biased_exp <= 0:
            biased_exp = 0
            # This shouldn't happen for normal numbers after subnormal check
        elif biased_exp >= 255:
            biased_exp = 254

        # Extract mantissa (7 bits)
        # scaled is in [1, 2), we want the fractional part
        var mantissa_val = scaled - 1.0  # Now in [0, 1)
        var mantissa = Int(
            mantissa_val * 128.0
        )  # Scale to 7-bit range [0, 127]
        if mantissa > 127:
            mantissa = 127

        # Combine: sign(1) | exponent(8) | mantissa(7)
        var bits = (sign << 15) | (UInt16(biased_exp) << 7) | UInt16(mantissa)
        return BF16(bits)

    fn to_float32(self) -> Float32:
        """Convert BF16 to Float32.

        Returns:
            Float32 representation of the BF16 value.
        """
        # Extract components
        var sign = (self.value >> 15) & 0x1
        var exp = (self.value >> 7) & 0xFF  # 8 bits
        var mantissa = self.value & 0x7F  # 7 bits

        # Handle special cases
        if exp == 255:
            if mantissa != 0:
                return Float32(0.0) / Float32(0.0)  # NaN
            else:
                if sign == 1:
                    return -Float32(1.0) / Float32(0.0)  # -Inf
                else:
                    return Float32(1.0) / Float32(0.0)  # +Inf

        # Handle zero
        if exp == 0 and mantissa == 0:
            if sign == 1:
                return -0.0
            else:
                return 0.0

        # Compute value
        var result: Float32

        if exp == 0:
            # Subnormal number
            # value = (-1)^sign * 2^(-126) * (mantissa / 128)
            result = Float32(mantissa.cast[DType.float32]()) / 128.0
            # Multiply by 2^-126 using repeated division
            for _ in range(126):
                result /= 2.0
        else:
            # Normal number
            # value = (-1)^sign * 2^(exp - 127) * (1 + mantissa / 128)
            var exponent = exp.cast[DType.int32]() - 127
            var base = Float32(1.0) + (
                Float32(mantissa.cast[DType.float32]()) / 128.0
            )

            # Compute 2^exponent more efficiently
            var scale = Float32(1.0)
            if exponent > 0:
                # Use doubling for positive exponents
                var e = exponent
                var factor = Float32(2.0)
                while e > 0:
                    if e & 1:
                        scale *= factor
                    factor *= factor
                    e >>= 1
            elif exponent < 0:
                # Use halving for negative exponents
                var e = -exponent
                var factor = Float32(0.5)
                while e > 0:
                    if e & 1:
                        scale *= factor
                    factor *= factor
                    e >>= 1

            result = base * scale

        # Apply sign
        if sign == 1:
            result = -result

        return result

    fn is_nan(self) -> Bool:
        """Check if value is NaN.

        Returns:
            True if the value is NaN (exp=255, mantissa!=0).
        """
        var exp = (self.value >> 7) & 0xFF
        var mantissa = self.value & 0x7F
        return exp == 255 and mantissa != 0

    fn is_inf(self) -> Bool:
        """Check if value is infinity (positive or negative).

        Returns:
            True if the value is ±Inf (exp=255, mantissa=0).
        """
        var exp = (self.value >> 7) & 0xFF
        var mantissa = self.value & 0x7F
        return exp == 255 and mantissa == 0

    fn is_zero(self) -> Bool:
        """Check if value is zero (positive or negative).

        Returns:
            True if the value is ±0 (exp=0, mantissa=0).
        """
        # Mask out sign bit and check if rest is zero
        return (self.value & 0x7FFF) == 0

    fn is_subnormal(self) -> Bool:
        """Check if value is subnormal (denormalized).

        Returns:
            True if the value is subnormal (exp=0, mantissa!=0).
        """
        var exp = (self.value >> 7) & 0xFF
        var mantissa = self.value & 0x7F
        return exp == 0 and mantissa != 0

    fn sign(self) -> Int:
        """Get the sign of the value.

        Returns:
            1 for negative values, 0 for positive values (including +0).
        """
        return Int((self.value >> 15) & 1)

    fn __str__(self) -> String:
        """String representation showing BF16 value as Float32.

        Returns:
            String representation.
        """
        return "BF16(" + String(self.to_float32()) + ")"

    fn __repr__(self) -> String:
        """Detailed representation showing both bits and value.

        Returns:
            Detailed string representation.
        """
        return (
            "BF16(bits=0x"
            + hex(self.value)
            + ", value="
            + String(self.to_float32())
            + ")"
        )

    fn __eq__(self, other: Self) -> Bool:
        """Check equality by comparing raw bits.

        Note: This means +0 != -0 and NaN == NaN (same bit pattern).
        For IEEE-754 semantics, compare to_float32() values.

        Args:
            other: Other BF16 value.

        Returns:
            True if bit patterns match.
        """
        return self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        """Check inequality.

        Args:
            other: Other BF16 value.

        Returns:
            True if bit patterns differ.
        """
        return self.value != other.value

    fn __lt__(self, other: Self) -> Bool:
        """Less than comparison.

        Args:
            other: Other BF16 value.

        Returns:
            True if self < other (using Float32 comparison).
        """
        return self.to_float32() < other.to_float32()

    fn __le__(self, other: Self) -> Bool:
        """Less than or equal comparison.

        Args:
            other: Other BF16 value.

        Returns:
            True if self <= other (using Float32 comparison).
        """
        return self.to_float32() <= other.to_float32()

    fn __gt__(self, other: Self) -> Bool:
        """Greater than comparison.

        Args:
            other: Other BF16 value.

        Returns:
            True if self > other (using Float32 comparison).
        """
        return self.to_float32() > other.to_float32()

    fn __ge__(self, other: Self) -> Bool:
        """Greater than or equal comparison.

        Args:
            other: Other BF16 value.

        Returns:
            True if self >= other (using Float32 comparison).
        """
        return self.to_float32() >= other.to_float32()

    fn __neg__(self) -> Self:
        """Negate the value.

        Returns:
            BF16 with flipped sign bit.
        """
        return BF16(self.value ^ 0x8000)

    fn __abs__(self) -> Self:
        """Absolute value.

        Returns:
            BF16 with sign bit cleared.
        """
        return BF16(self.value & 0x7FFF)
