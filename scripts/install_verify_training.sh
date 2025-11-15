#!/bin/bash
# Installation verification script for training module
#
# This script tests that the training package can be installed and used
# in a clean environment, verifying all exports work correctly.

set -e

echo "================================"
echo "Training Package Verification"
echo "================================"
echo ""

# Determine script directory to find package
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGE_PATH="$REPO_ROOT/dist/training-0.1.0.mojopkg"

# Check if package exists
if [ ! -f "$PACKAGE_PATH" ]; then
    echo "ERROR: Package not found at $PACKAGE_PATH"
    echo "Please build the package first:"
    echo "  mkdir -p dist/"
    echo "  mojo package shared/training -o dist/training-0.1.0.mojopkg"
    exit 1
fi

echo "Found package: $PACKAGE_PATH"
echo ""

# Create temporary directory for testing
TEMP_DIR=$(mktemp -d)
echo "Created test environment: $TEMP_DIR"
cd "$TEMP_DIR"

# Install package
echo "Installing training package..."
mojo install "$PACKAGE_PATH"

# Test imports - verify key exports work
echo ""
echo "Testing imports..."

# Test 1: Basic callback imports
echo "  - Testing callback system..."
mojo run -c "from training import Callback, CallbackSignal, CONTINUE, STOP; print('  ✓ Callback system imports OK')" || {
    echo "  ✗ FAILED: Callback system imports"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Test 2: Training state
echo "  - Testing training state..."
mojo run -c "from training import TrainingState; print('  ✓ TrainingState import OK')" || {
    echo "  ✗ FAILED: TrainingState import"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Test 3: Learning rate scheduler
echo "  - Testing LR scheduler..."
mojo run -c "from training import LRScheduler; print('  ✓ LRScheduler import OK')" || {
    echo "  ✗ FAILED: LRScheduler import"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Test 4: Scheduler implementations
echo "  - Testing scheduler implementations..."
mojo run -c "from training import StepLR, CosineAnnealingLR, WarmupLR; print('  ✓ Scheduler implementations OK')" || {
    echo "  ✗ FAILED: Scheduler implementations"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Test 5: Callback implementations
echo "  - Testing callback implementations..."
mojo run -c "from training import EarlyStopping, ModelCheckpoint, LoggingCallback; print('  ✓ Callback implementations OK')" || {
    echo "  ✗ FAILED: Callback implementations"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Test 6: Utility functions
echo "  - Testing utility functions..."
mojo run -c "from training import is_valid_loss, clip_gradients; print('  ✓ Utility functions OK')" || {
    echo "  ✗ FAILED: Utility functions"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
}

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo ""
echo "================================"
echo "✓ All verification tests passed!"
echo "================================"
echo ""
echo "Training package is ready for distribution."
