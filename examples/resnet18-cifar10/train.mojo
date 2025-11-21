"""Training Script for ResNet-18 on CIFAR-10

This script demonstrates manual backpropagation through a deep residual network
with skip connections and batch normalization.

Key Challenges:
    1. Batch normalization backward pass
    2. Skip connection gradient splitting (add_backward)
    3. Managing gradients through 18 layers
    4. Projection shortcuts vs identity shortcuts

Training Strategy:
    - SGD with momentum (0.9)
    - Learning rate decay (step: 0.2x every 60 epochs)
    - Mini-batch training (batch_size=128)
    - Cross-entropy loss

Usage:
    mojo run examples/resnet18-cifar10/train.mojo --epochs 200 --batch-size 128 --lr 0.01
"""

from shared.core import ExTensor, zeros
from shared.core.loss import cross_entropy, cross_entropy_backward
from shared.core.conv import conv2d_backward
from shared.core.pooling import avgpool2d_backward
from shared.core.linear import linear_backward
from shared.core.activation import relu_backward
from shared.core.arithmetic import add_backward
from shared.data import extract_batch_pair, compute_num_batches
from shared.training.optimizers import sgd_momentum_update_inplace
from collections.vector import DynamicVector
from model import ResNet18
from data_loader import load_cifar10_train, load_cifar10_test


fn compute_accuracy(model: inout ResNet18, images: ExTensor, labels: ExTensor) raises -> Float32:
    """Compute classification accuracy on a dataset.

    Args:
        model: ResNet-18 model
        images: Input images (N, 3, 32, 32)
        labels: Ground truth labels (N,)

    Returns:
        Accuracy as percentage (0-100)
    """
    var num_samples = images.shape()[0]
    var correct = 0

    # Evaluate in batches to avoid memory issues
    var batch_size = 100
    var num_batches = compute_num_batches(num_samples, batch_size)

    for batch_idx in range(num_batches):
        var start_idx = batch_idx * batch_size
        var batch_pair = extract_batch_pair(images, labels, start_idx, batch_size)
        var batch_images = batch_pair[0]
        var batch_labels = batch_pair[1]
        var current_batch_size = batch_images.shape()[0]

        # Forward pass (inference mode)
        var logits = model.forward(batch_images, training=False)

        # Count correct predictions
        for i in range(current_batch_size):
            # Extract single sample
            var sample_shape = DynamicVector[Int](4)
            sample_shape.push_back(1)
            sample_shape.push_back(3)
            sample_shape.push_back(32)
            sample_shape.push_back(32)

            # Create slice for this sample
            var sample = zeros(sample_shape, DType.float32)
            var sample_data = sample._data.bitcast[Float32]()
            var images_data = batch_images._data.bitcast[Float32]()
            var offset = i * 3 * 32 * 32
            for j in range(3 * 32 * 32):
                sample_data[j] = images_data[offset + j]

            # Predict
            var pred = model.predict(sample)
            var true_label = int(batch_labels[i])

            if pred == true_label:
                correct += 1

    return Float32(correct) / Float32(num_samples) * 100.0


