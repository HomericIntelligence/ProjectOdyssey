"""
Training Library

The training library provides reusable training infrastructure including optimizers,
schedulers, metrics, callbacks, and training loops for ML Odyssey paper implementations.

All components are implemented in Mojo for maximum performance.

FIXME: Placeholder import tests in tests/shared/test_imports.mojo require:
- test_training_imports (line 80+)
- test_training_optimizers_imports (line 95+)
- test_training_schedulers_imports (line 110+)
- test_training_metrics_imports (line 125+)
- test_training_callbacks_imports (line 140+)
- test_training_loops_imports (line 155+)
All tests marked as "(placeholder)" and require uncommented imports as Issue #49 progresses.
See Issue #49 for details
"""

# Package version
alias VERSION = "0.1.0"

# ============================================================================
# Exports - Training Components
# ============================================================================

# Export base interfaces and utilities
from .base import (
    Callback,
    CallbackSignal,
    CONTINUE,
    STOP,
    TrainingState,
    LRScheduler,
    is_valid_loss,
    clip_gradients,
)

# Export scheduler implementations
from .schedulers import StepLR, CosineAnnealingLR, WarmupLR

# Export callback implementations
from .callbacks import EarlyStopping, ModelCheckpoint, LoggingCallback

# ============================================================================
# Public API
# ============================================================================
