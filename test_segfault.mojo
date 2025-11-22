"""Test to isolate segfault - testing core library operations."""

from shared.core import ExTensor, zeros
from collections import List


fn test_zeros_creation() raises:
    """Test basic tensor creation with zeros."""
    print("Test 1: Creating zeros tensor...")
    var shape = List[Int]()
    shape.append(2)
    shape.append(3)
    var t = zeros(shape, DType.float32)
    print("  Numel:", t.numel())
    print("  ✓ Test 1 passed")


fn test_reshape() raises:
    """Test reshape operation (suspected to cause double-free)."""
    print("\nTest 2: Testing reshape...")
    var shape1 = List[Int]()
    shape1.append(2)
    shape1.append(3)

    var t = zeros(shape1, DType.float32)
    print("  Original numel:", t.numel())

    var shape2 = List[Int]()
    shape2.append(6)

    var reshaped = t.reshape(shape2)
    print("  Reshaped numel:", reshaped.numel())
    print("  ✓ Test 2 passed (if no crash)")


fn test_list_append() raises:
    """Test List creation and append operations."""
    print("\nTest 3: Testing List operations...")
    var lst = List[Int]()
    lst.append(1)
    lst.append(2)
    lst.append(3)
    lst.append(4)
    print("  List length:", len(lst))
    print("  Elements:", lst[0], lst[1], lst[2], lst[3])
    print("  ✓ Test 3 passed")


fn test_conv_shape_creation() raises:
    """Test the exact pattern used in conv2d."""
    print("\nTest 4: Testing conv2d shape creation pattern...")
    var batch = 1
    var out_channels = 6
    var out_height = 24
    var out_width = 24

    var out_shape = List[Int]()
    out_shape.append(batch)
    out_shape.append(out_channels)
    out_shape.append(out_height)
    out_shape.append(out_width)

    var output = zeros(out_shape, DType.float32)
    print("  Output numel:", output.numel())
    print("  Expected:", batch * out_channels * out_height * out_width)
    print("  ✓ Test 4 passed")


fn main() raises:
    print("=" * 60)
    print("Segfault Isolation Tests")
    print("=" * 60)

    test_zeros_creation()
    test_list_append()
    test_conv_shape_creation()
    test_reshape()  # Run this last as it's suspected to cause crash

    print("\n" + "=" * 60)
    print("All tests passed! 🎉")
    print("=" * 60)
