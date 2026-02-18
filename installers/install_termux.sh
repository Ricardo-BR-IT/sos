#!/bin/bash
# SOS V21 TERMUX INSTALLER (Android)
# Automates PHP/SQLite install on Rooted/Non-Rooted Android.

set -e

echo ">>> SOS V21 TERMUX DEPLOYMENT..."

# 1. Update Packages
pkg update -y && pkg upgrade -y
pkg install -y php sqlite openssh git

# 2. Storage Setup
if [ ! -d "$HOME/sos" ]; then
    echo "Cloning Repository..."
    mkdir -p "$HOME/sos"
    cp -r * "$HOME/sos"
fi

# 3. Permissions
termux-setup-storage

# 4. Configure PHP.ini
echo "display_errors = Off" >> $PREFIX/etc/php.ini
echo "upload_max_filesize = 50M" >> $PREFIX/etc/php.ini

# 5. Start Service
echo "Initializing Database..."
php "$HOME/sos/setup_database.php"

echo ">>> SERVER STARTED ON PORT 8080"
echo "Access via Browser at http://localhost:8080"
echo "To share on Local Network, find IP using 'ifconfig'"

# Background Process
cd "$HOME/sos"
php -S 0.0.0.0:8080 -t . &
