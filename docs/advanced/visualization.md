# Visualization

Visualization is essential for understanding model behavior, debugging training issues, and validating data
processing pipelines. This guide covers techniques for visualizing training metrics, model internals, and
datasets.

## Overview

Why visualization matters:

- **Training Debugging**: Detect overfitting, learning rate issues, and convergence problems
- **Model Understanding**: Inspect learned weights, activation patterns, and feature maps
- **Data Validation**: Verify augmentations, distributions, and preprocessing correctness
- **Reporting**: Create publication-quality figures for papers and presentations

Visualization accelerates iteration cycles by providing immediate feedback on model performance.

## Training Metrics

### Loss Curves

Track training and validation loss across epochs to detect convergence issues:

```python
```python

import matplotlib.pyplot as plt
from pathlib import Path

def plot_loss_curves(history: dict, output_path: str):
    """Plot training and validation loss."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(history['train_loss'], label='Training Loss', linewidth=2)
    ax.plot(history['val_loss'], label='Validation Loss', linewidth=2)
    ax.set_xlabel('Epoch')
    ax.set_ylabel('Loss')
    ax.set_title('Training Progress')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

```text

**Key indicators**:

- Diverging curves → learning rate too high
- Flat curves → learning rate too low
- Validation loss increasing → overfitting

### Accuracy and Metrics

Plot classification accuracy, precision, recall, and F1-score:

```python
```python

def plot_metrics(metrics: dict, output_path: str):
    """Plot multiple evaluation metrics."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    metrics_list = ['accuracy', 'precision', 'recall', 'f1_score']
    for idx, metric in enumerate(metrics_list):
        ax = axes[idx // 2, idx % 2]
        ax.plot(metrics[metric], marker='o', linewidth=2)
        ax.set_title(metric.replace('_', ' ').title())
        ax.set_xlabel('Epoch')
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()

```text

## Model Visualization

### Architecture Diagram

Visualize model structure and layer connections:

```python
```python

def visualize_architecture(model, input_shape: tuple, output_path: str):
    """Create architecture visualization."""
    # For Mojo models, export layer information
    # This is typically done via model inspection or export utilities
    layer_info = model.export_architecture()

    fig, ax = plt.subplots(figsize=(12, 8))
    ax.axis('off')

    # Draw layers
    y_pos = 0
    for idx, layer in enumerate(layer_info):
        rect = plt.Rectangle((1, y_pos), 2, 0.8,
                             edgecolor='black', facecolor='lightblue')
        ax.add_patch(rect)
        ax.text(2, y_pos + 0.4, f"{layer['name']}\n{layer['output_shape']}",
               ha='center', va='center', fontsize=10)
        y_pos -= 1

    ax.set_xlim(0, 4)
    ax.set_ylim(y_pos, 1)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

```text

### Weight Statistics

Inspect weight distributions across layers:

```python
```python

def plot_weight_distributions(model, output_path: str):
    """Visualize weight statistics."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    all_weights = []
    for layer in model.layers:
        if hasattr(layer, 'weight'):
            all_weights.extend(layer.weight.flatten().tolist())

    axes[0].hist(all_weights, bins=100, edgecolor='black')
    axes[0].set_title('Weight Distribution')
    axes[0].set_xlabel('Weight Value')
    axes[0].set_ylabel('Frequency')

    axes[1].boxplot([layer.weight.flatten().tolist()
                     for layer in model.layers if hasattr(layer, 'weight')])
    axes[1].set_title('Weight Statistics by Layer')
    axes[1].set_ylabel('Weight Value')

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()

```text

### Activation Maps

Visualize hidden layer activations for a sample input:

```python
```python

def plot_activation_maps(model, sample_input, layer_idx: int, output_path: str):
    """Visualize feature maps from intermediate layer."""
    activations = model.get_layer_output(layer_idx, sample_input)

    num_channels = min(activations.shape[0], 16)  # Limit for visualization
    fig, axes = plt.subplots(4, 4, figsize=(12, 12))

    for idx in range(num_channels):
        ax = axes[idx // 4, idx % 4]
        ax.imshow(activations[idx], cmap='viridis')
        ax.axis('off')
        ax.set_title(f'Channel {idx}')

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()

```text

## Data Visualization

### Input Samples

Display raw training samples and their labels:

```python
```python

def plot_dataset_samples(dataset, num_samples: int = 16, output_path: str = "samples.png"):
    """Visualize random dataset samples."""
    fig, axes = plt.subplots(4, 4, figsize=(12, 12))

    for idx in range(num_samples):
        image, label = dataset[idx]
        ax = axes[idx // 4, idx % 4]
        ax.imshow(image.squeeze(), cmap='gray')
        ax.set_title(f'Label: {label}')
        ax.axis('off')

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()

```text

### Augmentation Effects

Compare original and augmented versions:

```python
```python

def plot_augmentation_comparison(original, augmented_list, output_path: str):
    """Show original vs augmented versions."""
    num_aug = len(augmented_list)
    fig, axes = plt.subplots(1, num_aug + 1, figsize=(4 * (num_aug + 1), 4))

    axes[0].imshow(original.squeeze(), cmap='gray')
    axes[0].set_title('Original')
    axes[0].axis('off')

    for idx, aug in enumerate(augmented_list):
        axes[idx + 1].imshow(aug.squeeze(), cmap='gray')
        axes[idx + 1].set_title(f'Augmentation {idx + 1}')
        axes[idx + 1].axis('off')

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()

```text

## Tools and Libraries

### Matplotlib

Primary plotting library for static visualizations:

```python
```python

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Used for: loss curves, metrics, distributions, architecture diagrams

```text

### NumPy Integration

Array operations for preparing data:

```python
```python

import numpy as np

# Normalize images for visualization
normalized = (image - image.min()) / (image.max() - image.min())

```text

### TensorBoard Equivalent

For real-time monitoring in Mojo projects:

```python
```python

def log_metrics(step: int, metrics: dict, log_dir: str = "./logs"):
    """Log metrics for tensorboard-like visualization."""
    Path(log_dir).mkdir(exist_ok=True)

    with open(f"{log_dir}/metrics.csv", "a") as f:
        row = [step] + list(metrics.values())
        f.write(",".join(map(str, row)) + "\n")

```text

## Examples

### Complete Training Visualization

```python
```python

def visualize_training_session(model, train_history, val_history,
                               dataset, output_dir: str = "./visualizations"):
    """Create comprehensive training visualization report."""
    Path(output_dir).mkdir(exist_ok=True)

    # Plot metrics
    plot_loss_curves({'train_loss': train_history,
                      'val_loss': val_history},
                     f"{output_dir}/loss_curves.png")

    # Weight statistics
    plot_weight_distributions(model, f"{output_dir}/weights.png")

    # Sample visualization
    plot_dataset_samples(dataset, output_path=f"{output_dir}/samples.png")

    print(f"Visualizations saved to {output_dir}/")

```text

## Best Practices

- **High DPI**: Use `dpi=300` for publication-quality figures
- **Consistent Styling**: Define color schemes and fonts for cohesion
- **Labels**: Always include axis labels, titles, and legends
- **File Organization**: Store visualizations in timestamped directories
- **Memory**: Close figures with `plt.close()` to prevent memory leaks
