#!/bin/bash
# ==============================================================================
# SOS RANGER EDITION — Setup Script
# ==============================================================================
# Media edition (~16GB). Everything in Scout + Offline Maps + Medical Wiki.
# Runs inside chroot during ISO build.
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo ">>> [RANGER] Configuring Ranger (Media) Edition..."

# ------------------------------------------------------------------------------
# 1. INHERIT SCOUT SETUP
# ------------------------------------------------------------------------------
if [ -f /tmp/scout_setup_done ]; then
    echo "Scout setup already applied."
else
    # Run scout setup first (if available in assets)
    if [ -f /opt/sos-mesh/scout_setup.sh ]; then
        bash /opt/sos-mesh/scout_setup.sh
    fi
fi

# ------------------------------------------------------------------------------
# 2. ADDITIONAL DESKTOP TOOLS
# ------------------------------------------------------------------------------
apt-get update -qq
apt-get install -y -qq \
    firefox-esr \
    gimp \
    vlc \
    audacity \
    libreoffice-writer libreoffice-calc \
    qgis \
    gpsd gpsd-clients \
    arduino \
    minicom

# ------------------------------------------------------------------------------
# 3. KIWIX — OFFLINE WIKI SERVER
# ------------------------------------------------------------------------------
echo ">>> [RANGER] Installing Kiwix offline wiki server..."

# Install Kiwix
apt-get install -y -qq kiwix-tools 2>/dev/null || {
    echo "Kiwix not in repos, installing from binary..."
    KIWIX_VER="3.6.0"
    wget -q "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64-${KIWIX_VER}.tar.gz" \
        -O /tmp/kiwix.tar.gz
    tar -xzf /tmp/kiwix.tar.gz -C /opt/sos-mesh/ 2>/dev/null || true
    ln -sf /opt/sos-mesh/kiwix-tools_linux-x86_64-${KIWIX_VER}/kiwix-serve /usr/local/bin/kiwix-serve
    rm -f /tmp/kiwix.tar.gz
}

# Create content directory
mkdir -p /opt/sos-mesh/kiwix/content

# Download medical & survival wikis (ZIM files)
# Note: These are large files. In CI, they are cached.
KIWIX_DOWNLOADS=(
    "https://download.kiwix.org/zim/wikipedia/wikipedia_en_medicine_maxi_2024-06.zim"
    "https://download.kiwix.org/zim/other/mdwiki_en_all_2024-06.zim"
    "https://download.kiwix.org/zim/wiktionary/wiktionary_en_all_maxi_2024-06.zim"
)

for url in "${KIWIX_DOWNLOADS[@]}"; do
    FILENAME=$(basename "$url")
    if [ ! -f "/opt/sos-mesh/kiwix/content/$FILENAME" ]; then
        echo "Downloading: $FILENAME (this may take a while)..."
        wget -q --show-progress -c "$url" -O "/opt/sos-mesh/kiwix/content/$FILENAME" || \
            echo "WARNING: Failed to download $FILENAME (network may be unavailable)"
    fi
done

# Kiwix systemd service
cat > /etc/systemd/system/kiwix-serve.service <<'KIWIX_SVC'
[Unit]
Description=Kiwix Offline Wiki Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/kiwix-serve --port=8888 /opt/sos-mesh/kiwix/content/*.zim
Restart=always
RestartSec=5
User=sos

[Install]
WantedBy=multi-user.target
KIWIX_SVC
systemctl enable kiwix-serve.service

# Desktop shortcut for Kiwix
cat > /usr/share/applications/kiwix-wiki.desktop <<'KIWIX_DESK'
[Desktop Entry]
Name=Offline Medical Wiki
Comment=Access medical knowledge offline via Kiwix
Exec=firefox-esr http://localhost:8888
Icon=accessories-dictionary
Terminal=false
Type=Application
Categories=Education;Reference;
KIWIX_DESK

# ------------------------------------------------------------------------------
# 4. OFFLINE MAPS
# ------------------------------------------------------------------------------
echo ">>> [RANGER] Setting up offline maps..."

mkdir -p /opt/sos-mesh/maps

# Install lightweight tile server
pip3 install --break-system-packages mbtileserver 2>/dev/null || true

# Download Brazil OSM extract (MBTiles format)
# Note: Full planet is ~100GB. We use regional extracts.
MAPS_URL="https://download.geofabrik.de/south-america/brazil-latest.osm.pbf"
if [ ! -f "/opt/sos-mesh/maps/brazil.osm.pbf" ]; then
    echo "Downloading Brazil map data..."
    wget -q --show-progress -c "$MAPS_URL" -O "/opt/sos-mesh/maps/brazil.osm.pbf" || \
        echo "WARNING: Failed to download map data"
fi

# Map server systemd service
cat > /etc/systemd/system/sos-maps.service <<'MAP_SVC'
[Unit]
Description=SOS Offline Map Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 -m http.server 8889 --directory /opt/sos-mesh/maps
Restart=always
User=sos

[Install]
WantedBy=multi-user.target
MAP_SVC
systemctl enable sos-maps.service

# Desktop shortcut
cat > /usr/share/applications/sos-maps.desktop <<'MAP_DESK'
[Desktop Entry]
Name=SOS Offline Maps
Comment=View offline maps for navigation
Exec=firefox-esr http://localhost:8889
Icon=applications-internet
Terminal=false
Type=Application
Categories=Education;Geography;
MAP_DESK

# ------------------------------------------------------------------------------
# 5. SURVIVAL MANUALS (PDF)
# ------------------------------------------------------------------------------
mkdir -p /opt/sos-mesh/docs/survival

# These would be downloaded from a trusted mirror in production
echo "Survival manuals directory created at /opt/sos-mesh/docs/survival"
echo "Add PDF manuals here for offline access." > /opt/sos-mesh/docs/survival/README.txt

# ------------------------------------------------------------------------------
# 6. CLEANUP
# ------------------------------------------------------------------------------
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ">>> [RANGER] Setup complete. Media station ready."
