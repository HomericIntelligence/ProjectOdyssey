"""Data Loading Package

Provides data loaders for common ML datasets and utilities for handling various data formats.

Modules:
    `constants`: Dataset class names and metadata
    `formats`: Low-level data format loaders (IDX, CIFAR, etc.)
    `datasets`: High-level dataset interfaces (CIFAR-10, EMNIST, etc.)

Architecture:
    - `constants` provides class name mappings and metadata for all supported datasets
    - `formats` provides low-level file I/O and format parsing
    - `datasets` provides high-level, user-friendly interfaces
    - All data is returned as ExTensor for consistency with core library

Example:
    from shared.data import load_emnist_train, load_emnist_test, get_class_name

    # Load EMNIST
    images, labels = load_emnist_train("/path/to/emnist", split="balanced")

    # Get class names
    var airplane = get_class_name("cifar10", 0)  # Returns "airplane"
    var zero = get_class_name("emnist", 0)       # Returns "0"

    # Or use the EMNISTDataset class directly
    from shared.data import EMNISTDataset
    dataset = EMNISTDataset("/path/to/emnist", split="balanced", train=True)
    sample_img, sample_label = dataset[0]
"""

# Package version
alias VERSION = "0.1.0"

# ============================================================================
# Dataset Constants (Class Names and Metadata)
# ============================================================================

# Dataset constants and helper functions
from .constants import (
    CIFAR10_NUM_CLASSES,       # Number of CIFAR-10 classes (10)
    EMNIST_NUM_CLASSES,        # Number of EMNIST classes (47)
    get_cifar10_class_name,    # Get CIFAR-10 class name by index
    get_emnist_class_name,     # Get EMNIST class name by index
    get_class_name,            # Get class name by dataset and index
    get_num_classes,           # Get number of classes in dataset
    is_valid_dataset,          # Check if dataset is supported
)

# ============================================================================
# Format Loaders (Low-Level File I/O)
# ============================================================================

# IDX format utilities
from .formats import (
    read_uint32_be,         # Read big-endian uint32
    load_idx_labels,        # Load IDX label file
    load_idx_images,        # Load IDX grayscale images
    load_idx_images_rgb,    # Load IDX RGB images
    normalize_images,       # Normalize uint8 images to [0, 1] float32
    normalize_images_rgb,   # Normalize RGB images with ImageNet parameters
    one_hot_encode,         # One-hot encode integer labels
    load_cifar10_batch,     # Load single CIFAR-10 batch
)

# ============================================================================
# Dataset Loaders (High-Level Interfaces)
# ============================================================================

# Dataset classes and loaders
from .datasets import (
    Dataset,                # Base dataset interface
    ExTensorDataset,        # In-memory tensor dataset wrapper
    FileDataset,            # File-based lazy-loading dataset
    CIFAR10Dataset,         # CIFAR-10 dataset with train/test splits
)

# EMNIST dataset is defined in _datasets_core.mojo
from ._datasets_core import (
    EMNISTDataset,          # EMNIST dataset with multiple splits
    load_emnist_train,      # Load EMNIST training set
    load_emnist_test,       # Load EMNIST test set
)

# ============================================================================
# Public API
# ============================================================================

# Note: Mojo does not support __all__ for controlling exports.
# All imported symbols are automatically available to package consumers.
#
# High-level usage:
#   from shared.data import load_emnist_train, EMNISTDataset
#   images, labels = load_emnist_train("/path/to/emnist", split="balanced")
#
# Low-level usage:
#   from shared.data import load_idx_images, load_idx_labels, read_uint32_be
#   images = load_idx_images("/path/to/custom-images-idx3-ubyte")
