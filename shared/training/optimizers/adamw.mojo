"""AdamW optimizer (Adam with decoupled Weight Decay).

This module provides the AdamW optimizer for updating model parameters
during training using adaptive learning rates with decoupled weight decay.

AdamW extends Adam by applying weight decay in a decoupled manner:
- First apply the Adam update (without weight decay in the gradient)
- Then apply weight decay directly to parameters: params *= (1 - lr * weight_decay)

This differs from L2 regularization (used in standard Adam) where weight decay
is added to the gradient, which interacts with the adaptive learning rate.

Key differences from Adam:
- Weight decay is applied AFTER the Adam update, not mixed into gradients
- Weight decay magnitude is independent of learning rate schedule changes
- Better empirical results in many cases (especially for large models)

Standard AdamW update rule:
    m = beta1 * m + (1 - beta1) * gradients
    v = beta2 * v + (1 - beta2) * gradients^2
    m_hat = m / (1 - beta1^t)  # Bias correction
    v_hat = v / (1 - beta2^t)  # Bias correction
    params = params - learning_rate * m_hat / (sqrt(v_hat) + epsilon)
    params = params * (1 - learning_rate * weight_decay)  # Decoupled weight decay

Reference:
    Loshchilov, I., & Hutter, F. (2019). Decoupled Weight Decay Regularization.
    In International Conference on Learning Representations (ICLR).
"""

from shared.core.extensor import ExTensor
from shared.core.arithmetic import subtract, multiply, add, divide, power
from shared.core.arithmetic_simd import subtract_simd, multiply_simd, add_simd, divide_simd
from shared.core.elementwise import sqrt
from shared.core.extensor import full_like, ones_like


