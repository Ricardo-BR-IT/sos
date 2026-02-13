#!/bin/bash

# RESGATE SOS - LINUX BUILDER
# Optimized for Ubuntu/Debian based systems (Desktop & Raspberry Pi)

echo "=========================================="
echo "RESGATE SOS LINUX BUILDER"
echo "=========================================="

# 1. Check for basic tools
if ! command -v flutter &> /dev/null
then
    echo "[ERROR] Flutter could not be found."
    echo "Please install Flutter depending on your version (x64 or arm64 for Pi)."
    echo "  snap install flutter --classic"
    exit 1
fi

echo "[1/4] Checking Flutter..."
flutter --version

# 2. Dependencies Check (Optional but helpful)
echo "[2/4] Checking Linux build dependencies..."
echo "Ensure you have installed: clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev"
# We won't block build if they are missing, but Flutter will fail.

# 3. Bootstrap Workspace
echo "[3/4] Bootstrapping Workspace (Melos)..."
# Add pub cache to path just in case
export PATH="$PATH":"$HOME/.pub-cache/bin"

if ! command -v melos &> /dev/null
then
    echo "Melos not found. Activating..."
    dart pub global activate melos
fi

melos bootstrap

# 4. Build Linux App
echo "[4/4] Building Desktop App (Linux)..."
cd apps/desktop_station

# Clean first to avoid platform conflicts
flutter clean

# Build release bundle
flutter build linux --release

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "[SUCCESS] Linux Build Complete!"
    echo "Executable: apps/desktop_station/build/linux/x64/release/bundle/desktop_station"
    echo "=========================================="
else
    echo "=========================================="
    echo "[ERROR] Linux Build Failed."
    echo "Check if you have the required libraries installed."
    echo "sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev"
    echo "=========================================="
    exit 1
fi

cd ../..
