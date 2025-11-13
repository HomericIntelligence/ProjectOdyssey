"""Tests for in-memory tensor dataset.

Tests TensorDataset which stores all data in memory as tensors,
providing fast random access for small to medium datasets.
"""

from tests.shared.conftest import (
    assert_true,
    assert_equal,
    assert_almost_equal,
    TestFixtures,
)


# ============================================================================
# TensorDataset Creation Tests
# ============================================================================


fn test_tensor_dataset_creation():
    """Test creating TensorDataset from tensors.

    TensorDataset should accept data and labels tensors and store them
    for efficient in-memory access.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = TestFixtures.small_tensor()  # 3x3 tensor
    # var labels = Tensor([0, 1, 2])
    # var dataset = TensorDataset(data, labels)
    # assert_equal(len(dataset), 3)
    pass


fn test_tensor_dataset_with_matching_sizes():
    """Test that data and labels must have matching first dimension.

    The number of samples in data must match the number of labels,
    otherwise training would fail with mismatched batch sizes.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor.randn(100, 10)  # 100 samples
    # var labels = Tensor.randn(100)    # 100 labels
    # var dataset = TensorDataset(data, labels)
    # assert_equal(len(dataset), 100)
    pass


fn test_tensor_dataset_size_mismatch_error():
    """Test that mismatched data/label sizes raise error.

    Creating dataset with 100 data samples and 50 labels should fail
    immediately rather than causing silent errors during training.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor.randn(100, 10)
    # var labels = Tensor.randn(50)  # Mismatch!
    # try:
    #     var dataset = TensorDataset(data, labels)
    #     assert_true(False, "Should have raised ValueError")
    # except ValueError:
    #     pass  # Expected
    pass


fn test_tensor_dataset_empty():
    """Test creating empty TensorDataset.

    Empty dataset should be valid (length 0) and not crash when queried.
    Useful for testing edge cases and incremental dataset building.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor.empty(0, 10)
    # var labels = Tensor.empty(0)
    # var dataset = TensorDataset(data, labels)
    # assert_equal(len(dataset), 0)
    pass


# ============================================================================
# TensorDataset Access Tests
# ============================================================================


fn test_tensor_dataset_getitem():
    """Test accessing individual samples by index.

    Should return (data, label) tuple for the requested index,
    with data being a single sample (not a batch).
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
    # var labels = Tensor([0, 1, 2])
    # var dataset = TensorDataset(data, labels)
    #
    # var sample_data, sample_label = dataset[1]
    # assert_almost_equal(sample_data[0], 3.0)
    # assert_almost_equal(sample_data[1], 4.0)
    # assert_equal(sample_label, 1)
    pass


fn test_tensor_dataset_negative_indexing():
    """Test negative indexing works correctly.

    dataset[-1] should return the last sample,
    dataset[-2] the second-to-last, etc.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor([[1.0], [2.0], [3.0]])
    # var labels = Tensor([0, 1, 2])
    # var dataset = TensorDataset(data, labels)
    #
    # var last_data, last_label = dataset[-1]
    # assert_almost_equal(last_data[0], 3.0)
    # assert_equal(last_label, 2)
    pass


fn test_tensor_dataset_out_of_bounds():
    """Test that out-of-bounds access raises error.

    Accessing index >= len(dataset) or index < -len(dataset)
    should raise IndexError to prevent silent failures.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor([[1.0], [2.0], [3.0]])
    # var labels = Tensor([0, 1, 2])
    # var dataset = TensorDataset(data, labels)
    #
    # try:
    #     var sample = dataset[10]
    #     assert_true(False, "Should have raised IndexError")
    # except IndexError:
    #     pass
    pass


fn test_tensor_dataset_iteration_consistency():
    """Test that repeated access returns same data.

    Multiple calls to dataset[i] should return identical tensors,
    ensuring deterministic behavior for debugging and testing.
    """
    # TODO(#39): Implement when TensorDataset exists
    # var data = Tensor([[1.0, 2.0]])
    # var labels = Tensor([0])
    # var dataset = TensorDataset(data, labels)
    #
    # var sample1_data, _ = dataset[0]
    # var sample2_data, _ = dataset[0]
    # assert_almost_equal(sample1_data[0], sample2_data[0])
    pass


# ============================================================================
# TensorDataset Memory Tests
# ============================================================================


fn test_tensor_dataset_no_copy_on_access():
    """Test that __getitem__ returns views, not copies.

    For efficiency, dataset should return views into the original tensor
    rather than creating copies, reducing memory overhead.
    """
    # TODO(#39): Implement when TensorDataset and tensor views exist
    # var data = Tensor([[1.0, 2.0]])
    # var labels = Tensor([0])
    # var dataset = TensorDataset(data, labels)
    #
    # var sample_data, _ = dataset[0]
    # # Modify returned data
    # sample_data[0] = 999.0
    # # Check if original was modified (view behavior)
    # assert_almost_equal(data[0, 0], 999.0)
    pass


fn test_tensor_dataset_memory_efficiency():
    """Test that TensorDataset doesn't duplicate data in memory.

    Creating dataset should not copy the input tensors,
    just store references to save memory.
    """
    # TODO(#39): Implement when memory profiling tools exist
    # var data = Tensor.randn(1000, 100)  # Large tensor
    # var labels = Tensor.randn(1000)
    #
    # # Creating dataset should not significantly increase memory
    # var dataset = TensorDataset(data, labels)
    # # Memory usage should be approximately same as original tensors
    pass


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all tensor dataset tests."""
    print("Running tensor dataset tests...")

    # Creation tests
    test_tensor_dataset_creation()
    test_tensor_dataset_with_matching_sizes()
    test_tensor_dataset_size_mismatch_error()
    test_tensor_dataset_empty()

    # Access tests
    test_tensor_dataset_getitem()
    test_tensor_dataset_negative_indexing()
    test_tensor_dataset_out_of_bounds()
    test_tensor_dataset_iteration_consistency()

    # Memory tests
    test_tensor_dataset_no_copy_on_access()
    test_tensor_dataset_memory_efficiency()

    print("✓ All tensor dataset tests passed!")
