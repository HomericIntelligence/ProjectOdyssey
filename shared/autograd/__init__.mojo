"""Autograd - Automatic Differentiation for ML Odyssey.

This module provides automatic differentiation capabilities through a tape-based
autograd system similar to PyTorch's eager execution model.

Core Components:
- Variable: Tensor wrapper with gradient tracking
- GradientTape: Records operations for backward pass
- Backward engine: Computes gradients via chain rule

Public API:
    from shared.autograd import Variable, GradientTape

    # Create variables
    var x = Variable(data, requires_grad=True)
    var y = Variable(data, requires_grad=True)

    # Enable gradient tape
    var tape = GradientTape()
    tape.enable()

    # Forward pass (operations recorded)
    var z = x * y
    var loss = z.sum()

    # Backward pass (compute gradients)
    tape.backward()

    # Access gradients
    print(x.grad)  # ∂loss/∂x
    print(y.grad)  # ∂loss/∂y

Design Philosophy:
    This implementation prioritizes simplicity and correctness over performance,
    following YAGNI and KISS principles. Advanced features like graph optimization,
    checkpointing, and higher-order gradients are deliberately deferred.

Status:
    This is the initial autograd implementation providing the minimal API needed
    for training neural networks. It integrates with the existing 27 backward pass
    functions in shared/core/ (add_backward, multiply_backward, matmul_backward, etc.).

Next Steps:
    1. Implement backward pass dispatch (map operation -> backward function)
    2. Add Variable operations (arithmetic, matrix ops) that record in tape
    3. Integrate with loss functions and optimizers
    4. Write comprehensive tests comparing autograd vs manual gradients

References:
    - PyTorch Autograd: https://pytorch.org/tutorials/beginner/blitz/autograd_tutorial.html
    - Micrograd: https://github.com/karpathy/micrograd
    - Existing backward passes: /home/user/ml-odyssey/shared/core/
"""

from .variable import Variable
from .tape import GradientTape, TapeNode
from .optimizers import SGD

__all__ = ["Variable", "GradientTape", "TapeNode", "SGD"]
