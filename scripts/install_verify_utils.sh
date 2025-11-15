#!/bin/bash
# Installation verification script for utils package

set -e

echo "Testing utils package installation..."

# Get the absolute path to the package
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_PATH="$SCRIPT_DIR/../dist/utils-0.1.0.mojopkg"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"

cd "$TEMP_DIR"

# Install package
echo "Installing package from: $PACKAGE_PATH"
mojo install "$PACKAGE_PATH"

# Test imports
echo "Testing imports..."
mojo run -c "from utils import Logger, Config, set_seed; print('Utils module OK')"

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo "Utils package verification complete!"
