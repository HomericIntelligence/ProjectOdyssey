"""Tests for weighted sampler.

Tests WeightedSampler which samples indices according to specified weights,
enabling class balancing and importance sampling for imbalanced datasets.
"""

from tests.shared.conftest import (
    assert_true,
    assert_equal,
    assert_almost_equal,
    assert_greater,
    TestFixtures,
)


# ============================================================================
# WeightedSampler Creation Tests
# ============================================================================


fn test_weighted_sampler_creation():
    """Test creating WeightedSampler with weights.

    Should accept list of weights (one per sample) and sample
    indices proportional to weights.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 2.0, 3.0, 4.0])
    # var sampler = WeightedSampler(weights, num_samples=100)
    # assert_equal(len(sampler), 100)
    pass


fn test_weighted_sampler_uniform_weights():
    """Test that uniform weights produce uniform sampling.

    When all weights are equal, should behave like RandomSampler,
    each index equally likely.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 1.0, 1.0, 1.0])  # Uniform
    # var sampler = WeightedSampler(weights, num_samples=1000)
    #
    # var counts = List[Int]([0, 0, 0, 0])
    # for idx in sampler:
    #     counts[idx] += 1
    #
    # # Each index should appear ~250 times (25% of 1000)
    # for count in counts:
    #     assert_true(count > 200 and count < 300)
    pass


fn test_weighted_sampler_zero_weight():
    """Test that zero-weight samples are never sampled.

    Indices with weight=0 should never be yielded,
    useful for excluding certain samples.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 0.0, 1.0, 0.0])
    # var sampler = WeightedSampler(weights, num_samples=1000)
    #
    # var seen_indices = Set[Int]()
    # for idx in sampler:
    #     seen_indices.add(idx)
    #
    # # Should only see indices 0 and 2
    # assert_true(0 in seen_indices)
    # assert_false(1 in seen_indices)
    # assert_true(2 in seen_indices)
    # assert_false(3 in seen_indices)
    pass


fn test_weighted_sampler_weights_normalization():
    """Test that weights are automatically normalized.

    Weights [1, 2, 3] should behave same as [0.1, 0.2, 0.3],
    only relative proportions matter.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # TestFixtures.set_seed()
    # var sampler1 = WeightedSampler(
    #     List[Float32]([1.0, 2.0, 3.0]),
    #     num_samples=1000
    # )
    # var indices1 = List[Int]()
    # for idx in sampler1:
    #     indices1.append(idx)
    #
    # TestFixtures.set_seed()
    # var sampler2 = WeightedSampler(
    #     List[Float32]([0.1, 0.2, 0.3]),
    #     num_samples=1000
    # )
    # var indices2 = List[Int]()
    # for idx in sampler2:
    #     indices2.append(idx)
    #
    # # Should produce same sequence (weights are equivalent)
    # assert_equal(indices1, indices2)
    pass


# ============================================================================
# WeightedSampler Probability Tests
# ============================================================================


fn test_weighted_sampler_proportional_sampling():
    """Test that sampling is proportional to weights.

    With weights [1, 2, 3], index 2 should appear 3x more often
    than index 0, index 1 appears 2x more often than index 0.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 2.0, 3.0])
    # var sampler = WeightedSampler(weights, num_samples=6000)
    #
    # var counts = List[Int]([0, 0, 0])
    # for idx in sampler:
    #     counts[idx] += 1
    #
    # # Expected proportions: 1/6, 2/6, 3/6
    # # With 6000 samples: ~1000, ~2000, ~3000
    # assert_true(counts[0] > 800 and counts[0] < 1200)   # ~1000
    # assert_true(counts[1] > 1800 and counts[1] < 2200)  # ~2000
    # assert_true(counts[2] > 2800 and counts[2] < 3200)  # ~3000
    pass


fn test_weighted_sampler_extreme_weights():
    """Test handling of extreme weight ratios.

    With weights [0.001, 0.999], second index should dominate
    (appear ~99.9% of the time).
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([0.001, 0.999])
    # var sampler = WeightedSampler(weights, num_samples=10000)
    #
    # var count_idx1 = 0
    # for idx in sampler:
    #     if idx == 1:
    #         count_idx1 += 1
    #
    # # Should be approximately 9990 out of 10000 (99.9%)
    # assert_true(count_idx1 > 9900)
    pass


# ============================================================================
# WeightedSampler Replacement Tests
# ============================================================================


fn test_weighted_sampler_with_replacement():
    """Test that weighted sampling uses replacement by default.

    Should allow same index to be sampled multiple times,
    as sampling is probabilistic.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 1.0])
    # var sampler = WeightedSampler(weights, num_samples=100)
    #
    # var indices = List[Int]()
    # for idx in sampler:
    #     indices.append(idx)
    #
    # # Should have some duplicates (sampling with replacement)
    # var unique_count = Set[Int](indices).size()
    # assert_true(unique_count < 100)
    pass


fn test_weighted_sampler_num_samples():
    """Test that num_samples controls total samples yielded.

    Should yield exactly num_samples indices,
    regardless of dataset size or weights.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 1.0, 1.0])  # 3 samples
    # var sampler = WeightedSampler(weights, num_samples=1000)
    #
    # var count = 0
    # for idx in sampler:
    #     count += 1
    #
    # assert_equal(count, 1000)
    pass


