"""Unit tests for Cosine Annealing Learning Rate Scheduler.

Tests cover:
- Cosine curve learning rate decay
- Smooth annealing from initial to minimum LR
- T_max (number of iterations) parameter
- Mathematical correctness

All tests use the real CosineAnnealingLR implementation.
"""

from tests.shared.conftest import (
    assert_true,
    assert_equal,
    assert_almost_equal,
    assert_greater,
    assert_less,
    assert_greater_or_equal,
    assert_less_or_equal,
    TestFixtures,
)
from shared.training.schedulers import CosineAnnealingLR
from math import cos, pi


# ============================================================================
# Cosine Scheduler Core Tests
# ============================================================================


fn test_cosine_scheduler_initialization() raises:
    """Test CosineAnnealingLR scheduler initialization with hyperparameters."""
    var scheduler = CosineAnnealingLR(base_lr=0.1, T_max=100, eta_min=0.0)

    # Verify initial parameters
    assert_equal(scheduler.T_max, 100)
    assert_almost_equal(scheduler.eta_min, 0.0)
    assert_almost_equal(scheduler.base_lr, 0.1)


fn test_cosine_scheduler_follows_cosine_curve() raises:
    """Test CosineAnnealingLR follows cosine annealing curve.

    Formula: lr = eta_min + (base_lr - eta_min) * (1 + cos(pi * epoch / T_max)) / 2

    Key points:
    - Epoch 0: lr = base_lr (maximum)
    - Epoch T_max/2: lr = eta_min (minimum)
    - Epoch T_max: lr = base_lr (returns to maximum)
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # Epoch 0: lr = 0 + (1 - 0) * (1 + cos(0)) / 2 = 1.0
    var lr0 = scheduler.get_lr(epoch=0)
    assert_almost_equal(lr0, 1.0)

    # Epoch 50 (halfway): lr = 0 + (1 - 0) * (1 + cos(pi)) / 2 = 0.0
    var lr50 = scheduler.get_lr(epoch=50)
    assert_almost_equal(lr50, 0.0, tolerance=1e-10)

    # Epoch 100 (end): lr = 0 + (1 - 0) * (1 + cos(2*pi)) / 2 = 1.0
    var lr100 = scheduler.get_lr(epoch=100)
    assert_almost_equal(lr100, 1.0, tolerance=1e-10)


fn test_cosine_scheduler_smooth_decay() raises:
    """Test CosineAnnealingLR provides smooth continuous decay.

    LR should decrease smoothly in first half (epochs 0 to T_max/2),
    not in discrete jumps like StepLR.
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # Test smooth decrease in first half
    var lr0 = scheduler.get_lr(epoch=0)
    var lr25 = scheduler.get_lr(epoch=25)
    var lr50 = scheduler.get_lr(epoch=50)

    # LR should decrease from epoch 0 to 50
    assert_greater(lr0, lr25)
    assert_greater(lr25, lr50)

    # Approximate expected values using cosine formula
    # lr25 ≈ (1 + cos(pi * 0.25)) / 2 ≈ 0.8536
    assert_almost_equal(lr25, 0.8536, tolerance=0.001)


# ============================================================================
# Eta_min (Minimum LR) Tests
# ============================================================================


