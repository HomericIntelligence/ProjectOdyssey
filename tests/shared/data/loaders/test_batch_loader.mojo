"""Tests for batch loader with shuffling support.

Tests BatchLoader which efficiently batches data with optional shuffling,
the most common data loader for training neural networks.
"""

from tests.shared.conftest import (
    assert_true,
    assert_equal,
    assert_not_equal,
    TestFixtures,
)


# ============================================================================
# BatchLoader Batching Tests
# ============================================================================


fn test_batch_loader_fixed_batch_size():
    """Test creating batches of fixed size.

    Should group consecutive samples into batches of batch_size,
    with proper tensor stacking for efficient GPU processing.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # var first_batch = next(iter(loader))
    # assert_equal(first_batch.data.shape[0], 32)
    pass


fn test_batch_loader_perfect_division():
    """Test dataset size perfectly divisible by batch_size.

    With 96 samples and batch_size=32, should create exactly 3 batches
    of equal size with no partial batch.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=96)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # assert_equal(len(loader), 3)
    #
    # for batch in loader:
    #     assert_equal(batch.size(), 32)
    pass


fn test_batch_loader_partial_last_batch():
    """Test handling of partial last batch.

    With 100 samples and batch_size=32, last batch should have only 4 samples
    unless drop_last=True.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # var batches = List[Batch]()
    # for batch in loader:
    #     batches.append(batch)
    #
    # assert_equal(len(batches), 4)
    # assert_equal(batches[-1].size(), 4)
    pass


fn test_batch_loader_tensor_stacking():
    """Test that individual samples are properly stacked into batch tensor.

    Each sample is a tensor; batching should stack them along new dimension 0,
    creating a batch tensor with shape (batch_size, *sample_shape).
    """
    # TODO(#39): Implement when BatchLoader exists
    # # Dataset with samples of shape (10,)
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100, feature_dim=10)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # var batch = next(iter(loader))
    # # Batch should have shape (32, 10)
    # assert_equal(batch.data.shape[0], 32)
    # assert_equal(batch.data.shape[1], 10)
    pass


# ============================================================================
# BatchLoader Shuffling Tests
# ============================================================================


fn test_batch_loader_no_shuffle():
    """Test that shuffle=False preserves dataset order.

    Batches should contain samples in dataset order: batch 0 has indices [0-31],
    batch 1 has indices [32-63], etc.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.sequential_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # var batch = next(iter(loader))
    # # First batch should contain first 32 samples in order
    # for i in range(32):
    #     assert_equal(batch.data[i, 0], Float32(i))
    pass


fn test_batch_loader_shuffle():
    """Test that shuffle=True randomizes sample order.

    Consecutive batches should not contain consecutive dataset indices,
    improving training by preventing order-dependent biases.
    """
    # TODO(#39): Implement when BatchLoader exists
    # TestFixtures.set_seed()
    # var dataset = TestFixtures.sequential_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=True)
    #
    # var batch = next(iter(loader))
    # # Batch should NOT be [0, 1, 2, ..., 31] if shuffled
    # var is_sequential = True
    # for i in range(32):
    #     if batch.data[i, 0] != Float32(i):
    #         is_sequential = False
    #         break
    #
    # assert_false(is_sequential, "Shuffle should randomize order")
    pass


fn test_batch_loader_shuffle_deterministic():
    """Test that shuffling is deterministic with fixed seed.

    Setting random seed should produce identical shuffle order across runs,
    critical for reproducible experiments.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    #
    # # First run
    # TestFixtures.set_seed()
    # var loader1 = BatchLoader(dataset, batch_size=32, shuffle=True)
    # var batch1 = next(iter(loader1))
    #
    # # Second run with same seed
    # TestFixtures.set_seed()
    # var loader2 = BatchLoader(dataset, batch_size=32, shuffle=True)
    # var batch2 = next(iter(loader2))
    #
    # # Should produce identical batches
    # assert_equal(batch1.data, batch2.data)
    pass


fn test_batch_loader_shuffle_per_epoch():
    """Test that shuffle order changes between epochs.

    Each epoch should use different random permutation,
    preventing model from learning epoch-specific patterns.
    """
    # TODO(#39): Implement when BatchLoader exists
    # TestFixtures.set_seed()
    # var dataset = TestFixtures.synthetic_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=True)
    #
    # # First epoch
    # var epoch1_batch = next(iter(loader))
    #
    # # Second epoch (should re-shuffle)
    # var epoch2_batch = next(iter(loader))
    #
    # # Batches should be different
    # assert_not_equal(epoch1_batch.data, epoch2_batch.data)
    pass


fn test_batch_loader_all_samples_per_epoch():
    """Test that shuffling doesn't lose or duplicate samples.

    Each epoch should yield all samples exactly once,
    just in different order.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.sequential_dataset(n_samples=100)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=True)
    #
    # # Collect all sample indices from one epoch
    # var seen_indices = Set[Int]()
    # for batch in loader:
    #     for i in range(batch.size()):
    #         # Extract original index from data value
    #         var idx = int(batch.data[i, 0])
    #         seen_indices.add(idx)
    #
    # # Should have seen all 100 samples exactly once
    # assert_equal(len(seen_indices), 100)
    pass


# ============================================================================
# BatchLoader Performance Tests
# ============================================================================


fn test_batch_loader_efficient_batching():
    """Test that batching is memory-efficient.

    Should pre-allocate batch tensor and fill it,
    not create intermediate list of samples.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=1000)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # # Iterating should not cause memory spikes
    # for batch in loader:
    #     pass  # Just iterate
    pass


fn test_batch_loader_iteration_speed():
    """Test that batch iteration is fast.

    Should complete 100 batches in reasonable time,
    as this is done every training step.
    """
    # TODO(#39): Implement when BatchLoader exists
    # var dataset = TestFixtures.synthetic_dataset(n_samples=3200)
    # var loader = BatchLoader(dataset, batch_size=32, shuffle=False)
    #
    # # Should iterate through all batches quickly
    # var batch_count = 0
    # for batch in loader:
    #     batch_count += 1
    #
    # assert_equal(batch_count, 100)
    pass


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all batch loader tests."""
    print("Running batch loader tests...")

    # Batching tests
    test_batch_loader_fixed_batch_size()
    test_batch_loader_perfect_division()
    test_batch_loader_partial_last_batch()
    test_batch_loader_tensor_stacking()

    # Shuffling tests
    test_batch_loader_no_shuffle()
    test_batch_loader_shuffle()
    test_batch_loader_shuffle_deterministic()
    test_batch_loader_shuffle_per_epoch()
    test_batch_loader_all_samples_per_epoch()

    # Performance tests
    test_batch_loader_efficient_batching()
    test_batch_loader_iteration_speed()

    print("✓ All batch loader tests passed!")
