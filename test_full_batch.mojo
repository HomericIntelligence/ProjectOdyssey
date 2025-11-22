"""Test with full batch size to reproduce the crash."""

from shared.core import ExTensor, zeros
from shared.core.conv import conv2d
from shared.core.pooling import maxpool2d
from shared.core.activation import relu
from shared.core.initializers import kaiming_uniform
from collections import List


fn test_full_batch_forward() raises:
    """Test with the full training batch size."""
    print("Test: Full batch size (112800 samples)...")
    print("  This may take a while and use significant memory...")

    # Create input: (batch=112800, channels=1, height=28, width=28)
    var input_shape = List[Int]()
    input_shape.append(112800)
    input_shape.append(1)
    input_shape.append(28)
    input_shape.append(28)

    print("  Creating input tensor...")
    var input = zeros(input_shape, DType.float32)
    print("  Input numel:", input.numel(), "(", input.numel() * 4, "bytes )")

    # Create conv1 kernel: (6, 1, 5, 5)
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

    print("  Running conv2d on full batch...")
    var output = conv2d(input, kernel, bias, stride=1, padding=0)
    print("  Output numel:", output.numel())

    print("  ✓ Test passed!")


fn test_small_batch_pipeline() raises:
    """Test the full LeNet-5 pipeline with small batch."""
    print("\nTest: Full pipeline with batch=32...")

    # Create input: (batch=32, channels=1, height=28, width=28)
    var input_shape = List[Int]()
    input_shape.append(32)
    input_shape.append(1)
    input_shape.append(28)
    input_shape.append(28)
    var input = zeros(input_shape, DType.float32)
    print("  Input created")

    # Conv1: (6, 1, 5, 5)
    var conv1_kernel_shape = List[Int]()
    conv1_kernel_shape.append(6)
    conv1_kernel_shape.append(1)
    conv1_kernel_shape.append(5)
    conv1_kernel_shape.append(5)
    var conv1_kernel = kaiming_uniform(1*5*5, 6*5*5, conv1_kernel_shape, dtype=DType.float32)

    var conv1_bias_shape = List[Int]()
    conv1_bias_shape.append(6)
    var conv1_bias = zeros(conv1_bias_shape, DType.float32)

    print("  Running conv1...")
    var conv1_out = conv2d(input, conv1_kernel, conv1_bias, stride=1, padding=0)
    print("    conv1_out numel:", conv1_out.numel())

    print("  Running relu1...")
    var relu1_out = relu(conv1_out)
    print("    relu1_out numel:", relu1_out.numel())

    print("  Running maxpool1...")
    var pool1_out = maxpool2d(relu1_out, kernel_size=2, stride=2, padding=0)
    print("    pool1_out numel:", pool1_out.numel())

    print("  ✓ Test passed!")


fn main() raises:
    print("=" * 60)
    print("Full Batch Size Tests")
    print("=" * 60)
    print()

    # Start with smaller test first
    test_small_batch_pipeline()

    # Then try full batch (this might crash or run out of memory)
    # test_full_batch_forward()

    print()
    print("=" * 60)
    print("Tests completed!")
    print("=" * 60)
