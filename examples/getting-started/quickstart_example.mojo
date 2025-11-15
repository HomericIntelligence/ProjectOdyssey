"""Example: Quickstart - Simple Neural Network

This example demonstrates creating and training a basic neural network using
the ML Odyssey shared library.

Usage:
    pixi run mojo run examples/getting-started/quickstart_example.mojo

See documentation: docs/getting-started/quickstart.md
"""

from shared.core import Layer, Sequential
from shared.training import Trainer, SGD
from shared.data import TensorDataset, BatchLoader


fn main() raises:
    """Create and train a simple neural network."""

    # Create a simple network
    var model = Sequential([
        Layer("linear", input_size=784, output_size=128),
        Layer("relu"),
        Layer("linear", input_size=128, output_size=10),
    ])

    # Prepare data (using placeholder data for example)
    # In a real scenario, you would load actual training data
    var X_train = Tensor.randn(1000, 784)  # 1000 samples, 784 features
    var y_train = Tensor.randint(0, 10, shape=(1000,))  # 1000 labels (0-9)

    var train_data = TensorDataset(X_train, y_train)
    var train_loader = BatchLoader(train_data, batch_size=32, shuffle=True)

    # Train the model
    var optimizer = SGD(learning_rate=0.01)
    var trainer = Trainer(model, optimizer)

    trainer.train(train_loader, epochs=10)

    print("Training complete!")
