"""Tests for Fashion-MNIST dataset implementation."""

import testing
from shared.data.datasets import FashionMNISTDataset, get_fashion_mnist_classes


fn test_fashion_mnist_classes() raises:
    """Test Fashion-MNIST class names are correct."""
    var classes = get_fashion_mnist_classes()
    testing.assert_equal(len(classes), 10)
    testing.assert_equal(classes[0], "T-shirt/top")
    testing.assert_equal(classes[9], "Ankle boot")


fn test_fashion_mnist_properties() raises:
    """Test Fashion-MNIST dataset properties."""
    # Note: This test checks properties without loading actual data
    # Actual data loading would require dataset files
    var fashion_mnist = FashionMNISTDataset("/fake/path")

    testing.assert_equal(fashion_mnist.num_classes(), 10)
    testing.assert_equal(fashion_mnist.num_train_samples(), 60000)
    testing.assert_equal(fashion_mnist.num_test_samples(), 10000)

    var shape = fashion_mnist.image_shape()
    testing.assert_equal(len(shape), 3)
    testing.assert_equal(shape[0], 1)  # Channels
    testing.assert_equal(shape[1], 28)  # Height
    testing.assert_equal(shape[2], 28)  # Width

    testing.assert_equal(fashion_mnist.__len__(), 60000)


fn main() raises:
    """Run all Fashion-MNIST dataset tests."""
    test_fashion_mnist_classes()
    test_fashion_mnist_properties()
    print("All Fashion-MNIST dataset tests passed!")