fn test_cosine_scheduler_with_eta_min() raises:
    """Test CosineAnnealingLR respects minimum learning rate.

    With eta_min > 0:
    - LR oscillates between base_lr and eta_min
    - At T_max/2, LR = eta_min
    - At T_max, LR returns to base_lr
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.1)

    # Epoch 0: lr = base_lr
    var lr0 = scheduler.get_lr(epoch=0)
    assert_almost_equal(lr0, 1.0)

    # Epoch 50: lr = eta_min
    var lr50 = scheduler.get_lr(epoch=50)
    assert_almost_equal(lr50, 0.1, tolerance=1e-10)

    # Epoch 100: lr = base_lr
    var lr100 = scheduler.get_lr(epoch=100)
    assert_almost_equal(lr100, 1.0, tolerance=1e-10)


fn test_cosine_scheduler_eta_min_equals_base_lr() raises:
    """Test CosineAnnealingLR when eta_min equals base_lr.

    When eta_min = base_lr:
    - Cosine amplitude is zero
    - LR remains constant at base_lr
    """
    var scheduler = CosineAnnealingLR(base_lr=0.1, T_max=100, eta_min=0.1)

    # LR should remain constant for all epochs
    for epoch in range(0, 101):
        var lr = scheduler.get_lr(epoch)
        assert_almost_equal(lr, 0.1)


# ============================================================================
# T_max (Period) Tests
# ============================================================================


fn test_cosine_scheduler_different_t_max() raises:
    """Test CosineAnnealingLR with different T_max values.

    T_max determines the period of cosine curve:
    - Small T_max: Fast annealing
    - Large T_max: Slow annealing
    """
    # Fast annealing (T_max=10)
    var scheduler1 = CosineAnnealingLR(base_lr=1.0, T_max=10, eta_min=0.0)

    # Halfway point (epoch 5)
    var lr1_half = scheduler1.get_lr(5)
    assert_almost_equal(lr1_half, 0.0, tolerance=1e-10)

    # Slow annealing (T_max=100)
    var scheduler2 = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # Same epoch (5) should still be close to base_lr
    var lr2_early = scheduler2.get_lr(5)
    assert_greater(lr2_early, 0.9)


fn test_cosine_scheduler_beyond_t_max() raises:
    """Test CosineAnnealingLR behavior after T_max is reached.

    Implementation clamps epoch to T_max:
    - Epochs > T_max return same LR as T_max
    - No cosine restart (single cycle only)
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # LR at T_max
    var lr_at_t_max = scheduler.get_lr(100)
    assert_almost_equal(lr_at_t_max, 1.0, tolerance=1e-10)

    # LR beyond T_max (clamped)
    var lr_beyond = scheduler.get_lr(150)
    assert_almost_equal(lr_beyond, lr_at_t_max)


# ============================================================================
# Numerical Accuracy Tests
# ============================================================================


fn test_cosine_scheduler_matches_formula() raises:
    """Test CosineAnnealingLR matches cosine formula exactly.

    Formula: lr = eta_min + (base_lr - eta_min) * (1 + cos(pi * epoch / T_max)) / 2

    Verifies mathematical correctness at multiple points.
    """
    var base_lr: Float64 = 1.0
    var eta_min: Float64 = 0.1
    var T_max: Int = 100

    var scheduler = CosineAnnealingLR(base_lr=base_lr, T_max=T_max, eta_min=eta_min)

    # Test at several points
    for epoch in range(0, 101, 10):
        var actual_lr = scheduler.get_lr(epoch)

        # Compute expected LR using formula
        var progress = Float64(epoch) / Float64(T_max)
        var cosine_factor = (1.0 + cos(pi * progress)) / 2.0
        var expected_lr = eta_min + (base_lr - eta_min) * cosine_factor

        assert_almost_equal(actual_lr, expected_lr, tolerance=1e-10)


fn test_cosine_scheduler_quarter_points() raises:
    """Test CosineAnnealingLR at quarter-cycle points for precision.

    Verifies cosine values at 0%, 25%, 50%, 75%, 100% of cycle.
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # 0% (epoch 0): cos(0) = 1 → lr = 1.0
    assert_almost_equal(scheduler.get_lr(0), 1.0)

    # 25% (epoch 25): cos(pi/4) ≈ 0.707 → lr ≈ 0.8536
    var lr25 = scheduler.get_lr(25)
    var expected25 = (1.0 + cos(pi * 0.25)) / 2.0
    assert_almost_equal(lr25, expected25, tolerance=1e-10)

    # 50% (epoch 50): cos(pi/2) = 0 → lr = 0.0
    assert_almost_equal(scheduler.get_lr(50), 0.0, tolerance=1e-10)

    # 75% (epoch 75): cos(3pi/4) ≈ -0.707 → lr ≈ 0.1464
    var lr75 = scheduler.get_lr(75)
    var expected75 = (1.0 + cos(pi * 0.75)) / 2.0
    assert_almost_equal(lr75, expected75, tolerance=1e-10)

    # 100% (epoch 100): cos(pi) = -1 → lr = 1.0
    assert_almost_equal(scheduler.get_lr(100), 1.0, tolerance=1e-10)


# ============================================================================
# Edge Cases and Error Handling
# ============================================================================


fn test_cosine_scheduler_zero_t_max() raises:
    """Test CosineAnnealingLR with T_max=0.

    Implementation handles this gracefully by returning base_lr.
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=0, eta_min=0.0)

    # Should return base_lr (defensive behavior)
    assert_almost_equal(scheduler.get_lr(0), 1.0)
    assert_almost_equal(scheduler.get_lr(10), 1.0)