fn adamw_step(
    params: ExTensor,
    gradients: ExTensor,
    m: ExTensor,
    v: ExTensor,
    t: Int,
    learning_rate: Float64,
    beta1: Float64 = 0.9,
    beta2: Float64 = 0.999,
    epsilon: Float64 = 1e-8,
    weight_decay: Float64 = 0.01
) raises -> Tuple[ExTensor, ExTensor, ExTensor]:
    """Perform a single AdamW optimization step - pure functional.

    Returns new parameters, new first moment (m), and new second moment (v).
    Caller manages all state including timestep tracking.

    AdamW applies weight decay in a decoupled manner:
    1. First applies standard Adam update (without weight decay in gradient)
    2. Then applies: params = params * (1 - lr * weight_decay)

    Args:
        params: Model parameters to update.
        gradients: Gradients of loss with respect to params.
        m: First moment estimates (exponential moving average of gradients).
        v: Second moment estimates (exponential moving average of squared gradients).
        t: Current timestep (starts at 1, increments each step).
        learning_rate: Step size for parameter updates.
        beta1: Exponential decay rate for first moment (default: 0.9).
        beta2: Exponential decay rate for second moment (default: 0.999).
        epsilon: Small constant for numerical stability (default: 1e-8).
        weight_decay: Decoupled weight decay factor (default: 0.01).

    Returns:
        Tuple of (new_params, new_m, new_v)

    Example (AdamW with weight decay):
        ```mojo
        from shared.core import ExTensor, zeros_like
        from shared.training.optimizers import adamw_step

        var W = xavier_uniform(784, 128, DType.float32)
        var m = zeros_like(W)
        var v = zeros_like(W)
        var t = 1

        # Training loop
        for epoch in range(100):
            var grad_W = ...  # Compute gradients
            (W, m, v) = adamw_step(W, grad_W, m, v, t, lr=0.001, weight_decay=0.01)
            t += 1
        ```

    Note:
        This is a pure function - it returns new state rather than mutating.
        Caller must capture all three return values and update their variables.
        Timestep t must be tracked by caller and incremented after each step.

        Weight decay is applied AFTER the Adam update, independently of the
        learning rate. This differs from L2 regularization where weight decay
        is mixed into the gradient and scaled by the adaptive learning rate.
    """
    if params.shape() != gradients.shape():
        raise Error("Parameters and gradients must have the same shape")

    if params.dtype() != gradients.dtype():
        raise Error("Parameters and gradients must have the same dtype")

    if m.numel() == 0 or v.numel() == 0:
        raise Error("Moment buffers (m and v) must be initialized (use zeros_like(params))")

    if t <= 0:
        raise Error("Timestep t must be positive (starts at 1)")

    # Apply standard Adam update WITHOUT weight decay in gradient
    # (This is the key difference from standard Adam)
    var effective_gradients = gradients

    # Update biased first moment estimate (SIMD optimized)
    # m = beta1 * m + (1 - beta1) * grad
    var beta1_tensor = full_like(m, beta1)
    var one_minus_beta1 = full_like(m, 1.0 - beta1)

    var m_decay = multiply_simd(beta1_tensor, m)
    var grad_term = multiply_simd(one_minus_beta1, effective_gradients)
    var new_m = add_simd(m_decay, grad_term)

    # Update biased second moment estimate (SIMD optimized)
    # v = beta2 * v + (1 - beta2) * grad^2
    var beta2_tensor = full_like(v, beta2)
    var one_minus_beta2 = full_like(v, 1.0 - beta2)

    var v_decay = multiply_simd(beta2_tensor, v)
    var grad_squared = multiply_simd(effective_gradients, effective_gradients)
    var grad_squared_term = multiply_simd(one_minus_beta2, grad_squared)
    var new_v = add_simd(v_decay, grad_squared_term)

    # Compute bias-corrected first moment (SIMD optimized)
    # m_hat = m / (1 - beta1^t)
    var bias_correction1 = 1.0 - pow(beta1, Float64(t))
    var bc1_tensor = full_like(new_m, bias_correction1)
    var m_hat = divide_simd(new_m, bc1_tensor)

    # Compute bias-corrected second moment (SIMD optimized)
    # v_hat = v / (1 - beta2^t)
    var bias_correction2 = 1.0 - pow(beta2, Float64(t))
    var bc2_tensor = full_like(new_v, bias_correction2)
    var v_hat = divide_simd(new_v, bc2_tensor)

    # Compute parameter update (SIMD optimized)
    # params = params - lr * m_hat / (sqrt(v_hat) + epsilon)
    var v_hat_sqrt = sqrt(v_hat)
    var epsilon_tensor = full_like(v_hat_sqrt, epsilon)
    var denominator = add_simd(v_hat_sqrt, epsilon_tensor)
    var update_direction = divide_simd(m_hat, denominator)

    var lr_tensor = full_like(params, learning_rate)
    var update = multiply_simd(lr_tensor, update_direction)
    var params_after_adam = subtract_simd(params, update)

    # Apply DECOUPLED weight decay (key feature of AdamW)
    # params = params * (1 - lr * weight_decay)
    # Note: weight decay is applied independently, after the Adam update
    if weight_decay > 0.0:
        var decay_factor = 1.0 - learning_rate * weight_decay
        var decay_tensor = full_like(params_after_adam, decay_factor)
        var new_params = multiply_simd(params_after_adam, decay_tensor)
        return (new_params, new_m, new_v)
    else:
        # No weight decay, return Adam result directly
        return (params_after_adam, new_m, new_v)


fn adamw_step_simple(
    params: ExTensor,
    gradients: ExTensor,
    m: ExTensor,
    v: ExTensor,
    t: Int,
    learning_rate: Float64
) raises -> Tuple[ExTensor, ExTensor, ExTensor]:
    """Simplified AdamW step with default hyperparameters.

    This is a convenience function for basic AdamW optimization.

    Formula:
        m = 0.9 * m + 0.1 * grad
        v = 0.999 * v + 0.001 * grad^2
        m_hat = m / (1 - 0.9^t)
        v_hat = v / (1 - 0.999^t)
        params = params - lr * m_hat / (sqrt(v_hat) + 1e-8)
        params = params * (1 - lr * 0.01)  # Default weight decay

    Args:
        params: Model parameters to update.
        gradients: Gradients of loss with respect to params.
        m: First moment estimate.
        v: Second moment estimate.
        t: Current timestep (starts at 1).
        learning_rate: Step size for parameter updates.

    Returns:
        Tuple of (new_params, new_m, new_v)

    Example:
        var W = xavier_uniform(784, 128, shape, DType.float32)
        var m = zeros_like(W)
        var v = zeros_like(W)
        var t = 1

        for epoch in range(100):
            var grad_W = ... # Computed gradients
            (W, m, v) = adamw_step_simple(W, grad_W, m, v, t, 0.001)
            t += 1
    """
    return adamw_step(
        params, gradients, m, v, t,
        learning_rate=learning_rate,
        beta1=0.9,
        beta2=0.999,
        epsilon=1e-8,
        weight_decay=0.01
    )
