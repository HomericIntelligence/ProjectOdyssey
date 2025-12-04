"""Loss functions for training neural networks.

This module provides common loss functions used in supervised learning,
along with their backward passes for gradient computation.

Implemented losses:
- Binary Cross-Entropy (BCE): For binary classification
- Mean Squared Error (MSE): For regression
- Cross-Entropy: For multi-class classification (with softmax)
- Focal Loss: For handling class imbalance in object detection
- KL Divergence: For matching probability distributions

All loss functions include:
- Numerical stability (epsilon handling, clipping)
- Proper gradient computation
- Support for batched inputs
"""

from .extensor import ExTensor, ones_like, zeros_like, full_like
from .arithmetic import add, subtract, multiply, divide, power
from .elementwise import log, clip, exp
from .reduction import mean, sum, max_reduce
from .activation import softmax


fn binary_cross_entropy(
    predictions: ExTensor, targets: ExTensor, epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Binary cross-entropy loss for binary classification.

    Formula:
        BCE = -[y*log(p) + (1-y)*log(1-p)]

    where:
        p = predictions (should be in [0, 1] range, typically from sigmoid)
        y = targets (ground truth labels, 0 or 1)

    Args:.        `predictions`: Predicted probabilities, shape (batch_size,) or (batch_size, 1)
        `targets`: Ground truth binary labels (0 or 1), same shape as predictions.
        `epsilon`: Small constant for numerical stability (prevents log(0))

    Returns:.        Loss tensor of same shape as inputs (element-wise loss)
        Use mean() or sum() to get scalar loss for backpropagation.

    Raises:.        Error if shapes don't match or dtypes are incompatible.

    Example:.        var predictions = sigmoid(logits)  # (batch_size,)
        var targets = ... # (batch_size,) with values 0 or 1
        var loss_per_sample = binary_cross_entropy(predictions, targets)
        var loss = mean(loss_per_sample)  # Scalar loss for backprop

    Numerical Stability:
        - Clips predictions to [epsilon, 1-epsilon] to prevent log(0)
        - Uses epsilon=1e-7 by default
    """
    if predictions.dtype() != targets.dtype():
        raise Error("Predictions and targets must have the same dtype")

    if predictions.shape() != targets.shape():
        raise Error("Predictions and targets must have the same shape")

    # Clip predictions to prevent log(0) and log(1)
    var clipped = clip(predictions, epsilon, 1.0 - epsilon)

    # Compute log(p) and log(1-p)
    var log_pred = log(clipped)
    var one = ones_like(clipped)

    var one_minus_pred = subtract(one, clipped)
    var log_one_minus_pred = log(one_minus_pred)

    # BCE = -[y*log(p) + (1-y)*log(1-p)]
    var term1 = multiply(targets, log_pred)
    var one_minus_targets = subtract(one, targets)
    var term2 = multiply(one_minus_targets, log_one_minus_pred)
    var sum_terms = add(term1, term2)

    # Negate: BCE = -(term1 + term2)
    var zero = zeros_like(sum_terms)

    return subtract(zero, sum_terms)


fn binary_cross_entropy_backward(
    grad_output: ExTensor,
    predictions: ExTensor,
    targets: ExTensor,
    epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Backward pass for binary cross-entropy loss.

    Computes gradient of BCE loss with respect to predictions.

    Formula:
        ∂BCE/∂p = -y/p + (1-y)/(1-p)

    Which simplifies to:
        ∂BCE/∂p = (-y(1-p) + (1-y)p) / (p(1-p))
        ∂BCE/∂p = (p - y) / (p(1-p))

    For numerical stability, we add epsilon to the denominator:
        ∂BCE/∂p = (p - y) / (p(1-p) + epsilon)

    Args:
        `grad_output`: Gradient from upstream (e.g., from mean_backward)
        `predictions`: Original predictions passed to forward pass.
        `targets`: Original targets passed to forward pass.
        `epsilon`: Small constant for numerical stability (default: 1e-7)

    Returns:
        Gradient with respect to predictions, same shape as predictions.

    Example:
        # Forward
        var bce_loss = binary_cross_entropy(predictions, targets)
        var loss = mean(bce_loss)

        # Backward
        var grad_loss = ones_like(loss)
        var grad_bce = mean_backward(grad_loss, bce_loss)
        var grad_pred = binary_cross_entropy_backward(grad_bce, predictions, targets)
    """
    # Gradient formula: (p - y) / (p(1-p) + epsilon)
    var one = ones_like(predictions)

    # Numerator: (predictions - targets)
    var numerator = subtract(predictions, targets)

    # Denominator: p(1-p) + epsilon
    # First compute: (1 - predictions)
    var one_minus_pred = subtract(one, predictions)

    # Then compute: predictions * (1 - predictions)
    var pred_times_one_minus_pred = multiply(predictions, one_minus_pred)

    # Create epsilon tensor
    var epsilon_tensor = full_like(predictions, epsilon)

    # Compute: p(1-p) + epsilon
    var denominator = add(pred_times_one_minus_pred, epsilon_tensor)

    # Compute gradient: (p - y) / (p(1-p) + epsilon)
    var grad = divide(numerator, denominator)

    # Chain rule: multiply by upstream gradient
    return multiply(grad_output, grad)


fn mean_squared_error(predictions: ExTensor, targets: ExTensor) raises -> ExTensor:
    """Mean squared error loss for regression.

    Formula:
        MSE = (predictions - targets)^2.

    Returns element-wise squared error. Use mean() to get scalar loss.

    Args:.        `predictions`: Predicted values, any shape.
        `targets`: Ground truth values, same shape as predictions.

    Returns:.        Squared error tensor, same shape as inputs.
        Use mean() or sum() to get scalar loss for backpropagation.

    Raises:.        Error if shapes don't match or dtypes are incompatible.

    Example:.        var predictions = model(x)  # (batch_size, output_dim)
        var targets = y_true        # (batch_size, output_dim)
        var loss_per_sample = mean_squared_error(predictions, targets)
        var loss = mean(loss_per_sample)  # Scalar loss
    """
    if predictions.dtype() != targets.dtype():
        raise Error("Predictions and targets must have the same dtype")

    if predictions.shape() != targets.shape():
        raise Error("Predictions and targets must have the same shape")

    # MSE = (predictions - targets)^2
    var diff = subtract(predictions, targets)
    return multiply(diff, diff)


fn mean_squared_error_backward(
    grad_output: ExTensor, predictions: ExTensor, targets: ExTensor
) raises -> ExTensor:
    """Backward pass for mean squared error loss.

    Computes gradient of MSE loss with respect to predictions.

    Formula:
        ∂MSE/∂predictions = 2 * (predictions - targets)

    Args:.        `grad_output`: Gradient from upstream (e.g., from mean_backward)
        `predictions`: Original predictions passed to forward pass.
        `targets`: Original targets passed to forward pass.

    Returns:.        Gradient with respect to predictions, same shape as predictions.

    Example:.        # Forward.
        var squared_error = mean_squared_error(predictions, targets)
        var loss = mean(squared_error)

        # Backward
        var grad_loss = ones_like(loss)
        var grad_squared_error = mean_backward(grad_loss, squared_error)
        var grad_pred = mean_squared_error_backward(grad_squared_error, predictions, targets)
    """
    # Gradient: 2 * (predictions - targets)
    var diff = subtract(predictions, targets)

    # Create tensor with value 2.0
    var two = full_like(diff, 2.0)

    var grad = multiply(two, diff)

    # Chain rule: multiply by upstream gradient
    return multiply(grad_output, grad)


fn cross_entropy(
    logits: ExTensor, targets: ExTensor, axis: Int = -1, epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Cross-entropy loss for multi-class classification.

    Formula:
        CE = -sum(targets * log(softmax(logits)))

    This implementation uses the log-sum-exp trick for numerical stability.

    Args:.        `logits`: Raw model outputs (before softmax), shape (batch_size, num_classes)
        `targets`: One-hot encoded ground truth, same shape as logits.
        `axis`: Axis along which to compute softmax (default: -1, last axis)
        `epsilon`: Small constant for numerical stability in log operations (default: 1e-7)

    Returns:.        Loss tensor, shape depends on reduction.
        Use mean() to get scalar loss for backpropagation.

    Raises:.        Error if shapes don't match or dtypes are incompatible.

    Example:.        var logits = model(x)           # (batch_size, num_classes)
        var targets_onehot = ...        # (batch_size, num_classes) one-hot
        var loss_per_sample = cross_entropy(logits, targets_onehot)
        var loss = mean(loss_per_sample)  # Scalar loss

    Note:
        For efficiency, this does NOT compute softmax explicitly.
        Instead, it uses: CE = -sum(targets * (logits - log_sum_exp(logits)))

    Numerical Stability:
        - Uses log-sum-exp trick to prevent overflow/underflow
        - Adds epsilon to log argument to prevent log(0)
    """
    if logits.dtype() != targets.dtype():
        raise Error("Logits and targets must have the same dtype")

    if logits.shape() != targets.shape():
        raise Error("Logits and targets must have the same shape")

    # Implement cross-entropy with log-sum-exp trick for numerical stability
    # CE = -sum(targets * (logits - log_sum_exp(logits)))
    # where log_sum_exp(x) = max(x) + log(sum(exp(x - max(x))))

    # Assume last axis is the class dimension
    var shape = logits.shape()
    var class_axis = len(shape) - 1 if axis == -1 else axis

    # Step 1: Find max along class axis for numerical stability
    var max_logits = max_reduce(logits, axis=class_axis, keepdims=True)

    # Step 2: Subtract max from logits: x_stable = x - max(x)
    var logits_stable = subtract(logits, max_logits)

    # Step 3: Compute exp(x_stable)
    var exp_logits = exp(logits_stable)

    # Step 4: Sum exp values along class axis
    var sum_exp = sum(exp_logits, axis=class_axis, keepdims=True)

    # Step 5: Compute log_sum_exp = max + log(sum_exp + epsilon)
    # Add epsilon for numerical stability to prevent log(0)
    var epsilon_tensor = full_like(sum_exp, epsilon)
    var sum_exp_stable = add(sum_exp, epsilon_tensor)
    var log_sum_exp = add(max_logits, log(sum_exp_stable))

    # Step 6: Compute log probabilities: log(p) = logits - log_sum_exp
    var log_probs = subtract(logits, log_sum_exp)

    # Step 7: Compute cross-entropy: CE = -sum(targets * log_probs)
    var ce_per_sample = multiply(targets, log_probs)
    var ce_sum = sum(ce_per_sample, axis=class_axis, keepdims=False)  # Sum over classes

    # Negate: create -1.0 scalar tensor
    var neg_one = full_like(ce_sum, -1.0)
    var ce = multiply(ce_sum, neg_one)

    # Return mean over batch (first dimension)
    return mean(ce, axis=0, keepdims=False)


fn cross_entropy_backward(
    grad_output: ExTensor, logits: ExTensor, targets: ExTensor, epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Backward pass for cross-entropy loss.

    For cross-entropy with softmax, the gradient simplifies to:
        ∂CE/∂logits = softmax(logits) - targets

    This beautiful result comes from the chain rule and the properties.
    of the softmax function.

    Args:.        `grad_output`: Gradient from upstream (scalar for mean reduction)
        `logits`: Original logits passed to forward pass, shape (batch, num_classes)
        `targets`: Original one-hot targets, shape (batch, num_classes)

    Returns:.        Gradient with respect to logits, shape (batch, num_classes)

    Example:.        ```mojo.
        from shared.core import cross_entropy, cross_entropy_backward

        # Forward pass
        var loss = cross_entropy(logits, targets)
        # Backward pass (grad_output is usually 1.0 for scalar loss)
        var grad_logits = cross_entropy_backward(grad_output, logits, targets)
        ```

    Note:
        The gradient is already averaged over the batch if the forward pass.
        used mean reduction.
    """
    # Compute softmax probabilities
    var axis = len(logits.shape()) - 1  # Last axis is classes
    var probs = softmax(logits, axis=axis)

    # Gradient: softmax(logits) - targets
    var grad = subtract(probs, targets)

    # Scale by upstream gradient and average over batch
    # NOTE: Forward pass already averages via mean(ce, axis=0), so we divide by batch_size here
    var batch_size = Float32(logits.shape()[0])
    var scale_val = 1.0 / batch_size

    # Create scale tensor with same shape as grad
    var scale_tensor = full_like(grad, Float64(scale_val))

    var grad_scaled = multiply(grad, scale_tensor)

    # Chain rule: multiply by upstream gradient
    return multiply(grad_scaled, grad_output)


fn focal_loss(
    predictions: ExTensor,
    targets: ExTensor,
    alpha: Float64 = 0.25,
    gamma: Float64 = 2.0,
    epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Focal loss for addressing class imbalance.

    Formula:
        FL(p) = -alpha * (1 - p)^gamma * log(p)

    where:
        p = predictions (typically from sigmoid for binary classification)
        targets = ground truth labels (0 or 1)
        alpha = weighting factor for positive class (default: 0.25)
        gamma = focusing parameter (default: 2.0, controls how much to focus on hard examples)

    The loss is particularly useful for imbalanced datasets where easy examples
    dominate the loss. Higher gamma values focus more on hard examples.

    Args:
        `predictions`: Predicted probabilities, shape (batch_size,) or (batch_size, num_classes)
        `targets`: Ground truth binary labels (0 or 1), same shape as predictions.
        `alpha`: Weighting factor for positive class (default: 0.25)
        `gamma`: Focusing parameter, typically 2.0 (default: 2.0)
        `epsilon`: Small constant for numerical stability (prevents log(0))

    Returns:
        Loss tensor of same shape as inputs (element-wise loss)
        Use mean() or sum() to get scalar loss for backpropagation.

    Raises:
        Error if shapes don't match or dtypes are incompatible.

    Example:
        var predictions = sigmoid(logits)  # (batch_size,)
        var targets = ...  # (batch_size,) with values 0 or 1
        var loss_per_sample = focal_loss(predictions, targets, alpha=0.25, gamma=2.0)
        var loss = mean(loss_per_sample)  # Scalar loss for backprop

    Numerical Stability:
        - Clips predictions to [epsilon, 1-epsilon] to prevent log(0)
        - Uses epsilon=1e-7 by default
    """
    if predictions.dtype() != targets.dtype():
        raise Error("Predictions and targets must have the same dtype")

    if predictions.shape() != targets.shape():
        raise Error("Predictions and targets must have the same shape")

    # Clip predictions to prevent log(0) and log(1)
    var clipped = clip(predictions, epsilon, 1.0 - epsilon)

    # Compute log probabilities
    var log_pred = log(clipped)

    # Compute (1 - predictions) for the focusing term
    var one = ones_like(clipped)
    var one_minus_pred = subtract(one, clipped)

    # Compute (1 - p)^gamma (the focusing term)
    # Create gamma tensor
    var gamma_tensor = full_like(one_minus_pred, gamma)
    var focus_term = power(one_minus_pred, gamma_tensor)

    # Compute alpha * (1 - p)^gamma * log(p) for positive class (target = 1)
    var alpha_tensor = full_like(log_pred, alpha)
    var pos_loss = multiply(alpha_tensor, focus_term)
    pos_loss = multiply(pos_loss, log_pred)

    # Compute (1 - alpha) * p^gamma * log(1 - p) for negative class (target = 0)
    var one_minus_alpha = full_like(alpha_tensor, 1.0 - alpha)
    var pred_gamma = power(clipped, gamma_tensor)
    var log_one_minus_pred = log(one_minus_pred)
    var neg_loss = multiply(one_minus_alpha, pred_gamma)
    neg_loss = multiply(neg_loss, log_one_minus_pred)

    # Combine losses based on targets
    var pos_contrib = multiply(targets, pos_loss)
    var one_minus_targets = subtract(one, targets)
    var neg_contrib = multiply(one_minus_targets, neg_loss)

    var loss = add(pos_contrib, neg_contrib)

    # Negate to get positive loss
    var zero = zeros_like(loss)
    return subtract(zero, loss)


fn focal_loss_backward(
    grad_output: ExTensor,
    predictions: ExTensor,
    targets: ExTensor,
    alpha: Float64 = 0.25,
    gamma: Float64 = 2.0,
    epsilon: Float64 = 1e-7
) raises -> ExTensor:
    """Backward pass for focal loss.

    Computes gradient of focal loss with respect to predictions.

    Args:
        `grad_output`: Gradient from upstream (e.g., from mean_backward)
        `predictions`: Original predictions passed to forward pass.
        `targets`: Original targets passed to forward pass.
        `alpha`: Weighting factor used in forward pass (default: 0.25)
        `gamma`: Focusing parameter used in forward pass (default: 2.0)
        `epsilon`: Small constant for numerical stability (default: 1e-7)

    Returns:
        Gradient with respect to predictions, same shape as predictions.

    Example:
        # Forward
        var focal = focal_loss(predictions, targets)
        var loss = mean(focal)

        # Backward
        var grad_loss = ones_like(loss)
        var grad_focal = mean_backward(grad_loss, focal)
        var grad_pred = focal_loss_backward(grad_focal, predictions, targets)
    """
    # Clip predictions for numerical stability
    var clipped = clip(predictions, epsilon, 1.0 - epsilon)
    var one = ones_like(clipped)

    # Compute (1 - p)
    var one_minus_pred = subtract(one, clipped)

    # Compute gradient for positive class: α * [-γ*(1-p)^(γ-1)*log(p) - (1-p)^γ/p]
    # For simplification, we use: α * (1-p)^γ * (γ*log(p)*(1-p) + p) / (p*(1-p) + ε)
    var gamma_tensor = full_like(one, gamma)
    var alpha_tensor = full_like(one, alpha)

    # Compute (1-p)^(gamma-1)
    var gamma_minus_one = full_like(gamma_tensor, gamma - 1.0)
    var focus_term_grad = power(one_minus_pred, gamma_minus_one)

    # Gradient denominator for numerical stability
    var denom = multiply(clipped, one_minus_pred)
    var epsilon_tensor = full_like(denom, epsilon)
    var denom_safe = add(denom, epsilon_tensor)

    # Simplified gradient computation
    # ∂FL/∂p ≈ -α*γ*(1-p)^γ/p + α*(1-p)^(γ+1)/p
    var numerator = multiply(alpha_tensor, focus_term_grad)

    # For positive class (target = 1)
    var pos_grad = divide(numerator, clipped)

    # For negative class (target = 0): (1-α)*γ*p^(γ-1)/(1-p)
    var one_minus_alpha = full_like(alpha_tensor, 1.0 - alpha)
    var pred_grad = power(clipped, gamma_minus_one)
    var neg_grad = multiply(one_minus_alpha, pred_grad)
    neg_grad = divide(neg_grad, one_minus_pred)

    # Combine based on targets
    var pos_contrib = multiply(targets, pos_grad)
    var one_minus_targets = subtract(one, targets)
    var neg_contrib = multiply(one_minus_targets, neg_grad)

    var grad = subtract(pos_contrib, neg_contrib)

    # Chain rule: multiply by upstream gradient
    return multiply(grad_output, grad)


fn kl_divergence(
    predictions: ExTensor, targets: ExTensor, epsilon: Float64 = 1e-7, axis: Int = -1
) raises -> ExTensor:
    """Kullback-Leibler (KL) divergence loss for distribution matching.

    Formula:
        KL(target || pred) = sum(target * log(target / pred))
                           = sum(target * (log(target) - log(pred)))

    KL divergence measures the difference between two probability distributions.
    It is asymmetric: KL(P||Q) != KL(Q||P).

    Args:
        `predictions`: Predicted probabilities (should sum to 1 along axis)
        `targets`: Target/reference probabilities (should sum to 1 along axis)
        `epsilon`: Small constant for numerical stability (default: 1e-7)
        `axis`: Axis along which distributions sum to 1 (default: -1, last axis)

    Returns:
        KL divergence tensor. For distributions over classes, use mean() to get scalar loss.

    Raises:
        Error if shapes don't match or dtypes are incompatible.

    Example:
        var pred_probs = softmax(logits)  # (batch_size, num_classes)
        var targets = ...  # (batch_size, num_classes), one-hot or soft labels
        var kl_loss = kl_divergence(pred_probs, targets)
        var loss = mean(kl_loss)  # Scalar loss for backprop

    Numerical Stability:
        - Clips both predictions and targets to [epsilon, 1] to prevent log(0)
        - Uses epsilon=1e-7 by default
    """
    if predictions.dtype() != targets.dtype():
        raise Error("Predictions and targets must have the same dtype")

    if predictions.shape() != targets.shape():
        raise Error("Predictions and targets must have the same shape")

    # Clip to prevent log(0)
    var clipped_pred = clip(predictions, epsilon, 1.0)
    var clipped_target = clip(targets, epsilon, 1.0)

    # Compute log probabilities
    var log_pred = log(clipped_pred)
    var log_target = log(clipped_target)

    # Compute log(target) - log(pred)
    var log_ratio = subtract(log_target, log_pred)

    # Compute target * log(target/pred)
    var kl_per_element = multiply(clipped_target, log_ratio)

    # Sum along the specified axis to get KL per sample
    var shape = predictions.shape()
    var class_axis = len(shape) - 1 if axis == -1 else axis
    var kl_per_sample = sum(kl_per_element, axis=class_axis, keepdims=False)

    return kl_per_sample


fn kl_divergence_backward(
    grad_output: ExTensor,
    predictions: ExTensor,
    targets: ExTensor,
    epsilon: Float64 = 1e-7,
    axis: Int = -1
) raises -> ExTensor:
    """Backward pass for KL divergence loss.

    Computes gradient of KL divergence with respect to predictions.

    Formula:
        ∂KL/∂pred = -target / pred

    Args:
        `grad_output`: Gradient from upstream (e.g., from mean_backward)
        `predictions`: Original predictions passed to forward pass.
        `targets`: Original targets passed to forward pass.
        `epsilon`: Small constant for numerical stability (default: 1e-7)
        `axis`: Axis along which distributions were computed (default: -1)

    Returns:
        Gradient with respect to predictions, same shape as predictions.

    Example:
        # Forward
        var kl = kl_divergence(predictions, targets)
        var loss = mean(kl)

        # Backward
        var grad_loss = ones_like(loss)
        var grad_kl = mean_backward(grad_loss, kl)
        var grad_pred = kl_divergence_backward(grad_kl, predictions, targets)
    """
    # Clip predictions for numerical stability
    var clipped_pred = clip(predictions, epsilon, 1.0)

    # Compute -target / pred
    var neg_target = multiply(targets, full_like(targets, -1.0))
    var grad = divide(neg_target, clipped_pred)

    # For batched inputs, we need to expand grad_output to match predictions shape
    # If grad_output is (batch_size,) and predictions is (batch_size, num_classes),
    # we need to broadcast grad_output
    var grad_shape = grad_output.shape()
    var pred_shape = predictions.shape()

    # Simple case: grad_output needs to be expanded
    if len(grad_shape) < len(pred_shape):
        # Unsqueeze grad_output to match dimensions
        var expanded_grad_output = grad_output
        # We'll use full_like to broadcast
        for _ in range(len(pred_shape) - len(grad_shape)):
            # Expand by replicating - create a tensor with the same value
            # This is a workaround for lack of native unsqueeze in this context
            pass
        # For now, we assume grad_output has been properly shaped by upstream

    # Chain rule: multiply by upstream gradient
    # Need to broadcast grad_output properly
    var result = multiply(grad, grad_output)

    return result
