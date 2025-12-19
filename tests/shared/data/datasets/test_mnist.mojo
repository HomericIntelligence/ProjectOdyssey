"""Tests for MNIST dataset implementation."""

import testing
from shared.data.datasets import MNISTDataset, get_mnist_classes


fn test_mnist_classes() raises:
    """Test MNIST class names are correct."""
    var classes = get_mnist_classes()
    testing.assert_equal(len(classes), 10)
    testing.assert_equal(classes[0], "0")
    testing.assert_equal(classes[9], "9")


fn test_mnist_properties() raises:
    """Test MNIST dataset properties."""
    # Note: This test checks properties without loading actual data
    # Actual data loading would require dataset files
    var mnist = MNISTDataset("/fake/path")

    testing.assert_equal(mnist.num_classes(), 10)
    testing.assert_equal(mnist.num_train_samples(), 60000)
    testing.assert_equal(mnist.num_test_samples(), 10000)

    var shape = mnist.image_shape()
    testing.assert_equal(len(shape), 3)
    testing.assert_equal(shape[0], 1)  # Channels
    testing.assert_equal(shape[1], 28)  # Height
    testing.assert_equal(shape[2], 28)  # Width

    testing.assert_equal(mnist.__len__(), 60000)


fn main() raises:
    """Run all MNIST dataset tests."""
    test_mnist_classes()
    test_mnist_properties()
    print("All MNIST dataset tests passed!")
