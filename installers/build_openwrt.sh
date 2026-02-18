#!/bin/bash
# SOS V21 OPENWRT IMAGE BUILDER
# Generates Custom Firmware ROMs for: TP-Link, GL.iNet, Ubiquiti, Linksys
# Includes: PHP-CLI, Batman-Adv (Mesh), Wpad-Mesh.

set -e

echo ">>> OPENWRT SOS ROM BUILDER"
echo "Requires: Linux, Build Essentials, Python3, libncurses5-dev"

# 1. Download OpenWrt ImageBuilder (23.05 Stable)
BUILDER_URL="https://downloads.openwrt.org/releases/23.05.0/targets/ath79/generic/openwrt-imagebuilder-23.05.0-ath79-generic.Linux-x86_64.tar.xz"
BASE_DIR="openwrt-builder"

if [ ! -d "$BASE_DIR" ]; then
    echo "Downloading ImageBuilder..."
    wget -q "$BUILDER_URL" -O builder.tar.xz
    tar Jxvf builder.tar.xz
    mv openwrt-imagebuilder-* "$BASE_DIR"
    rm builder.tar.xz
fi

cd "$BASE_DIR"

# 2. Define Packages (The "SOS Core")
SOS_PACKAGES="php8-cli php8-mod-sqlite3 php8-mod-json php8-mod-curl wpad-mesh-wolfssl kmod-batman-adv batctl-default"

# 3. Inject Files (Custom Files for /etc/sos and /etc/init.d/sos)
FILES_DIR="files"
mkdir -p "$FILES_DIR/etc/sos"
mkdir -p "$FILES_DIR/etc/init.d"

# Copy PHP source from repo
cp -r ../../../ "$FILES_DIR/etc/sos/"
# (Assuming current dir is installers/openwrt-builder, and source is ../../../)

# Generate Init Script
cat <<EOF > "$FILES_DIR/etc/init.d/sos"
#!/bin/sh /etc/rc.common
START=99
APP=/usr/bin/php
ARGS="-S 0.0.0.0:80 -t /etc/sos"

start() {
    echo "Starting SOS..."
    service_start $APP $ARGS
}
stop() {
    echo "Stopping SOS..."
    service_stop $APP
}
EOF
chmod +x "$FILES_DIR/etc/init.d/sos"

# 4. Build Images
echo "Building TP-Link Archer C7 v5..."
make image PROFILE="tplink_archer-c7-v5" PACKAGES="$SOS_PACKAGES" FILES="$FILES_DIR"

echo "Building GL.iNet AR750..."
make image PROFILE="glinet_gl-ar750" PACKAGES="$SOS_PACKAGES" FILES="$FILES_DIR"

echo ">>> ROMs Generated in bin/targets/"
