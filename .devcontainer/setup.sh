#!/bin/bash
# Setup script for macropad tool development environment

set -e

echo "🚀 Macropad Tool Development Environment Setup"
echo "=============================================="

# Check if running in container
if [ -f /.dockerenv ]; then
    echo "✅ Running inside development container"
    
    # Update package lists
    echo "📦 Updating package lists..."
    apt-get update -qq
    
    # Install any missing development tools
    echo "🔧 Setting up development tools..."
    
    # Setup udev rules if not already done
    if [ -f /workspace/80-macropad.rules ] && [ ! -f /etc/udev/rules.d/80-macropad.rules ]; then
        echo "📝 Installing udev rules for macropad access..."
        cp /workspace/80-macropad.rules /etc/udev/rules.d/
        echo "✅ Udev rules installed"
    fi
    
    # Check USB devices
    echo "🔍 Checking for USB devices..."
    if command -v lsusb > /dev/null; then
        echo "USB devices detected:"
        lsusb | grep -E "(1189|macropad)" || echo "No macropad devices found (vendor ID 1189)"
    fi
    
    # Build project dependencies
    echo "🏗️  Building project dependencies..."
    cd /workspace
    cargo fetch
    
    echo ""
    echo "✅ Development environment ready!"
    echo ""
    echo "Quick commands:"
    echo "  cargo build          - Build the project"
    echo "  cargo run -- --help  - Show help"
    echo "  cargo run -- validate -d  - Validate with connected device"
    echo "  cargo run -- program - Program the macropad"
    echo "  lsusb | grep 1189    - Check for macropad device"
    echo ""
    
else
    echo "❌ This script should be run inside the development container"
    echo "Please open this project in VS Code and use 'Reopen in Container'"
    exit 1
fi