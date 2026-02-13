#!/bin/bash
# ==============================================================================
# SOS HYDRATE: RANGER
# ==============================================================================
# Downloads and installs Ranger assets (Map tiles, Medical Wiki) onto a target system.
# Usage: ./hydrate_ranger.sh [--target /mnt/target]
# ==============================================================================

TARGET_DIR=""
while [[ $# -gt 1 ]]; do
    case "$1" in
        --target) TARGET_DIR="$2"; shift 2;;
        *) shift;;
    esac
done

# If no target specified, assume running on live system
if [ -z "$TARGET_DIR" ]; then TARGET_DIR=""; fi

echo ">>> [HYDRATE] Installing RANGER Edition Pack..."

# 1. Install Packages
apt-get update -qq
apt-get install -y -qq firefox-esr gimp vlc audacity libreoffice-writer qgis gpsd kiwix-tools

# 2. Download Offline Maps (Brazil OSM)
mkdir -p "$TARGET_DIR/opt/sos-mesh/maps"
wget -c "https://download.geofabrik.de/south-america/brazil-latest.osm.pbf" -O "$TARGET_DIR/opt/sos-mesh/maps/brazil.osm.pbf"

# 3. Download Medical Wiki (Kiwix)
mkdir -p "$TARGET_DIR/opt/sos-mesh/kiwix/content"
wget -c "https://download.kiwix.org/zim/wikipedia/wikipedia_en_medicine_maxi_2024-06.zim" -O "$TARGET_DIR/opt/sos-mesh/kiwix/content/wikipedia_medicine.zim"

# 4. Enable Services
if [ -z "$TARGET_DIR" ]; then
    systemctl enable kiwix-serve
    systemctl enable sos-maps
else
    # Enable in chroot if target is mounted
    ln -sf /etc/systemd/system/kiwix-serve.service "$TARGET_DIR/etc/systemd/system/multi-user.target.wants/kiwix-serve.service"
fi

echo ">>> [HYDRATE] Ranger Pack Installed."
