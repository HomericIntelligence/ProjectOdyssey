"""NVFP4 (NVIDIA FP4) blocked floating point format.

Implements NVFP4 format from the paper "Microscaling Data Formats for Deep Learning":
- Individual values: E2M1 (1 sign, 2 exponent, 1 mantissa)
- Block size: 16 elements
- Scale format: E4M3 (4-bit exponent, 3-bit mantissa)

NVFP4 provides finer-grained scaling than MXFP4 with smaller block size.
Each block of 16 FP4 values shares a common E4M3 scale factor.

According to the paper, E4M3 "achieves the best results" and provides
"modest improvements in accuracy" over E8M0, despite narrower exponent range.

Key characteristics:
- Memory: 8 bytes per block (16 × 4 bits = 64 bits) + 7 bits scale ≈ 9 bytes
- Dynamic range: Balanced (E4M3 scale)
- Precision: Limited (E2M1 values) but better than MXFP4 (smaller blocks)
- Use case: Memory-efficient ML training with better accuracy than MXFP4

Example:
    from shared.core.types.nvfp4 import NVFP4, NVFP4Block

    # Individual value (stores both E2M1 and scale for convenience)
    var val = NVFP4.from_float32(3.14159)
    var reconstructed = val.to_float32()

    # Block storage (efficient: 16 values + 1 shared scale)
    var block = NVFP4Block.from_float32_array(data_array)
"""

from math import isnan, isinf
from .fp4 import FP4_E2M1


@value
struct E4M3Scale(Stringable, Representable):
    """4-bit exponent + 3-bit mantissa scale factor for NVFP4 blocks.

    Memory layout (7 bits stored in UInt8):
    - Bits 6-3: Exponent (4 bits, bias = 7, same as FP8 E4M3)
    - Bits 2-0: Mantissa (3 bits)
    - No sign bit (always positive)

    Special values:
    - Zero: exp=0, mantissa=0
    - Max: exp=15, mantissa=7
    - No NaN/Inf (all patterns represent finite positive values)

    Valid range: Similar to FP8 E4M3 format
    """
    var value: UInt8  # Only lower 7 bits are used

    fn __init__(inout self, value: UInt8 = 0x38):
        """Initialize E4M3 scale from raw 7-bit value.

        Args:
            value: 7-bit representation (default = 0x38 = exp:7, mantissa:0 = 1.0)
        """
        self.value = value & 0x7F  # Mask to 7 bits

    @staticmethod
    fn from_float32(scale: Float32) -> Self:
        """Compute E4M3 scale from Float32 value.

        Args:
            scale: Positive Float32 scale value

        Returns:
            E4M3 representation

        Note:
            Scale must be positive. Uses FP8 E4M3 encoding logic.
        """
        if scale <= 0.0 or isnan(scale):
            return E4M3Scale(0)  # Zero scale

        if isinf(scale) or scale >= 240.0:
            return E4M3Scale(0x7F)  # Maximum scale (exp=15, mantissa=7)

        # Handle very small scales
        if scale < 0.015625:  # Below normal range
            if scale < 0.0078125:
                return E4M3Scale(0)  # Zero
            # Subnormal: exp=0, encode in mantissa
            var mantissa = int(scale * 128.0)
            if mantissa > 7:
                mantissa = 7
            return E4M3Scale(mantissa.cast[DType.uint8]())

        # Normal number encoding (same as FP8 E4M3)
        var exp_val = 0
        var scaled = scale

        # Scale to range [1, 2)
        while scaled >= 2.0:
            scaled /= 2.0
            exp_val += 1

        while scaled < 1.0:
            scaled *= 2.0
            exp_val -= 1

        # Apply bias (7 for E4M3)
        var biased_exp = exp_val + 7

        # Clamp exponent to valid range [1, 14]
        if biased_exp <= 0:
            biased_exp = 0  # Subnormal
        elif biased_exp >= 15:
            biased_exp = 14  # Avoid overflow

        # Extract mantissa (3 bits)
        var mantissa_val = scaled - 1.0  # Now in [0, 1)
        var mantissa = int(mantissa_val * 8.0)  # Scale to 3-bit range [0, 7]
        if mantissa > 7:
            mantissa = 7

        # Combine: exponent(4) | mantissa(3)
        var bits = (biased_exp.cast[DType.uint8]() << 3) | mantissa.cast[DType.uint8]()
        return E4M3Scale(bits)

    fn to_float32(self) -> Float32:
        """Convert E4M3 scale to Float32.

        Returns:
            Float32 representation
        """
        # Extract components (7 bits total)
        var exp = (self.value >> 3) & 0xF  # 4 bits
        var mantissa = self.value & 0x7    # 3 bits

        # Handle zero
        if exp == 0 and mantissa == 0:
            return 0.0

        # Compute value (same logic as FP8 E4M3)
        var result: Float32

        if exp == 0:
            # Subnormal number
            # value = 2^(-6) * (mantissa / 8)
            result = Float32(mantissa.cast[DType.float32]()) / 8.0
            result *= 0.015625  # 2^-6
        else:
            # Normal number
            # value = 2^(exp - 7) * (1 + mantissa / 8)
            var exponent = exp.cast[DType.int32]() - 7
            var base = Float32(1.0) + (Float32(mantissa.cast[DType.float32]()) / 8.0)

            # Compute 2^exponent
            var scale_factor = Float32(1.0)
            if exponent > 0:
                for _ in range(exponent):
                    scale_factor *= 2.0
            elif exponent < 0:
                for _ in range(-exponent):
                    scale_factor /= 2.0

            result = base * scale_factor

        return result

    fn __str__(self) -> String:
        """String representation showing scale value.

        Returns:
            String representation
        """
        var exp = (self.value >> 3) & 0xF
        var mantissa = self.value & 0x7
        return "E4M3(exp=" + str(exp) + ", mantissa=" + str(mantissa) + ", scale=" + str(self.to_float32()) + ")"

    fn __repr__(self) -> String:
        """Detailed representation.

        Returns:
            Detailed string representation
        """
        return self.__str__()


