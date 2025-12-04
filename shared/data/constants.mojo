"""Dataset Class Name Constants.

Consolidates dataset class names and labels currently duplicated across examples.
Provides a single source of truth for class mappings used across all examples.

Supported Datasets:
    - CIFAR-10: 10 object classes.
    - EMNIST: 47 character classes (digits, uppercase, lowercase).

Example:
    ```mojo
    from shared.data.constants import get_cifar10_class_name, get_emnist_class_name

    # Get specific class name by index
    var airplane_name = get_cifar10_class_name(0)  # Returns "airplane"
    var zero_name = get_emnist_class_name(0)  # Returns "0"
    ```
"""


# ============================================================================
# CIFAR-10 Constants
# ============================================================================

alias CIFAR10_NUM_CLASSES: Int = 10


fn get_cifar10_class_name(class_idx: Int) -> String:
    """Get the CIFAR-10 class name for a given index.

    Args:
        class_idx: Zero-indexed class number (0-9).

    Returns:
        Class name string, or "unknown" if out of bounds.

    Example:
        ```mojo
        var name = get_cifar10_class_name(0)  # Returns "airplane"
        var cat = get_cifar10_class_name(3)   # Returns "cat"
        ```
    """
    if class_idx == 0:
        return "airplane"
    elif class_idx == 1:
        return "automobile"
    elif class_idx == 2:
        return "bird"
    elif class_idx == 3:
        return "cat"
    elif class_idx == 4:
        return "deer"
    elif class_idx == 5:
        return "dog"
    elif class_idx == 6:
        return "frog"
    elif class_idx == 7:
        return "horse"
    elif class_idx == 8:
        return "ship"
    elif class_idx == 9:
        return "truck"
    else:
        return "unknown"


# ============================================================================
# EMNIST Balanced Constants (47 classes)
# ============================================================================
# Mapping:
#   0-9: Digits (0-9)
#   10-35: Uppercase letters (A-Z)
#   36-46: Lowercase letters (select subset: a, b, d, e, f, g, h, n, q, r, t)

alias EMNIST_NUM_CLASSES: Int = 47


fn get_emnist_class_name(class_idx: Int) -> String:
    """Get the EMNIST Balanced class name for a given index.

    Args:
        class_idx: Zero-indexed class number (0-46).

    Returns:
        Class name string, or "unknown" if out of bounds.

    Example:
        ```mojo
        var zero = get_emnist_class_name(0)   # Returns "0"
        var A = get_emnist_class_name(10)     # Returns "A"
        var a = get_emnist_class_name(36)     # Returns "a"
        ```
    """
    # Digits 0-9
    if class_idx == 0:
        return "0"
    elif class_idx == 1:
        return "1"
    elif class_idx == 2:
        return "2"
    elif class_idx == 3:
        return "3"
    elif class_idx == 4:
        return "4"
    elif class_idx == 5:
        return "5"
    elif class_idx == 6:
        return "6"
    elif class_idx == 7:
        return "7"
    elif class_idx == 8:
        return "8"
    elif class_idx == 9:
        return "9"
    # Uppercase A-Z (10-35)
    elif class_idx == 10:
        return "A"
    elif class_idx == 11:
        return "B"
    elif class_idx == 12:
        return "C"
    elif class_idx == 13:
        return "D"
    elif class_idx == 14:
        return "E"
    elif class_idx == 15:
        return "F"
    elif class_idx == 16:
        return "G"
    elif class_idx == 17:
        return "H"
    elif class_idx == 18:
        return "I"
    elif class_idx == 19:
        return "J"
    elif class_idx == 20:
        return "K"
    elif class_idx == 21:
        return "L"
    elif class_idx == 22:
        return "M"
    elif class_idx == 23:
        return "N"
    elif class_idx == 24:
        return "O"
    elif class_idx == 25:
        return "P"
    elif class_idx == 26:
        return "Q"
    elif class_idx == 27:
        return "R"
    elif class_idx == 28:
        return "S"
    elif class_idx == 29:
        return "T"
    elif class_idx == 30:
        return "U"
    elif class_idx == 31:
        return "V"
    elif class_idx == 32:
        return "W"
    elif class_idx == 33:
        return "X"
    elif class_idx == 34:
        return "Y"
    elif class_idx == 35:
        return "Z"
    # Lowercase subset (36-46): a, b, d, e, f, g, h, n, q, r, t
    elif class_idx == 36:
        return "a"
    elif class_idx == 37:
        return "b"
    elif class_idx == 38:
        return "d"
    elif class_idx == 39:
        return "e"
    elif class_idx == 40:
        return "f"
    elif class_idx == 41:
        return "g"
    elif class_idx == 42:
        return "h"
    elif class_idx == 43:
        return "n"
    elif class_idx == 44:
        return "q"
    elif class_idx == 45:
        return "r"
    elif class_idx == 46:
        return "t"
    else:
        return "unknown"


# ============================================================================
# Generic Helper Functions
# ============================================================================


fn get_class_name(dataset: String, class_idx: Int) -> String:
    """Get the name of a class by dataset and index.

    Args:
        dataset: Dataset name ("cifar10" or "emnist").
        class_idx: Zero-indexed class number.

    Returns:
        Class name string, or empty string if invalid.

    Example:
        ```mojo
        var name = get_class_name("cifar10", 0)  # Returns "airplane"
        var char = get_class_name("emnist", 10)  # Returns "A"
        ```
    """
    if dataset == "cifar10":
        return get_cifar10_class_name(class_idx)
    elif dataset == "emnist":
        return get_emnist_class_name(class_idx)
    else:
        return ""


fn get_num_classes(dataset: String) -> Int:
    """Get the number of classes in a dataset.

    Args:
        dataset: Dataset name ("cifar10" or "emnist").

    Returns:
        Number of classes in the dataset, or 0 if unknown.

    Example:
        ```mojo
        var cifar10_classes = get_num_classes("cifar10")  # Returns 10
        var emnist_classes = get_num_classes("emnist")   # Returns 47
        ```
    """
    if dataset == "cifar10":
        return CIFAR10_NUM_CLASSES
    elif dataset == "emnist":
        return EMNIST_NUM_CLASSES
    else:
        return 0


fn is_valid_dataset(dataset: String) -> Bool:
    """Check if a dataset name is supported.

    Args:
        dataset: Dataset name to validate.

    Returns:
        True if dataset is supported, False otherwise.

    Example:
        ```mojo
        if is_valid_dataset("cifar10"):
            print("CIFAR-10 is supported")
        ```
    """
    return dataset == "cifar10" or dataset == "emnist"
