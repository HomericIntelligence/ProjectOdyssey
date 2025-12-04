"""Test suite for dataset constants module.

Tests the constants.mojo module which consolidates dataset class names
and provides helper functions for accessing class metadata.

Test Coverage:
    - CIFAR-10 class name lookup.
    - EMNIST class name lookup.
    - get_class_name() helper function.
    - get_num_classes() helper function.
    - is_valid_dataset() validation function.
    - Error handling for invalid inputs.
"""

from tests.shared.conftest import assert_equal, assert_true
from shared.data import (
    CIFAR10_NUM_CLASSES,
    EMNIST_NUM_CLASSES,
    get_cifar10_class_name,
    get_emnist_class_name,
    get_class_name,
    get_num_classes,
    is_valid_dataset,
)


fn test_cifar10_num_classes() raises:
    """Test CIFAR-10 number of classes constant."""
    assert_equal(CIFAR10_NUM_CLASSES, 10, "CIFAR-10 should have 10 classes")


fn test_emnist_num_classes() raises:
    """Test EMNIST number of classes constant."""
    assert_equal(EMNIST_NUM_CLASSES, 47, "EMNIST should have 47 classes")


fn test_get_cifar10_class_name() raises:
    """Test get_cifar10_class_name() function."""
    # Test all valid indices
    assert_equal(get_cifar10_class_name(0), "airplane", "Index 0 should be airplane")
    assert_equal(get_cifar10_class_name(1), "automobile", "Index 1 should be automobile")
    assert_equal(get_cifar10_class_name(2), "bird", "Index 2 should be bird")
    assert_equal(get_cifar10_class_name(3), "cat", "Index 3 should be cat")
    assert_equal(get_cifar10_class_name(4), "deer", "Index 4 should be deer")
    assert_equal(get_cifar10_class_name(5), "dog", "Index 5 should be dog")
    assert_equal(get_cifar10_class_name(6), "frog", "Index 6 should be frog")
    assert_equal(get_cifar10_class_name(7), "horse", "Index 7 should be horse")
    assert_equal(get_cifar10_class_name(8), "ship", "Index 8 should be ship")
    assert_equal(get_cifar10_class_name(9), "truck", "Index 9 should be truck")

    # Test invalid indices
    assert_equal(get_cifar10_class_name(-1), "unknown", "Negative index should be unknown")
    assert_equal(get_cifar10_class_name(10), "unknown", "Out of bounds should be unknown")


fn test_get_emnist_class_name_digits() raises:
    """Test get_emnist_class_name() for digits (0-9)."""
    assert_equal(get_emnist_class_name(0), "0", "Index 0 should be 0")
    assert_equal(get_emnist_class_name(5), "5", "Index 5 should be 5")
    assert_equal(get_emnist_class_name(9), "9", "Index 9 should be 9")


fn test_get_emnist_class_name_uppercase() raises:
    """Test get_emnist_class_name() for uppercase letters (A-Z)."""
    assert_equal(get_emnist_class_name(10), "A", "Index 10 should be A")
    assert_equal(get_emnist_class_name(19), "J", "Index 19 should be J")
    assert_equal(get_emnist_class_name(35), "Z", "Index 35 should be Z")


fn test_get_emnist_class_name_lowercase() raises:
    """Test get_emnist_class_name() for lowercase subset."""
    assert_equal(get_emnist_class_name(36), "a", "Index 36 should be a")
    assert_equal(get_emnist_class_name(37), "b", "Index 37 should be b")
    assert_equal(get_emnist_class_name(46), "t", "Index 46 should be t")


fn test_get_emnist_class_name_invalid() raises:
    """Test get_emnist_class_name() with invalid indices."""
    assert_equal(get_emnist_class_name(-1), "unknown", "Negative index should be unknown")
    assert_equal(get_emnist_class_name(47), "unknown", "Out of bounds should be unknown")
    assert_equal(get_emnist_class_name(100), "unknown", "Large index should be unknown")


fn test_get_class_name_cifar10() raises:
    """Test generic get_class_name() for CIFAR-10."""
    assert_equal(get_class_name("cifar10", 0), "airplane", "cifar10 index 0 should be airplane")
    assert_equal(get_class_name("cifar10", 3), "cat", "cifar10 index 3 should be cat")
    assert_equal(get_class_name("cifar10", 9), "truck", "cifar10 index 9 should be truck")


fn test_get_class_name_emnist() raises:
    """Test generic get_class_name() for EMNIST."""
    assert_equal(get_class_name("emnist", 0), "0", "emnist index 0 should be 0")
    assert_equal(get_class_name("emnist", 10), "A", "emnist index 10 should be A")
    assert_equal(get_class_name("emnist", 36), "a", "emnist index 36 should be a")