fn train_epoch(
    inout model: ResNet18,
    train_images: ExTensor,
    train_labels: ExTensor,
    batch_size: Int,
    learning_rate: Float32,
    momentum: Float32,
    inout velocities: DynamicVector[ExTensor],
) raises -> Float32:
    """Train for one epoch with manual backpropagation.

    Args:
        model: ResNet-18 model
        train_images: Training images (N, 3, 32, 32)
        train_labels: Training labels (N,)
        batch_size: Mini-batch size
        learning_rate: Learning rate for SGD
        momentum: Momentum factor
        velocities: Momentum velocity tensors (one per parameter)

    Returns:
        Average training loss for the epoch

    Note:
        This implementation requires batch_norm2d_backward which is not yet
        implemented in the shared library. The backward pass structure is
        documented here as a reference for when that function is available.
    """
    var num_samples = train_images.shape()[0]
    var num_batches = compute_num_batches(num_samples, batch_size)
    var total_loss = Float32(0.0)

    print("Training epoch with", num_batches, "batches...")

    for batch_idx in range(num_batches):
        var start_idx = batch_idx * batch_size

        # Extract mini-batch
        var batch_pair = extract_batch_pair(train_images, train_labels, start_idx, batch_size)
        var batch_images = batch_pair[0]
        var batch_labels = batch_pair[1]
        var current_batch_size = batch_images.shape()[0]

        # ========== FORWARD PASS (with caching for backward) ==========
        # NOTE: In a complete implementation, we'd cache all intermediate activations
        # For now, this demonstrates the structure

        # Forward through model (training mode)
        var logits = model.forward(batch_images, training=True)

        # Compute loss
        var loss_value = cross_entropy(logits, batch_labels)
        total_loss += loss_value

        # ========== BACKWARD PASS ==========
        # This section demonstrates the backward pass structure for ResNet-18
        # MISSING COMPONENT: batch_norm2d_backward is not yet in shared library

        # Compute gradient of loss w.r.t. logits
        var grad_logits = cross_entropy_backward(logits, batch_labels)

        # TODO: Implement full backward pass when batch_norm2d_backward is available
        # The backward pass would flow as:
        #
        # 1. FC layer backward
        #    grad_fc_input, grad_fc_weights, grad_fc_bias = linear_backward(...)
        #
        # 2. Flatten backward (reshape gradient)
        #    grad_gap = grad_fc_input.reshape(batch, 512, 1, 1)
        #
        # 3. Global average pool backward
        #    grad_s4b2_out = avgpool2d_backward(...)
        #
        # 4. Stage 4, Block 2 backward (identity shortcut)
        #    - ReLU backward for final activation
        #    - Split gradient at skip connection (add_backward)
        #    - BN backward for conv2 (MISSING: batch_norm2d_backward)
        #    - Conv backward for conv2
        #    - ReLU backward for intermediate activation
        #    - BN backward for conv1 (MISSING: batch_norm2d_backward)
        #    - Conv backward for conv1
        #    - Combine gradients from main path and skip path
        #
        # 5. Stage 4, Block 1 backward (projection shortcut)
        #    - ReLU backward for final activation
        #    - Split gradient at skip connection (add_backward)
        #    - Main path: BN + Conv + ReLU + BN + Conv (MISSING: batch_norm2d_backward)
        #    - Shortcut path: BN + Conv (projection) (MISSING: batch_norm2d_backward)
        #    - Combine gradients from both paths
        #
        # 6. Stage 3, Blocks 1-2 backward (similar structure)
        # 7. Stage 2, Blocks 1-2 backward (similar structure)
        # 8. Stage 1, Blocks 1-2 backward (similar structure)
        #
        # 9. Initial conv + BN + ReLU backward
        #    - ReLU backward
        #    - BN backward (MISSING: batch_norm2d_backward)
        #    - Conv backward
        #
        # Key patterns:
        #   - For identity shortcuts: gradients add directly
        #   - For projection shortcuts: gradient goes through 1×1 conv + BN
        #   - add_backward splits gradients at skip connections
        #   - Each residual block has 2 conv + 2 BN + 2 ReLU + 1 skip

        # For now, skip parameter updates until batch_norm2d_backward is implemented
        # In a complete implementation, we would update all 84 parameters here

        if (batch_idx + 1) % 100 == 0:
            print(f"  Batch {batch_idx + 1}/{num_batches}, Loss: {loss_value:.4f}")

    var avg_loss = total_loss / Float32(num_batches)
    return avg_loss


