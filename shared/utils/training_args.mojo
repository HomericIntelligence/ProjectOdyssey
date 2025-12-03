"""Training argument utilities for common training script configuration.

This module provides a standardized TrainingArgs struct and parse_training_args()
function for consistent command-line argument handling across training scripts.

Example:
    from shared.utils.training_args import TrainingArgs, parse_training_args

    fn main() raises:
        var args = parse_training_args()
        print("Epochs:", args.epochs)
        print("Batch size:", args.batch_size)
        print("Learning rate:", args.learning_rate)
"""

from sys import argv


# ============================================================================
# Training Arguments Struct
# ============================================================================


@fieldwise_init
struct TrainingArgs(Copyable, Movable):
    """Container for common training hyperparameters and paths.

    Attributes:
        epochs: Number of training epochs.
        batch_size: Batch size for training.
        learning_rate: Learning rate for optimizer.
        momentum: Momentum factor for SGD.
        data_dir: Path to dataset directory.
        weights_dir: Path to save/load model weights.
        verbose: Whether to print verbose output.
    """

    var epochs: Int
    var batch_size: Int
    var learning_rate: Float64
    var momentum: Float64
    var data_dir: String
    var weights_dir: String
    var verbose: Bool

    fn __init__(out self):
        """Initialize with default training arguments."""
        self.epochs = 10
        self.batch_size = 32
        self.learning_rate = 0.01
        self.momentum = 0.9
        self.data_dir = "datasets"
        self.weights_dir = "weights"
        self.verbose = False


# ============================================================================
# Argument Parsing Functions
# ============================================================================


fn parse_training_args() raises -> TrainingArgs:
    """Parse common training arguments from command line.

    Supported arguments:
        --epochs <int>: Number of training epochs (default: 10).
        --batch-size <int>: Batch size (default: 32).
        --lr <float>: Learning rate (default: 0.01).
        --momentum <float>: Momentum for SGD (default: 0.9).
        --data-dir <str>: Dataset directory (default: "datasets").
        --weights-dir <str>: Weights directory (default: "weights").
        --verbose: Enable verbose output.

    Returns:
        TrainingArgs struct with parsed values.

    Example:
        # Command line: python train.py --epochs 100 --lr 0.001 --verbose
        var args = parse_training_args()
        # args.epochs == 100, args.learning_rate == 0.001, args.verbose == True
    """
    var result = TrainingArgs()

    var args = argv()
    var i = 1  # Skip program name
    while i < len(args):
        var arg = args[i]

        if arg == "--epochs" and i + 1 < len(args):
            result.epochs = Int(args[i + 1])
            i += 2
        elif arg == "--batch-size" and i + 1 < len(args):
            result.batch_size = Int(args[i + 1])
            i += 2
        elif arg == "--lr" and i + 1 < len(args):
            result.learning_rate = Float64(args[i + 1])
            i += 2
        elif arg == "--momentum" and i + 1 < len(args):
            result.momentum = Float64(args[i + 1])
            i += 2
        elif arg == "--data-dir" and i + 1 < len(args):
            result.data_dir = args[i + 1]
            i += 2
        elif arg == "--weights-dir" and i + 1 < len(args):
            result.weights_dir = args[i + 1]
            i += 2
        elif arg == "--verbose":
            result.verbose = True
            i += 1
        else:
            # Skip unknown arguments (allows model-specific args)
            i += 1

    return result^


fn parse_training_args_with_defaults(
    default_epochs: Int = 10,
    default_batch_size: Int = 32,
    default_lr: Float64 = 0.01,
    default_momentum: Float64 = 0.9,
    default_data_dir: String = "datasets",
    default_weights_dir: String = "weights",
) raises -> TrainingArgs:
    """Parse training arguments with custom defaults.

    Allows each training script to specify model-appropriate defaults
    while still using shared parsing logic.

    Args:
        default_epochs: Default number of epochs.
        default_batch_size: Default batch size.
        default_lr: Default learning rate.
        default_momentum: Default momentum.
        default_data_dir: Default dataset directory.
        default_weights_dir: Default weights directory.

    Returns:
        TrainingArgs struct with parsed values.

    Example:
        # AlexNet with custom defaults
        var args = parse_training_args_with_defaults(
            default_epochs=100,
            default_batch_size=128,
            default_lr=0.01,
            default_data_dir="datasets/cifar10",
            default_weights_dir="alexnet_weights"
        )
    """
    var result = TrainingArgs()
    result.epochs = default_epochs
    result.batch_size = default_batch_size
    result.learning_rate = default_lr
    result.momentum = default_momentum
    result.data_dir = default_data_dir
    result.weights_dir = default_weights_dir
    result.verbose = False

    var args = argv()
    var i = 1
    while i < len(args):
        var arg = args[i]

        if arg == "--epochs" and i + 1 < len(args):
            result.epochs = Int(args[i + 1])
            i += 2
        elif arg == "--batch-size" and i + 1 < len(args):
            result.batch_size = Int(args[i + 1])
            i += 2
        elif arg == "--lr" and i + 1 < len(args):
            result.learning_rate = Float64(args[i + 1])
            i += 2
        elif arg == "--momentum" and i + 1 < len(args):
            result.momentum = Float64(args[i + 1])
            i += 2
        elif arg == "--data-dir" and i + 1 < len(args):
            result.data_dir = args[i + 1]
            i += 2
        elif arg == "--weights-dir" and i + 1 < len(args):
            result.weights_dir = args[i + 1]
            i += 2
        elif arg == "--verbose":
            result.verbose = True
            i += 1
        else:
            i += 1

    return result^
