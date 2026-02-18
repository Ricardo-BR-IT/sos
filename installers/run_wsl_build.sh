#!/bin/bash
# SOS V22 Builder (WSL Helper)
echo ">>> Setting up WSL Environment..."

# 1. Update & Install Dependencies
# (Attempts default sudo without password first)
if sudo -n true 2>/dev/null; then
    sudo apt-get update && sudo apt-get install -y build-essential libncurses5-dev python3 unzip git wget file
else
    echo "Requires SUDO password. Trying with user interaction..."
    sudo apt-get update && sudo apt-get install -y build-essential libncurses5-dev python3 unzip git wget file
fi

# 2. Convert Windows Paths to Linux
cd "$(dirname "$0")/.."
echo "Current Directory: $(pwd)"

# 3. Execute Main Build Script
export TERM=xterm
bash installers/build_openwrt.sh
