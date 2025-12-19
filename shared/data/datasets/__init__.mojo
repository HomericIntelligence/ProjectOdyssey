"""Dataset implementations and utilities.

Provides high-level dataset interfaces for common ML datasets including MNIST, Fashion-MNIST,
CIFAR-10, and CIFAR-100.

Modules:
    cifar10: CIFAR-10 dataset wrapper for image classification
    cifar100: CIFAR-100 dataset wrapper with fine and coarse labels
    mnist: MNIST dataset wrapper for digit classification
    fashion_mnist: Fashion-MNIST dataset wrapper for clothing classification

Classes:
    Dataset: Base trait for all datasets
    ExTensorDataset: In-memory tensor dataset
    TensorDataset: Alias for ExTensorDataset
    FileDataset: Lazy-loading file-based dataset
    CIFAR10Dataset: High-level interface for CIFAR-10 data access
    CIFAR100Dataset: High-level interface for CIFAR-100 data access
    MNISTDataset: High-level interface for MNIST data access
    FashionMNISTDataset: High-level interface for Fashion-MNIST data access

Example:
    from shared.data.datasets import (
        CIFAR10Dataset,
        CIFAR100Dataset,
        MNISTDataset,
        FashionMNISTDataset,
        TensorDataset,
    )

    # Create CIFAR-10 dataset
    var cifar10 = CIFAR10Dataset("/path/to/cifar10/data")

    # Create MNIST dataset
    var mnist = MNISTDataset("/path/to/mnist/data")

    # Create in-memory tensor dataset
    var dataset = TensorDataset(data_tensor, label_tensor)
"""

# Core dataset types from _datasets_core.mojo
from .._datasets_core import (
    Dataset,
    ExTensorDataset,
    TensorDataset,
    FileDataset,
)

# CIFAR-10 dataset
from .cifar10 import CIFAR10Dataset, get_cifar10_classes

# CIFAR-100 dataset
from .cifar100 import (
    CIFAR100Dataset,
    get_cifar100_fine_classes,
    get_cifar100_coarse_classes,
)

# MNIST dataset
from .mnist import MNISTDataset, get_mnist_classes

# Fashion-MNIST dataset
from .fashion_mnist import FashionMNISTDataset, get_fashion_mnist_classes