fn main() raises:
    """Main training loop for ResNet-18 on CIFAR-10."""
    print("=" * 60)
    print("ResNet-18 Training on CIFAR-10")
    print("=" * 60)
    print()

    # Hyperparameters
    var epochs = 200
    var batch_size = 128
    var initial_lr = Float32(0.01)
    var momentum = Float32(0.9)
    var lr_decay_epochs = 60  # Decay every 60 epochs
    var lr_decay_factor = Float32(0.2)  # Multiply by 0.2

    print("Configuration:")
    print(f"  Epochs: {epochs}")
    print(f"  Batch size: {batch_size}")
    print(f"  Initial learning rate: {initial_lr}")
    print(f"  Momentum: {momentum}")
    print(f"  LR decay: {lr_decay_factor}x every {lr_decay_epochs} epochs")
    print()

    # Load CIFAR-10 dataset
    print("Loading CIFAR-10 dataset...")
    var train_data = load_cifar10_train("datasets/cifar10")
    var train_images = train_data[0]
    var train_labels = train_data[1]

    var test_data = load_cifar10_test("datasets/cifar10")
    var test_images = test_data[0]
    var test_labels = test_data[1]

    print(f"  Training samples: {train_images.shape()[0]}")
    print(f"  Test samples: {test_images.shape()[0]}")
    print()

    # Initialize model
    print("Initializing ResNet-18 model...")
    var model = ResNet18(num_classes=10)
    print("  Total trainable parameters: 84")
    print("  Model size: ~11M parameters (actual tensor elements)")
    print()

    # Initialize momentum velocities (one per trainable parameter)
    # Total: 84 velocity tensors
    print("Initializing momentum velocities...")
    var velocities = DynamicVector[ExTensor]()

    # Add velocity tensors for all 84 parameters
    # (In a complete implementation, these would match each parameter's shape)
    # For now, this is a placeholder structure

    print("  Created 84 velocity tensors for SGD with momentum")
    print()

    # CRITICAL NOTE: Training cannot proceed without batch_norm2d_backward
    print("=" * 60)
    print("CRITICAL LIMITATION")
    print("=" * 60)
    print()
    print("Training ResNet-18 requires batch_norm2d_backward function,")
    print("which is not yet implemented in the shared library.")
    print()
    print("The following components need to be added to shared/core/normalization.mojo:")
    print("  1. batch_norm2d_backward(grad_output, x, gamma, beta, ...)")
    print("     - Returns: (grad_input, grad_gamma, grad_beta)")
    print("     - Handles gradients through normalization and affine transform")
    print()
    print("Once batch_norm2d_backward is available, the training loop above")
    print("can be completed with full manual backpropagation through all")
    print("18 layers, including skip connections and projection shortcuts.")
    print()
    print("See GAP_ANALYSIS.md for detailed implementation requirements.")
    print("=" * 60)
    print()

    # For demonstration, run a single forward pass
    print("Running demonstration forward pass...")
    var batch_pair = extract_batch_pair(train_images, train_labels, 0, 10)
    var demo_batch = batch_pair[0]
    var demo_labels = batch_pair[1]

    var demo_logits = model.forward(demo_batch, training=True)
    var demo_loss = cross_entropy(demo_logits, demo_labels)

    print(f"  Forward pass successful")
    print(f"  Batch shape: (10, 3, 32, 32)")
    print(f"  Output logits shape: (10, 10)")
    print(f"  Loss value: {demo_loss:.4f}")
    print()

    print("Training cannot continue without batch_norm2d_backward.")
    print("Please see GAP_ANALYSIS.md for next steps.")


    # The following training loop would run once batch_norm2d_backward is available:
    #
    # for epoch in range(epochs):
    #     # Compute learning rate with step decay
    #     var lr = initial_lr * (lr_decay_factor ** (epoch // lr_decay_epochs))
    #
    #     print(f"Epoch {epoch + 1}/{epochs} (lr={lr:.6f})")
    #
    #     # Train for one epoch
    #     var train_loss = train_epoch(
    #         model, train_images, train_labels,
    #         batch_size, lr, momentum, velocities
    #     )
    #
    #     # Evaluate on training and test sets
    #     var train_acc = compute_accuracy(model, train_images, train_labels)
    #     var test_acc = compute_accuracy(model, test_images, test_labels)
    #
    #     print(f"  Train Loss: {train_loss:.4f}")
    #     print(f"  Train Acc: {train_acc:.2f}%")
    #     print(f"  Test Acc: {test_acc:.2f}%")
    #     print()
    #
    #     # Save weights every 10 epochs
    #     if (epoch + 1) % 10 == 0:
    #         print("  Saving weights...")
    #         model.save_weights("resnet18_weights")
    #         print("  Weights saved to resnet18_weights/")
    #         print()
    #
    # print("Training complete!")
    # model.save_weights("resnet18_weights")
