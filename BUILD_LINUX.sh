#!/bin/bash

# RESGATE SOS - LINUX BUILDER
# Optimized for Ubuntu/Debian based systems (Desktop & Raspberry Pi)

echo "=========================================="
echo "RESGATE SOS LINUX BUILDER"
echo "=========================================="

if ! command -v flutter &> /dev/null
then
    echo "[ERROR] Flutter could not be found."
    echo "Please install Flutter depending on your version (x64 or arm64 for Pi)."
    echo "  snap install flutter --classic"
    exit 1
fi

echo "[1/4] Checking Flutter..."
flutter --version

echo "[2/4] Checking Linux build dependencies..."
echo "Ensure you have installed: clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev"

echo "[3/4] Bootstrapping Workspace (Melos)..."
export PATH="$PATH":"$HOME/.pub-cache/bin"

if ! command -v melos &> /dev/null
then
    echo "Melos not found. Activating..."
    dart pub global activate melos
fi

melos bootstrap

echo "[4/4] Building Desktop App (Linux)..."
cd apps/desktop_station
flutter clean
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
