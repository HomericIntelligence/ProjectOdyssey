#!/bin/bash
# Build script for training module package
#
# Creates the distributable .mojopkg file for the training module

set -e

echo "================================"
echo "Building Training Package"
echo "================================"
echo ""

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"

# Create dist directory if it doesn't exist
mkdir -p dist/

echo "Building training-0.1.0.mojopkg..."
echo ""

# Build the package
mojo package shared/training -o dist/training-0.1.0.mojopkg

# Check if build succeeded
if [ -f "dist/training-0.1.0.mojopkg" ]; then
    echo ""
    echo "================================"
    echo "✓ Package built successfully!"
    echo "================================"
    echo ""
    ls -lh dist/training-0.1.0.mojopkg
    echo ""
else
    echo ""
    echo "ERROR: Package build failed!"
    exit 1
fi
