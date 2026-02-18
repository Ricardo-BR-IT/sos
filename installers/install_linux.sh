#!/bin/bash
# SOS V21 UNIVERSAL LINUX INSTALLER
# Works on Debian/Ubuntu/Arch/Fedora/Raspbian/Termux
# Installs PHP, SQLite, and Configuring Systemd Service.

set -e

echo ">>> SOS V21 INSTALLER initialized..."

# 1. Detect Hardware & OS
ARCH=$(uname -m)
OS=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')

echo "Detected: $OS ($ARCH)"

# 2. Dependencies
PACKAGES="php php-sqlite3 php-json php-curl sqlite3 curl unzip"

if [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y $PACKAGES
elif [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm php php-sqlite php-gd sqlite
elif [ -f /etc/termux/termux.properties ]; then
    pkg install -y php sqlite
fi

# 3. Deploy Files
INSTALL_DIR="/opt/sos"
if [ -d "$HOME/sos" ]; then INSTALL_DIR="$HOME/sos"; fi

echo "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r . "$INSTALL_DIR"

# 4. Configure Database
echo "Initializing SQLite..."
php "$INSTALL_DIR/setup_database.php"

# 5. Create Service (Systemd)
if command -v systemctl &> /dev/null; then
    cat <<EOF | sudo tee /etc/systemd/system/sos.service
[Unit]
Description=SOS Platform V21
After=network.target

[Service]
ExecStart=/usr/bin/php -S 0.0.0.0:8080 -t $INSTALL_DIR
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable sos
    sudo systemctl start sos
    echo "Service Started on Port 8080"
else
    # Termux / Non-Systemd Fallback
    echo "Starting Manual Server..."
    php -S 0.0.0.0:8080 -t "$INSTALL_DIR" &
fi

echo ">>> SOS V21 DEPLOYED SUCCESSFULLY!"
echo "Access at http://localhost:8080"
