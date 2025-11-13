"""Tests for base data loader interface.

Tests the DataLoader interface that all loaders must implement,
ensuring consistent API for batch iteration during training.
"""

from tests.shared.conftest import assert_true, assert_equal, TestFixtures


# ============================================================================
# Base DataLoader Interface Tests
# ============================================================================


fn test_loader_has_iter_method():
    """Test that DataLoader interface requires __iter__ method.

    Loaders must be iterable to enable 'for batch in loader' pattern,
    which is the standard way to consume batches during training.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32)
    # var iterator = iter(loader)
    # assert_true(iterator is not None)
    pass


fn test_loader_has_len_method():
    """Test that DataLoader interface requires __len__ method.

    Should return the number of batches (not samples),
    enabling progress bars and epoch calculations.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32)
    # assert_equal(len(loader), 4)  # ceil(100/32) = 4 batches
    pass


fn test_loader_iteration():
    """Test basic iteration over batches.

    Should yield all samples exactly once per epoch,
    grouped into batches of the specified size.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32)
    #
    # var total_samples = 0
    # for batch in loader:
    #     total_samples += batch.size()
    #
    # assert_equal(total_samples, 100)
    pass


fn test_loader_batch_size_consistency():
    """Test that batches have consistent size (except possibly last).

    All batches should have batch_size samples except the last batch
    which may be smaller if dataset size is not divisible by batch_size.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32)
    #
    # var batch_sizes = List[Int]()
    # for batch in loader:
    #     batch_sizes.append(batch.size())
    #
    # # First 3 batches should be size 32
    # assert_equal(batch_sizes[0], 32)
    # assert_equal(batch_sizes[1], 32)
    # assert_equal(batch_sizes[2], 32)
    # # Last batch should be size 4 (100 - 3*32)
    # assert_equal(batch_sizes[3], 4)
    pass


fn test_loader_empty_dataset():
    """Test loader behavior with empty dataset.

    Should create valid loader that yields zero batches,
    not crash when iterated.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=0)
    # var loader = DataLoader(dataset, batch_size=32)
    #
    # assert_equal(len(loader), 0)
    #
    # var batch_count = 0
    # for batch in loader:
    #     batch_count += 1
    #
    # assert_equal(batch_count, 0)
    pass


fn test_loader_single_sample():
    """Test loader with single sample dataset.

    Should create one batch containing the single sample,
    even though batch_size is larger.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=1)
    # var loader = DataLoader(dataset, batch_size=32)
    #
    # assert_equal(len(loader), 1)
    #
    # var batch_count = 0
    # for batch in loader:
    #     assert_equal(batch.size(), 1)
    #     batch_count += 1
    #
    # assert_equal(batch_count, 1)
    pass


# ============================================================================
# DataLoader Configuration Tests
# ============================================================================


fn test_loader_batch_size_validation():
    """Test that batch_size must be positive.

    Creating loader with batch_size <= 0 should raise ValueError,
    as it would cause division by zero or infinite loop.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # try:
    #     var loader = DataLoader(dataset, batch_size=0)
    #     assert_true(False, "Should have raised ValueError")
    # except ValueError:
    #     pass
    pass


fn test_loader_drop_last_option():
    """Test drop_last parameter.

    When drop_last=True, should discard final partial batch,
    ensuring all batches have exactly batch_size samples.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32, drop_last=True)
    #
    # assert_equal(len(loader), 3)  # Drops last batch of 4 samples
    #
    # for batch in loader:
    #     assert_equal(batch.size(), 32)
    pass


fn test_loader_reset_between_epochs():
    """Test that loader can be iterated multiple times.

    Should support multiple epochs by allowing iterator to be reset,
    yielding same batches in subsequent iterations.
    """
    # TODO(#39): Implement when DataLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = DataLoader(dataset, batch_size=32)
    #
    # # First epoch
    # var epoch1_batches = 0
    # for batch in loader:
    #     epoch1_batches += 1
    #
    # # Second epoch (should work identically)
    # var epoch2_batches = 0
    # for batch in loader:
    #     epoch2_batches += 1
    #
    # assert_equal(epoch1_batches, epoch2_batches)
    pass


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all base loader tests."""
    print("Running base loader tests...")

    # Interface tests
    test_loader_has_iter_method()
    test_loader_has_len_method()
    test_loader_iteration()
    test_loader_batch_size_consistency()
    test_loader_empty_dataset()
    test_loader_single_sample()

    # Configuration tests
    test_loader_batch_size_validation()
    test_loader_drop_last_option()
    test_loader_reset_between_epochs()

    print("✓ All base loader tests passed!")
