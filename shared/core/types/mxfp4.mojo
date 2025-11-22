"""MXFP4 (Microscaling FP4) blocked floating point format.

Implements MXFP4 format from the paper "Microscaling Data Formats for Deep Learning":
- Individual values: E2M1 (1 sign, 2 exponent, 1 mantissa)
- Block size: 32 elements
- Scale format: E8M0 (8-bit exponent-only, no mantissa or sign)

MXFP4 provides wide dynamic range through exponent-only scaling.
Each block of 32 FP4 values shares a common E8M0 scale factor.

Key characteristics:
- Memory: 16 bytes per block (32 × 4 bits = 128 bits) + 1 byte scale = 17 bytes
- Dynamic range: Wide (E8M0 scale)
- Precision: Limited (E2M1 values)
- Use case: Memory-efficient ML training and inference

Example:
    from shared.core.types.mxfp4 import MXFP4, MXFP4Block

    # Individual value (stores both E2M1 and scale for convenience)
    var val = MXFP4.from_float32(3.14159)
    var reconstructed = val.to_float32()

    # Block storage (efficient: 32 values + 1 shared scale)
    var block = MXFP4Block.from_float32_array(data_array)
"""

from math import isnan, isinf
from .fp4 import FP4_E2M1


@value
struct E8M0Scale(Stringable, Representable):
    """8-bit exponent-only scale factor for MXFP4 blocks.

    Memory layout (1 byte):
    - Bits 7-0: Exponent (8 bits, bias = 127, same as Float32)
    - No sign bit (always positive)
    - No mantissa bits (implicit mantissa = 1.0)

    Represents: 2^(exponent - 127)

    Valid range: 2^-127 to 2^128
    """
    var exponent: UInt8

    fn __init__(inout self, exponent: UInt8 = 127):
        """Initialize E8M0 scale from raw exponent.

        Args:
            exponent: 8-bit exponent value (bias = 127)
        """
        self.exponent = exponent

    @staticmethod
    fn from_float32(scale: Float32) -> Self:
        """Compute E8M0 scale from Float32 value.

        Args:
            scale: Positive Float32 scale value

        Returns:
            E8M0 representation

        Note:
            Scale must be positive. Negative or zero values return minimum scale.
        """
        if scale <= 0.0 or isnan(scale):
            return E8M0Scale(0)  # Minimum scale (2^-127)

        if isinf(scale):
            return E8M0Scale(255)  # Maximum scale (2^128)

        # Find exponent: scale = 2^exp
        var exp_val = 0
        var s = scale

        # Scale to find the exponent
        while s >= 2.0 and exp_val < 128:
            s /= 2.0
            exp_val += 1

        while s < 1.0 and exp_val > -127:
            s *= 2.0
            exp_val -= 1

        # Apply bias (127)
        var biased_exp = exp_val + 127

        # Clamp to [0, 255]
        if biased_exp < 0:
            biased_exp = 0
        elif biased_exp > 255:
            biased_exp = 255

        return E8M0Scale(biased_exp.cast[DType.uint8]())

    fn to_float32(self) -> Float32:
        """Convert E8M0 scale to Float32.

        Returns:
            Float32 representation: 2^(exponent - 127)
        """
        var exponent = self.exponent.cast[DType.int32]() - 127

        # Compute 2^exponent
        var result = Float32(1.0)
        if exponent > 0:
            for _ in range(exponent):
                result *= 2.0
        elif exponent < 0:
            for _ in range(-exponent):
                result /= 2.0

        return result

    fn __str__(self) -> String:
        """String representation showing scale value.

        Returns:
            String representation
        """
        return "E8M0(exp=" + str(self.exponent) + ", scale=" + str(self.to_float32()) + ")"

    fn __repr__(self) -> String:
        """Detailed representation.

        Returns:
            Detailed string representation
        """
        return self.__str__()


