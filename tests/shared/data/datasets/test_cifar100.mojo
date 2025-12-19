"""Tests for CIFAR-100 dataset implementation."""

import testing
from shared.data.datasets import (
    CIFAR100Dataset,
    get_cifar100_fine_classes,
    get_cifar100_coarse_classes,
)


fn test_cifar100_fine_classes() raises:
    """Test CIFAR-100 fine class names are correct."""
    var classes = get_cifar100_fine_classes()
    testing.assert_equal(len(classes), 100)
    testing.assert_equal(classes[0], "beaver")
    testing.assert_equal(classes[99], "tractor")


fn test_cifar100_coarse_classes() raises:
    """Test CIFAR-100 coarse class names are correct."""
    var classes = get_cifar100_coarse_classes()
    testing.assert_equal(len(classes), 20)
    testing.assert_equal(classes[0], "aquatic mammals")
    testing.assert_equal(classes[19], "vehicles 2")


fn test_cifar100_properties() raises:
    """Test CIFAR-100 dataset properties."""
    # Note: This test checks properties without loading actual data
    # Actual data loading would require dataset files
    var cifar100 = CIFAR100Dataset("/fake/path")

    testing.assert_equal(cifar100.num_fine_classes(), 100)
    testing.assert_equal(cifar100.num_coarse_classes(), 20)
    testing.assert_equal(cifar100.num_train_samples(), 50000)
    testing.assert_equal(cifar100.num_test_samples(), 10000)

    var shape = cifar100.image_shape()
    testing.assert_equal(len(shape), 3)
    testing.assert_equal(shape[0], 3)  # RGB channels
    testing.assert_equal(shape[1], 32)  # Height
    testing.assert_equal(shape[2], 32)  # Width

    testing.assert_equal(cifar100.__len__(), 50000)


fn main() raises:
    """Run all CIFAR-100 dataset tests."""
    test_cifar100_fine_classes()
    test_cifar100_coarse_classes()
    test_cifar100_properties()
    print("All CIFAR-100 dataset tests passed!")
