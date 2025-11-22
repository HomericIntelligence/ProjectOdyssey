"""Test conv2d forward pass to isolate the segfault."""

from shared.core import ExTensor, zeros
from shared.core.conv import conv2d
from shared.core.initializers import kaiming_uniform
from collections import List


fn test_conv2d_forward() raises:
    """Test single conv2d forward pass."""
    print("Test: Single conv2d forward pass...")

    # Create input: (batch=1, channels=1, height=28, width=28)
    var input_shape = List[Int]()
    input_shape.append(1)
    input_shape.append(1)
    input_shape.append(28)
    input_shape.append(28)
    var input = zeros(input_shape, DType.float32)
    print("  Input created: numel=", input.numel())

    # Create kernel: (out_channels=6, in_channels=1, kH=5, kW=5)
    var kernel_shape = List[Int]()
    kernel_shape.append(6)   # out_channels
    kernel_shape.append(1)   # in_channels
    kernel_shape.append(5)   # kH
    kernel_shape.append(5)   # kW
    var fan_in = 1 * 5 * 5  # in_channels * kH * kW
    var fan_out = 6 * 5 * 5  # out_channels * kH * kW
    var kernel = kaiming_uniform(fan_in, fan_out, kernel_shape, dtype=DType.float32)
    print("  Kernel created: numel=", kernel.numel())

    # Create bias: (out_channels=6)
    var bias_shape = List[Int]()
    bias_shape.append(6)
    var bias = zeros(bias_shape, DType.float32)
    print("  Bias created: numel=", bias.numel())

    # Forward pass
    print("  Running conv2d...")
    var output = conv2d(input, kernel, bias, stride=1, padding=0)
    print("  Output numel:", output.numel())
    print("  Expected output shape: (1, 6, 24, 24) = 3456 elements")

    print("  ✓ Test passed!")


fn test_conv2d_multiple() raises:
    """Test multiple conv2d forward passes (simulating training loop)."""
    print("\nTest: Multiple conv2d forward passes...")

    for i in range(3):
        print("  Iteration", i + 1)

        # Create input
        var input_shape = List[Int]()
        input_shape.append(1)
        input_shape.append(1)
        input_shape.append(28)
        input_shape.append(28)
        var input = zeros(input_shape, DType.float32)

        # Create kernel
        var kernel_shape = List[Int]()
        kernel_shape.append(6)
        kernel_shape.append(1)
        kernel_shape.append(5)
        kernel_shape.append(5)
        var fan_in = 1 * 5 * 5
        var fan_out = 6 * 5 * 5
        var kernel = kaiming_uniform(fan_in, fan_out, kernel_shape, dtype=DType.float32)

        # Create bias
        var bias_shape = List[Int]()
        bias_shape.append(6)
        var bias = zeros(bias_shape, DType.float32)

        # Forward pass
        var output = conv2d(input, kernel, bias, stride=1, padding=0)
        print("    Output numel:", output.numel())

    print("  ✓ Test passed!")


fn main() raises:
    print("=" * 60)
    print("Conv2d Forward Pass Tests")
    print("=" * 60)
    print()

    test_conv2d_forward()
    test_conv2d_multiple()

    print()
    print("=" * 60)
    print("All tests passed! 🎉")
    print("=" * 60)