@value
struct MXFP4(Stringable, Representable):
    """MXFP4 individual value (E2M1 + E8M0 scale).

    Acts like FP16 but stores internally as 4-bit E2M1 value plus 8-bit E8M0 scale.
    This representation is convenient but NOT space-efficient (12 bits total vs 4 bits in blocks).

    For efficient storage, use MXFP4Block which amortizes the scale across 32 values.

    Attributes:
        value: 4-bit E2M1 encoded value
        scale: 8-bit E8M0 scale factor
    """
    var value: FP4_E2M1
    var scale: E8M0Scale

    fn __init__(inout self, value: FP4_E2M1 = FP4_E2M1(), scale: E8M0Scale = E8M0Scale()):
        """Initialize MXFP4 from E2M1 value and E8M0 scale.

        Args:
            value: E2M1 encoded value
            scale: E8M0 scale factor
        """
        self.value = value
        self.scale = scale

    @staticmethod
    fn from_float32(x: Float32) -> Self:
        """Convert Float32 to MXFP4.

        Computes optimal scale for the single value and encodes.

        Args:
            x: Float32 value to convert

        Returns:
            MXFP4 representation
        """
        # Handle special cases
        if isnan(x) or isinf(x):
            return MXFP4(FP4_E2M1.from_float32(x, scale=1.0), E8M0Scale(127))

        if x == 0.0:
            return MXFP4(FP4_E2M1(0), E8M0Scale(127))

        # Compute scale: find 2^k such that |x| / 2^k is in E2M1 range [0, 6]
        var abs_x = x if x > 0 else -x
        var scale_val = Float32(1.0)
        var exp_val = 0

        # Scale to fit in E2M1 range [0, 6]
        while abs_x / scale_val > 6.0:
            scale_val *= 2.0
            exp_val += 1

        while abs_x / scale_val < 0.5 and exp_val > -127:
            scale_val /= 2.0
            exp_val -= 1

        # Create E8M0 scale
        var scale = E8M0Scale.from_float32(scale_val)

        # Encode E2M1 value
        var value = FP4_E2M1.from_float32(x, scale=scale.to_float32())

        return MXFP4(value, scale)

    fn to_float32(self) -> Float32:
        """Convert MXFP4 to Float32.

        Returns:
            Float32 representation
        """
        return self.value.to_float32(scale=self.scale.to_float32())

    fn __add__(self, other: MXFP4) -> MXFP4:
        """Add two MXFP4 values (via Float32).

        Args:
            other: Value to add

        Returns:
            Sum as MXFP4
        """
        return MXFP4.from_float32(self.to_float32() + other.to_float32())

    fn __sub__(self, other: MXFP4) -> MXFP4:
        """Subtract two MXFP4 values (via Float32).

        Args:
            other: Value to subtract

        Returns:
            Difference as MXFP4
        """
        return MXFP4.from_float32(self.to_float32() - other.to_float32())

    fn __mul__(self, other: MXFP4) -> MXFP4:
        """Multiply two MXFP4 values (via Float32).

        Args:
            other: Value to multiply

        Returns:
            Product as MXFP4
        """
        return MXFP4.from_float32(self.to_float32() * other.to_float32())

    fn __truediv__(self, other: MXFP4) -> MXFP4:
        """Divide two MXFP4 values (via Float32).

        Args:
            other: Divisor

        Returns:
            Quotient as MXFP4
        """
        return MXFP4.from_float32(self.to_float32() / other.to_float32())

    fn __neg__(self) -> MXFP4:
        """Negate MXFP4 value.

        Returns:
            Negated value
        """
        # Flip sign bit in E2M1 value
        var neg_value = FP4_E2M1(self.value.value ^ 0b1000)
        return MXFP4(neg_value, self.scale)

    fn __eq__(self, other: MXFP4) -> Bool:
        """Check equality.

        Args:
            other: Value to compare

        Returns:
            True if equal
        """
        return self.value == other.value and self.scale.exponent == other.scale.exponent

    fn __ne__(self, other: MXFP4) -> Bool:
        """Check inequality.

        Args:
            other: Value to compare

        Returns:
            True if not equal
        """
        return not (self == other)

    fn __lt__(self, other: MXFP4) -> Bool:
        """Check less than.

        Args:
            other: Value to compare

        Returns:
            True if self < other
        """
        return self.to_float32() < other.to_float32()

    fn __le__(self, other: MXFP4) -> Bool:
        """Check less than or equal.

        Args:
            other: Value to compare

        Returns:
            True if self <= other
        """
        return self.to_float32() <= other.to_float32()

    fn __gt__(self, other: MXFP4) -> Bool:
        """Check greater than.

        Args:
            other: Value to compare

        Returns:
            True if self > other
        """
        return self.to_float32() > other.to_float32()

    fn __ge__(self, other: MXFP4) -> Bool:
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
        return "MXFP4(" + str(self.to_float32()) + ")"

    fn __repr__(self) -> String:
        """Get representation string.

        Returns:
            Representation string
        """
        return "MXFP4(value=" + repr(self.value) + ", scale=" + repr(self.scale) + ")"


# MXFP4Block will be added in future implementation for efficient block storage
# TODO: Implement MXFP4Block with 32 E2M1 values + 1 E8M0 scale (17 bytes total)