@value
struct NVFP4(Stringable, Representable):
    """NVFP4 individual value (E2M1 + E4M3 scale).

    Acts like FP16 but stores internally as 4-bit E2M1 value plus 7-bit E4M3 scale.
    This representation is convenient but NOT space-efficient (11 bits total vs 4 bits in blocks).

    For efficient storage, use NVFP4Block which amortizes the scale across 16 values.

    Attributes:
        value: 4-bit E2M1 encoded value
        scale: 7-bit E4M3 scale factor
    """
    var value: FP4_E2M1
    var scale: E4M3Scale

    fn __init__(inout self, value: FP4_E2M1 = FP4_E2M1(), scale: E4M3Scale = E4M3Scale()):
        """Initialize NVFP4 from E2M1 value and E4M3 scale.

        Args:
            value: E2M1 encoded value
            scale: E4M3 scale factor
        """
        self.value = value
        self.scale = scale

    @staticmethod
    fn from_float32(x: Float32) -> Self:
        """Convert Float32 to NVFP4.

        Computes optimal scale for the single value and encodes.

        Args:
            x: Float32 value to convert

        Returns:
            NVFP4 representation
        """
        # Handle special cases
        if isnan(x) or isinf(x):
            return NVFP4(FP4_E2M1.from_float32(x, scale=1.0), E4M3Scale(0x38))

        if x == 0.0:
            return NVFP4(FP4_E2M1(0), E4M3Scale(0x38))

        # Compute scale: find value such that |x| / scale is in E2M1 range [0, 6]
        var abs_x = x if x > 0 else -x
        var scale_val = Float32(1.0)
        var exp_val = 0

        # Scale to fit in E2M1 range [0, 6]
        while abs_x / scale_val > 6.0:
            scale_val *= 2.0
            exp_val += 1

        while abs_x / scale_val < 0.5 and exp_val > -7:
            scale_val /= 2.0
            exp_val -= 1

        # Create E4M3 scale
        var scale = E4M3Scale.from_float32(scale_val)

        # Encode E2M1 value
        var value = FP4_E2M1.from_float32(x, scale=scale.to_float32())

        return NVFP4(value, scale)

    fn to_float32(self) -> Float32:
        """Convert NVFP4 to Float32.

        Returns:
            Float32 representation
        """
        return self.value.to_float32(scale=self.scale.to_float32())

    fn __add__(self, other: NVFP4) -> NVFP4:
        """Add two NVFP4 values (via Float32).

        Args:
            other: Value to add

        Returns:
            Sum as NVFP4
        """
        return NVFP4.from_float32(self.to_float32() + other.to_float32())

    fn __sub__(self, other: NVFP4) -> NVFP4:
        """Subtract two NVFP4 values (via Float32).

        Args:
            other: Value to subtract

        Returns:
            Difference as NVFP4
        """
        return NVFP4.from_float32(self.to_float32() - other.to_float32())

    fn __mul__(self, other: NVFP4) -> NVFP4:
        """Multiply two NVFP4 values (via Float32).

        Args:
            other: Value to multiply

        Returns:
            Product as NVFP4
        """
        return NVFP4.from_float32(self.to_float32() * other.to_float32())

    fn __truediv__(self, other: NVFP4) -> NVFP4:
        """Divide two NVFP4 values (via Float32).

        Args:
            other: Divisor

        Returns:
            Quotient as NVFP4
        """
        return NVFP4.from_float32(self.to_float32() / other.to_float32())

    fn __neg__(self) -> NVFP4:
        """Negate NVFP4 value.

        Returns:
            Negated value
        """
        # Flip sign bit in E2M1 value
        var neg_value = FP4_E2M1(self.value.value ^ 0b1000)
        return NVFP4(neg_value, self.scale)

    fn __eq__(self, other: NVFP4) -> Bool:
        """Check equality.

        Args:
            other: Value to compare

        Returns:
            True if equal
        """
        return self.value == other.value and self.scale.value == other.scale.value

    fn __ne__(self, other: NVFP4) -> Bool:
        """Check inequality.

        Args:
            other: Value to compare

        Returns:
            True if not equal
        """
        return not (self == other)

    fn __lt__(self, other: NVFP4) -> Bool:
        """Check less than.

        Args:
            other: Value to compare

        Returns:
            True if self < other
        """
        return self.to_float32() < other.to_float32()

    fn __le__(self, other: NVFP4) -> Bool:
        """Check less than or equal.

        Args:
            other: Value to compare

        Returns:
            True if self <= other
        """
        return self.to_float32() <= other.to_float32()

    fn __gt__(self, other: NVFP4) -> Bool:
        """Check greater than.

        Args:
            other: Value to compare

        Returns:
            True if self > other
        """
        return self.to_float32() > other.to_float32()

    fn __ge__(self, other: NVFP4) -> Bool:
        """Check greater than or equal.

        Args:
            other: Value to compare

        Returns:
            True if self >= other
        """
        return self.to_float32() >= other.to_float32()

    fn __str__(self) -> String:
        """Convert to string.

        Returns:
            String representation
        """
        return "NVFP4(" + str(self.to_float32()) + ")"

    fn __repr__(self) -> String:
        """Get representation string.

        Returns:
            Representation string
        """
        return "NVFP4(value=" + repr(self.value) + ", scale=" + repr(self.scale) + ")"


# NVFP4Block will be added in future implementation for efficient block storage
# TODO: Implement NVFP4Block with 16 E2M1 values + 1 E4M3 scale (≈9 bytes total)
