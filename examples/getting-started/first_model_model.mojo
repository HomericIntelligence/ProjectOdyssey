"""Example: First Model - Model Definition

Defines the DigitClassifier model architecture.

Usage:
    from model import DigitClassifier

See documentation: docs/getting-started/first_model.md
"""

from shared.core import Layer, Sequential, ReLU, Softmax
from shared.core.types import Tensor


struct DigitClassifier:
    """Simple 3-layer neural network for digit classification."""

    var model: Sequential

    fn __init__(inout self):
        """Create a 3-layer network: 784 -> 128 -> 64 -> 10."""

        # Input: 784 pixels (28x28 flattened)
        # Hidden layer 1: 128 neurons with ReLU activation
        # Hidden layer 2: 64 neurons with ReLU activation
        # Output: 10 classes (digits 0-9) with Softmax

        self.model = Sequential([
            Layer("linear", input_size=784, output_size=128),
            ReLU(),
            Layer("linear", input_size=128, output_size=64),
            ReLU(),
            Layer("linear", input_size=64, output_size=10),
            Softmax(),
        ])

    fn forward(inout self, borrowed input: Tensor) -> Tensor:
        """Forward pass through the network."""
        return self.model.forward(input)

    fn parameters(inout self) -> List[Tensor]:
        """Get all trainable parameters."""
        return self.model.parameters()
