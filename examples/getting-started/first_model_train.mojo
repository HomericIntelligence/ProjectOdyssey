"""Example: First Model - Complete Training Script

This example shows a complete training script for a digit classifier on MNIST.

Usage:
    pixi run mojo run examples/getting-started/first_model_train.mojo

See documentation: docs/getting-started/first_model.md
"""

from shared.training import Trainer, SGD, CrossEntropyLoss
from shared.training.callbacks import EarlyStopping, ModelCheckpoint
from shared.data import BatchLoader
from model import DigitClassifier
from prepare_data import prepare_mnist


fn main() raises:
    """Train the digit classifier."""

    print("=" * 50)
    print("Training Digit Classifier")
    print("=" * 50)

    # Step 1: Load data
    var train_data, test_data = prepare_mnist()

    # Step 2: Create data loaders
    var train_loader = BatchLoader(
        train_data,
        batch_size=32,
        shuffle=True,
        drop_last=True
    )

    var test_loader = BatchLoader(
        test_data,
        batch_size=32,
        shuffle=False
    )

    # Step 3: Create model
    var model = DigitClassifier()
    print("\nModel architecture:")
    print(model.model.summary())

    # Step 4: Configure optimizer
    var optimizer = SGD(
        learning_rate=0.01,
        momentum=0.9
    )

    # Step 5: Configure loss function
    var loss_fn = CrossEntropyLoss()

    # Step 6: Create trainer
    var trainer = Trainer(
        model=model,
        optimizer=optimizer,
        loss_fn=loss_fn
    )

    # Step 7: Add callbacks
    trainer.add_callback(
        EarlyStopping(patience=3, min_delta=0.001)
    )
    trainer.add_callback(
        ModelCheckpoint(filepath="best_model.mojo", save_best_only=True)
    )

    # Step 8: Train the model
    print("\nStarting training...")
    trainer.train(
        train_loader=train_loader,
        val_loader=test_loader,
        epochs=10,
        verbose=True
    )

    print("\nTraining complete!")
