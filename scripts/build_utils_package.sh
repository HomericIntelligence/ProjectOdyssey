#!/bin/bash
# Build script for utils package

set -e

echo "Building utils package..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

cd "$PROJECT_ROOT"

# Create dist directory
mkdir -p dist

# Build the package
echo "Running: mojo package shared/utils -o dist/utils-0.1.0.mojopkg"
mojo package shared/utils -o dist/utils-0.1.0.mojopkg

# Verify package was created
if [ -f "dist/utils-0.1.0.mojopkg" ]; then
    echo "✓ Package built successfully!"
    ls -lh dist/utils-0.1.0.mojopkg
else
    echo "✗ Package build failed!"
    exit 1
fi

echo "Build complete!"
