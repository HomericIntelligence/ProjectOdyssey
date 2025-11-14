# ML Odyssey

Description here.

## Features

Features list.

## Getting Started

Quick start guide.

## Installation

Installation steps.

## Configuration Management

ML Odyssey uses a hierarchical configuration system for reproducible experiments and paper implementations.

### Quick Start

Load an experiment configuration:

```mojo
from shared.utils.config_loader import load_experiment_config

fn main() raises:
    // Load configuration for LeNet-5 baseline experiment
    var config = load_experiment_config("lenet5", "baseline")

    // Access parameters
    var lr = config.get_float("optimizer.learning_rate")
    var batch_size = config.get_int("training.batch_size")
    var epochs = config.get_int("training.epochs")

    // Use in training
    print("Training with lr =", lr, "for", epochs, "epochs")
```

### Configuration Hierarchy

Configurations follow a three-tier merge pattern:

1. **Defaults** (`configs/defaults/`) - System-wide defaults
2. **Paper Configs** (`configs/papers/<paper>/`) - Paper-specific settings
3. **Experiment Configs** (`configs/experiments/<paper>/<experiment>`) - Experiment variations

**Example merge**:

```yaml
# configs/defaults/training.yaml
optimizer:
  learning_rate: 0.001
  momentum: 0.9

# configs/papers/lenet5/training.yaml
optimizer:
  learning_rate: 0.01  # Override default

# configs/experiments/lenet5/high_lr.yaml
optimizer:
  learning_rate: 0.1  # Override paper config
```

Final merged config will have `learning_rate: 0.1`.

### Creating Configurations

**Step 1**: Create paper configuration

```yaml
# configs/papers/your-paper/model.yaml
model:
  name: "YourModel"
  num_classes: 10
  input_shape: [3, 224, 224]
```

**Step 2**: Create experiment configuration

```yaml
# configs/experiments/your-paper/baseline.yaml
experiment:
  name: "baseline"
  description: "Baseline reproduction"

# Experiment-specific overrides
training:
  epochs: 50
  batch_size: 64
```

**Step 3**: Load in code

```mojo
from shared.utils.config_loader import load_experiment_config

var config = load_experiment_config("your-paper", "baseline")
```

### Environment Variables

Configurations support environment variable substitution:

```yaml
paths:
  data_dir: "${DATA_DIR:-./data}"
  model_dir: "${MODEL_DIR:-./models}"
```

Set environment variables:

```bash
export DATA_DIR=/mnt/data
export MODEL_DIR=/mnt/models
```

### Validation

Validate configurations before use:

```mojo
from shared.utils.config_loader import validate_experiment_config

fn main() raises:
    var config = load_experiment_config("lenet5", "baseline")

    // Validate required fields
    validate_experiment_config(config)  // Raises on error

    // Proceed with training
    train_model(config)
```

### Configuration Examples

See `papers/_template/examples/train.mojo` for a complete example of configuration-driven training.

For detailed documentation:

- **Configuration Architecture**: See `notes/review/configs-architecture.md`
- **Migration Guide**: See `configs/MIGRATION.md`
- **Paper Template**: See `papers/_template/`

### Common Patterns

**Loading with defaults**:

```mojo
var lr = config.get_float("optimizer.learning_rate", default=0.001)
var use_augmentation = config.get_bool("data.augmentation", default=False)
```

**Accessing nested values**:

```mojo
var optimizer_name = config.get_string("optimizer.name")
var scheduler_step = config.get_int("scheduler.step_size")
var data_workers = config.get_int("data.num_workers")
```

**Creating new experiment configs**:

```mojo
from shared.utils.config_loader import create_experiment_config

var overrides = Config()
overrides.set("optimizer.learning_rate", 0.01)
overrides.set("training.batch_size", 64)

create_experiment_config("lenet5", "high_lr", overrides)
```

### Benefits

- **Reproducibility**: Every experiment fully defined by configuration
- **Version Control**: Track parameter changes in git
- **Reusability**: Share configurations across experiments
- **Flexibility**: Override defaults at any level
- **Type Safety**: Leverage Mojo's type system for validation
- **Environment Flexibility**: Deploy anywhere with environment variables

For more information, see the [Configuration Architecture](notes/review/configs-architecture.md) documentation.