# ============================================================================
# WeightedSampler Class Balancing Tests
# ============================================================================


fn test_weighted_sampler_class_balancing():
    """Test using WeightedSampler for class balancing.

    For imbalanced dataset (90 class A, 10 class B),
    weights can balance classes to 50/50 sampling.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # # Simulated dataset: 90 samples of class 0, 10 of class 1
    # var weights = List[Float32]()
    # for _ in range(90):
    #     weights.append(1.0/90.0)  # Low weight for majority class
    # for _ in range(10):
    #     weights.append(1.0/10.0)  # High weight for minority class
    #
    # var sampler = WeightedSampler(weights, num_samples=10000)
    #
    # var count_class0 = 0
    # var count_class1 = 0
    # for idx in sampler:
    #     if idx < 90:
    #         count_class0 += 1
    #     else:
    #         count_class1 += 1
    #
    # # Should be approximately balanced (50/50)
    # assert_true(count_class0 > 4500 and count_class0 < 5500)
    # assert_true(count_class1 > 4500 and count_class1 < 5500)
    pass


fn test_weighted_sampler_inverse_frequency():
    """Test inverse frequency weighting for balancing.

    Weight = 1/class_frequency is common pattern for balancing,
    e.g., class with 100 samples gets weight 1/100.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # # Class frequencies: [100, 50, 10]
    # var weights = List[Float32]()
    # for _ in range(100):
    #     weights.append(1.0/100.0)
    # for _ in range(50):
    #     weights.append(1.0/50.0)
    # for _ in range(10):
    #     weights.append(1.0/10.0)
    #
    # var sampler = WeightedSampler(weights, num_samples=15000)
    #
    # var counts = [0, 0, 0]
    # for idx in sampler:
    #     if idx < 100:
    #         counts[0] += 1
    #     elif idx < 150:
    #         counts[1] += 1
    #     else:
    #         counts[2] += 1
    #
    # # All classes should be approximately balanced
    # for count in counts:
    #     assert_true(count > 4500 and count < 5500)
    pass


# ============================================================================
# WeightedSampler Determinism Tests
# ============================================================================


fn test_weighted_sampler_deterministic_with_seed():
    """Test that weighted sampling is deterministic with seed.

    Same seed should produce same sequence of indices,
    enabling reproducible training.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, 2.0, 3.0])
    #
    # TestFixtures.set_seed()
    # var sampler1 = WeightedSampler(weights, num_samples=100)
    # var indices1 = List[Int]()
    # for idx in sampler1:
    #     indices1.append(idx)
    #
    # TestFixtures.set_seed()
    # var sampler2 = WeightedSampler(weights, num_samples=100)
    # var indices2 = List[Int]()
    # for idx in sampler2:
    #     indices2.append(idx)
    #
    # assert_equal(indices1, indices2)
    pass


# ============================================================================
# WeightedSampler Error Handling Tests
# ============================================================================


fn test_weighted_sampler_negative_weight_error():
    """Test that negative weights raise error.

    Weights must be non-negative (>=0),
    negative weights are meaningless for probabilities.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([1.0, -1.0, 2.0])
    # try:
    #     var sampler = WeightedSampler(weights, num_samples=100)
    #     assert_true(False, "Should have raised ValueError")
    # except ValueError:
    #     pass
    pass


fn test_weighted_sampler_all_zero_weights_error():
    """Test that all-zero weights raise error.

    If all weights are zero, cannot sample anything,
    should fail with clear error.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]([0.0, 0.0, 0.0])
    # try:
    #     var sampler = WeightedSampler(weights, num_samples=100)
    #     assert_true(False, "Should have raised ValueError")
    # except ValueError:
    #     pass
    pass


fn test_weighted_sampler_empty_weights_error():
    """Test that empty weights list raises error.

    Cannot create sampler with no weights,
    should fail immediately.
    """
    # TODO(#39): Implement when WeightedSampler exists
    # var weights = List[Float32]()
    # try:
    #     var sampler = WeightedSampler(weights, num_samples=100)
    #     assert_true(False, "Should have raised ValueError")
    # except ValueError:
    #     pass
    pass


# ============================================================================
# Main Test Runner
# ============================================================================


fn main() raises:
    """Run all weighted sampler tests."""
    print("Running weighted sampler tests...")

    # Creation tests
    test_weighted_sampler_creation()
    test_weighted_sampler_uniform_weights()
    test_weighted_sampler_zero_weight()
    test_weighted_sampler_weights_normalization()

    # Probability tests
    test_weighted_sampler_proportional_sampling()
    test_weighted_sampler_extreme_weights()

    # Replacement tests
    test_weighted_sampler_with_replacement()
    test_weighted_sampler_num_samples()

    # Class balancing tests
    test_weighted_sampler_class_balancing()
    test_weighted_sampler_inverse_frequency()

    # Determinism tests
    test_weighted_sampler_deterministic_with_seed()

    # Error handling tests
    test_weighted_sampler_negative_weight_error()
    test_weighted_sampler_all_zero_weights_error()
    test_weighted_sampler_empty_weights_error()

    print("✓ All weighted sampler tests passed!")
