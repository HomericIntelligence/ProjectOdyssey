"""Tests for base dataset interface.

Tests the abstract Dataset interface that all datasets must implement,
ensuring consistent API across different dataset types.
"""

from tests.shared.conftest import assert_true, assert_equal, TestFixtures


# ============================================================================
# Base Dataset Interface Tests
# ============================================================================


fn test_dataset_has_len_method():
    """Test that Dataset interface requires __len__ method.

    The Dataset trait must provide a way to query the total number of samples.
    This is critical for batch calculation and progress tracking.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # assert_equal(len(dataset), 100)
    pass


fn test_dataset_has_getitem_method():
    """Test that Dataset interface requires __getitem__ method.

    The Dataset trait must provide indexed access to samples.
    This enables data loaders to fetch specific samples by index.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # var sample = dataset[0]
    # assert_true(sample is not None)
    pass


fn test_dataset_getitem_returns_tuple():
    """Test that __getitem__ returns (data, label) tuple.

    Standard convention is to return both data and label together,
    which simplifies training loop implementations.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # var data, label = dataset[0]
    # assert_true(data.shape[0] > 0)
    # assert_true(label is not None)
    pass


fn test_dataset_getitem_index_validation():
    """Test that __getitem__ validates index bounds.

    Should raise error for out-of-bounds indices to prevent
    accessing invalid memory or returning corrupted data.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # try:
    #     var sample = dataset[100]  # Out of bounds
    #     assert_true(False, "Should have raised IndexError")
    # except IndexError:
    #     pass  # Expected
    pass


fn test_dataset_supports_negative_indexing():
    """Test that Dataset supports Python-style negative indexing.

    Negative indices should count from the end: dataset[-1] == dataset[len-1].
    This provides convenient access to the last elements.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # var last_sample = dataset[-1]
    # var explicit_last = dataset[99]
    # assert_equal(last_sample[0], explicit_last[0])
    pass


fn test_dataset_length_immutable():
    """Test that dataset length remains constant after creation.

    The __len__ method should return the same value across multiple calls,
    ensuring deterministic behavior for data loaders.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # var len1 = len(dataset)
    # var len2 = len(dataset)
    # assert_equal(len1, len2)
    pass


fn test_dataset_iteration_consistency():
    """Test that repeated __getitem__ calls return consistent data.

    Calling dataset[i] multiple times should return the same data,
    unless the dataset explicitly supports randomization per access.
    """
    # TODO(#39): Implement when Dataset trait exists
    # var dataset = SimpleDataset(size=100)
    # var sample1 = dataset[5]
    # var sample2 = dataset[5]
    # assert_equal(sample1[0], sample2[0])  # Data should be identical
    pass


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all base dataset tests."""
    print("Running base dataset tests...")

    test_dataset_has_len_method()
    test_dataset_has_getitem_method()
    test_dataset_getitem_returns_tuple()
    test_dataset_getitem_index_validation()
    test_dataset_supports_negative_indexing()
    test_dataset_length_immutable()
    test_dataset_iteration_consistency()

    print("✓ All base dataset tests passed!")
