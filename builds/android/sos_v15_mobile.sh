#!/bin/bash
# SOS "GOD MODE" SCRIPT (ANDROID/TERMUX) - V15.0
# Turns an old Android phone into a Portable Server & Node.

echo ">>> SOS V15: ANDROID DEPLOYMENT"
echo ">>> UPDATING PACKAGES..."

pkg update -y && pkg upgrade -y
pkg install -y php git wget python

# 1. Setup Environment
mkdir -p ~/sos_node
cd ~/sos_node

# 2. Clone SOS Core
echo ">>> CLONING CORE REPOSITORY..."
if [ -d "sos_core" ]; then
    cd sos_core
    git pull
else
    git clone https://github.com/ricardosos/sos_core.git .
fi

# 3. Production Environment
echo ">>> SETTING UP PRODUCTION ENV..."
echo "<?php phpinfo(); ?>" > info.php

# 3. Start PHP Server
echo ">>> STARTING LOCAL SERVER ON PORT 8080..."
echo ">>> ACCESS: http://localhost:8080"
echo ">>> SHARE: Enable 'Wi-Fi Hotspot' to let others connect."

php -S 0.0.0.0:8080
