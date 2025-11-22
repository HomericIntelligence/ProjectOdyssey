"""Functional autograd helpers - practical gradient computation.

This module provides helper functions for common gradient patterns,
avoiding the complexity of full computation graph autograd while still
reducing boilerplate code.

Design Philosophy:
- YAGNI: Implement helpers for patterns we actually use
- KISS: Simple function calls, not complex graph management
- Practical: Works today with current Mojo constraints

Each helper function computes gradients for a specific loss + reduction pattern.
This covers 90% of real use cases without the complexity of full autograd.

Example:
    from shared.autograd.functional import mse_loss_and_grad

    # Compute loss and gradient in one call
    var loss, grad = mse_loss_and_grad(predictions, targets)

    # Use gradient to update parameters
    parameters = subtract(parameters, multiply(learning_rate, grad))

Common Patterns Supported:
- MSE loss + mean reduction
- Binary cross-entropy loss + mean reduction
- Cross-entropy loss (includes softmax)
- Custom: Just chain the backward functions yourself!
"""

from ..core.extensor import ExTensor
from ..core.arithmetic import add, multiply, subtract, divide
from ..core.reduction import sum as tensor_sum, mean
from ..core.reduction import sum_backward, mean_backward
from ..core.loss import mean_squared_error, mean_squared_error_backward
from ..core.loss import binary_cross_entropy, binary_cross_entropy_backward
from ..core.loss import cross_entropy, cross_entropy_backward
from ..core.creation import ones
from collections.vector import DynamicVector


struct LossAndGrad:
    """Container for loss value and gradient.

    Returned by loss_and_grad helper functions.

    Attributes:
        loss: Scalar loss value
        grad: Gradient tensor (same shape as input)
    """

    var loss: ExTensor
    var grad: ExTensor

    fn __init__(inout self, loss: ExTensor, grad: ExTensor):
        """Initialize loss and gradient pair.

        Args:
            loss: Scalar loss tensor
            grad: Gradient tensor
        """
        self.loss = loss
        self.grad = grad


fn mse_loss_and_grad(
    predictions: ExTensor,
    targets: ExTensor
) raises -> LossAndGrad:
    """Compute MSE loss and gradient in one pass.

    Computes:
        loss = mean(mean_squared_error(predictions, targets))
        grad = ∂loss/∂predictions

    This is the most common loss pattern for regression.

    Args:
        predictions: Model predictions, any shape
        targets: Ground truth targets, same shape as predictions

    Returns:
        LossAndGrad containing scalar loss and gradient tensor

    Example:
        var result = mse_loss_and_grad(predictions, targets)
        print("Loss:", result.loss)

        # Update parameters
        params = subtract(params, multiply(lr_tensor, result.grad))
    """
    # Forward pass
    var squared_errors = mean_squared_error(predictions, targets)
    var loss = mean(squared_errors, axis=-1, keepdims=False)

    # Backward pass
    var grad_loss = ones(loss.shape(), loss.dtype())
    var grad_squared_errors = mean_backward(grad_loss, squared_errors.shape(), axis=-1)
    var grad_predictions = mean_squared_error_backward(
        grad_squared_errors, predictions, targets
    )

    return LossAndGrad(loss, grad_predictions)


fn bce_loss_and_grad(
    predictions: ExTensor,
    targets: ExTensor,
    epsilon: Float64 = 1e-7
) raises -> LossAndGrad:
    """Compute binary cross-entropy loss and gradient.

    Computes:
        loss = mean(binary_cross_entropy(predictions, targets))
        grad = ∂loss/∂predictions

    Used for binary classification (predictions from sigmoid).

    Args:
        predictions: Predicted probabilities in [0, 1], shape (batch_size,) or (batch_size, 1)
        targets: Binary labels (0 or 1), same shape as predictions
        epsilon: Small constant for numerical stability (default: 1e-7)

    Returns:
        LossAndGrad containing scalar loss and gradient tensor

    Example:
        var predictions = sigmoid(logits)
        var result = bce_loss_and_grad(predictions, targets)
        # Gradient flows back through sigmoid
    """
    # Forward pass
    var bce_per_sample = binary_cross_entropy(predictions, targets, epsilon)
    var loss = mean(bce_per_sample, axis=-1, keepdims=False)

    # Backward pass
    var grad_loss = ones(loss.shape(), loss.dtype())
    var grad_bce = mean_backward(grad_loss, bce_per_sample.shape(), axis=-1)
    var grad_predictions = binary_cross_entropy_backward(
        grad_bce, predictions, targets, epsilon
    )

    return LossAndGrad(loss, grad_predictions)


fn ce_loss_and_grad(
    logits: ExTensor,
    targets: ExTensor,
    epsilon: Float64 = 1e-7
) raises -> LossAndGrad:
    """Compute cross-entropy loss and gradient.

    Computes:
        loss = cross_entropy(logits, targets)  # Already includes mean
        grad = ∂loss/∂logits

    Used for multi-class classification. Includes softmax internally.

    Args:
        logits: Raw model outputs (before softmax), shape (batch_size, num_classes)
        targets: One-hot encoded labels, same shape as logits
        epsilon: Small constant for numerical stability (default: 1e-7)

    Returns:
        LossAndGrad containing scalar loss and gradient tensor

    Example:
        var logits = model(x)  # (batch_size, num_classes)
        var targets_onehot = one_hot(targets, num_classes)
        var result = ce_loss_and_grad(logits, targets_onehot)

    Note:
        cross_entropy already computes mean reduction internally,
        so no need for additional mean() call.
    """
    # Forward pass (cross_entropy already includes mean reduction)
    var loss = cross_entropy(logits, targets, axis=-1, epsilon=epsilon)

    # Backward pass
    var grad_loss = ones(loss.shape(), loss.dtype())
    var grad_logits = cross_entropy_backward(grad_loss, logits, targets, epsilon)

    return LossAndGrad(loss, grad_logits)


# Helper function for manual gradient computation patterns
fn compute_gradient(
    predictions: ExTensor,
    targets: ExTensor,
    loss_type: String = "mse"
) raises -> ExTensor:
    """Compute gradient for common loss functions.

    Convenience function that dispatches to the appropriate loss_and_grad
    helper based on loss_type string.

    Args:
        predictions: Model predictions
        targets: Ground truth targets
        loss_type: One of "mse", "bce", "ce" (default: "mse")

    Returns:
        Gradient tensor

    Example:
        var grad = compute_gradient(predictions, targets, "mse")

    Note:
        For more control, use the specific loss_and_grad functions directly.
    """
    if loss_type == "mse":
        var result = mse_loss_and_grad(predictions, targets)
        return result.grad
    elif loss_type == "bce":
        var result = bce_loss_and_grad(predictions, targets)
        return result.grad
    elif loss_type == "ce":
        var result = ce_loss_and_grad(predictions, targets)
        return result.grad
    else:
        raise Error("Unknown loss type: " + loss_type + ". Use 'mse', 'bce', or 'ce'.")