fn test_get_class_name_unknown_dataset() raises:
    """Test get_class_name() with unknown dataset."""
    var result = get_class_name("unknown_dataset", 0)
    assert_equal(result, "", "Unknown dataset should return empty string")


fn test_get_num_classes_cifar10() raises:
    """Test get_num_classes() for CIFAR-10."""
    var num_classes = get_num_classes("cifar10")
    assert_equal(num_classes, 10, "CIFAR-10 should have 10 classes")


fn test_get_num_classes_emnist() raises:
    """Test get_num_classes() for EMNIST."""
    var num_classes = get_num_classes("emnist")
    assert_equal(num_classes, 47, "EMNIST should have 47 classes")


fn test_get_num_classes_unknown_dataset() raises:
    """Test get_num_classes() with unknown dataset."""
    var num_classes = get_num_classes("unknown_dataset")
    assert_equal(num_classes, 0, "Unknown dataset should return 0 classes")


fn test_is_valid_dataset() raises:
    """Test is_valid_dataset() validation function."""
    # Test valid datasets
    assert_true(is_valid_dataset("cifar10"), "cifar10 should be valid")
    assert_true(is_valid_dataset("emnist"), "emnist should be valid")

    # Test invalid datasets
    assert_true(not is_valid_dataset("unknown"), "unknown should not be valid")
    assert_true(not is_valid_dataset("cifar100"), "cifar100 should not be valid")
    assert_true(not is_valid_dataset(""), "empty string should not be valid")


fn test_consistent_class_count() raises:
    """Test that get_num_classes() matches the constants."""
    assert_equal(
        get_num_classes("cifar10"),
        CIFAR10_NUM_CLASSES,
        "get_num_classes should match CIFAR10_NUM_CLASSES"
    )
    assert_equal(
        get_num_classes("emnist"),
        EMNIST_NUM_CLASSES,
        "get_num_classes should match EMNIST_NUM_CLASSES"
    )


fn main():
    """Run all tests."""
    print("Running dataset constants tests...")

    try:
        test_cifar10_num_classes()
        print("  test_cifar10_num_classes passed")
    except e:
        print("  test_cifar10_num_classes failed:", e)

    try:
        test_emnist_num_classes()
        print("  test_emnist_num_classes passed")
    except e:
        print("  test_emnist_num_classes failed:", e)

    try:
        test_get_cifar10_class_name()
        print("  test_get_cifar10_class_name passed")
    except e:
        print("  test_get_cifar10_class_name failed:", e)

    try:
        test_get_emnist_class_name_digits()
        print("  test_get_emnist_class_name_digits passed")
    except e:
        print("  test_get_emnist_class_name_digits failed:", e)

    try:
        test_get_emnist_class_name_uppercase()
        print("  test_get_emnist_class_name_uppercase passed")
    except e:
        print("  test_get_emnist_class_name_uppercase failed:", e)

    try:
        test_get_emnist_class_name_lowercase()
        print("  test_get_emnist_class_name_lowercase passed")
    except e:
        print("  test_get_emnist_class_name_lowercase failed:", e)

    try:
        test_get_emnist_class_name_invalid()
        print("  test_get_emnist_class_name_invalid passed")
    except e:
        print("  test_get_emnist_class_name_invalid failed:", e)

    try:
        test_get_class_name_cifar10()
        print("  test_get_class_name_cifar10 passed")
    except e:
        print("  test_get_class_name_cifar10 failed:", e)

    try:
        test_get_class_name_emnist()
        print("  test_get_class_name_emnist passed")
    except e:
        print("  test_get_class_name_emnist failed:", e)

    try:
        test_get_class_name_unknown_dataset()
        print("  test_get_class_name_unknown_dataset passed")
    except e:
        print("  test_get_class_name_unknown_dataset failed:", e)

    try:
        test_get_num_classes_cifar10()
        print("  test_get_num_classes_cifar10 passed")
    except e:
        print("  test_get_num_classes_cifar10 failed:", e)

    try:
        test_get_num_classes_emnist()
        print("  test_get_num_classes_emnist passed")
    except e:
        print("  test_get_num_classes_emnist failed:", e)

    try:
        test_get_num_classes_unknown_dataset()
        print("  test_get_num_classes_unknown_dataset passed")
    except e:
        print("  test_get_num_classes_unknown_dataset failed:", e)

    try:
        test_is_valid_dataset()
        print("  test_is_valid_dataset passed")
    except e:
        print("  test_is_valid_dataset failed:", e)

    try:
        test_consistent_class_count()
        print("  test_consistent_class_count passed")
    except e:
        print("  test_consistent_class_count failed:", e)

    print("\nAll tests completed!")