fn test_cosine_scheduler_negative_eta_min() raises:
    """Test CosineAnnealingLR with negative eta_min.

    While unusual, negative eta_min is mathematically valid.
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=-0.5)

    # At epoch 0: lr = base_lr
    assert_almost_equal(scheduler.get_lr(0), 1.0)

    # At epoch 50: lr = eta_min
    assert_almost_equal(scheduler.get_lr(50), -0.5, tolerance=1e-10)


# ============================================================================
# Property-Based Tests
# ============================================================================


fn test_cosine_scheduler_property_symmetric() raises:
    """Property: Cosine curve is symmetric around T_max/2.

    For eta_min = 0:
    - LR at epoch T should equal LR at epoch (T_max - T)
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # Check symmetry at several points
    for offset in range(0, 51, 10):
        var lr_left = scheduler.get_lr(offset)
        var lr_right = scheduler.get_lr(100 - offset)
        assert_almost_equal(lr_left, lr_right, tolerance=1e-10)


fn test_cosine_scheduler_property_bounded() raises:
    """Property: LR is always bounded by [eta_min, base_lr].

    For all epochs: eta_min <= LR <= base_lr
    """
    var base_lr: Float64 = 1.0
    var eta_min: Float64 = 0.1
    var scheduler = CosineAnnealingLR(base_lr=base_lr, T_max=100, eta_min=eta_min)

    for epoch in range(0, 101):
        var lr = scheduler.get_lr(epoch)

        # LR should be in bounds
        assert_greater_or_equal(lr, eta_min)
        assert_less_or_equal(lr, base_lr)


fn test_cosine_scheduler_property_smooth() raises:
    """Property: LR changes continuously (no discrete jumps).

    For small epoch steps, LR change should be small.
    """
    var scheduler = CosineAnnealingLR(base_lr=1.0, T_max=100, eta_min=0.0)

    # Check smoothness over entire range
    var prev_lr = scheduler.get_lr(0)
    for epoch in range(1, 101):
        var curr_lr = scheduler.get_lr(epoch)

        # Change should be small (< 0.05 per epoch for T_max=100)
        var change = abs(curr_lr - prev_lr)
        assert_less(change, 0.05)

        prev_lr = curr_lr


# ============================================================================
# Test Main
# ============================================================================


fn main() raises:
    """Run all CosineAnnealingLR scheduler tests."""
    print("Running CosineAnnealingLR core tests...")
    test_cosine_scheduler_initialization()
    test_cosine_scheduler_follows_cosine_curve()
    test_cosine_scheduler_smooth_decay()

    print("Running eta_min tests...")
    test_cosine_scheduler_with_eta_min()
    test_cosine_scheduler_eta_min_equals_base_lr()

    print("Running T_max tests...")
    test_cosine_scheduler_different_t_max()
    test_cosine_scheduler_beyond_t_max()

    print("Running numerical accuracy tests...")
    test_cosine_scheduler_matches_formula()
    test_cosine_scheduler_quarter_points()

    print("Running edge cases...")
    test_cosine_scheduler_zero_t_max()
    test_cosine_scheduler_negative_eta_min()

    print("Running property-based tests...")
    test_cosine_scheduler_property_symmetric()
    test_cosine_scheduler_property_bounded()
    test_cosine_scheduler_property_smooth()

    print("\nAll CosineAnnealingLR scheduler tests passed! ✓")
