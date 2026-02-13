#!/bin/bash
# ==============================================================================
# SOS SCOUT EDITION — Setup Script
# ==============================================================================
# Minimal edition (~2GB). Kernel + Mesh Drivers + Emergency Comms.
# Runs inside chroot during ISO build.
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo ">>> [SCOUT] Configuring Scout (Minimal) Edition..."

# ------------------------------------------------------------------------------
# 1. MINIMALIST TOOLS
# ------------------------------------------------------------------------------
apt-get update -qq
apt-get install -y -qq \
    rfkill \
    iw \
    hostapd \
    dnsmasq \
    avahi-daemon \
    screen tmux

# ------------------------------------------------------------------------------
# 2. MESH NETWORKING SETUP
# ------------------------------------------------------------------------------
# Create mesh WiFi profile (auto-creates ad-hoc network on boot)
cat > /etc/NetworkManager/system-connections/sos-mesh.nmconnection <<'MESHCFG'
[connection]
id=SOS-Mesh-AdHoc
type=wifi
autoconnect=true
autoconnect-priority=100

[wifi]
mode=adhoc
ssid=SOS-RESGATE-MESH

[wifi-security]
key-mgmt=none

[ipv4]
method=link-local

[ipv6]
method=ignore
MESHCFG
chmod 600 /etc/NetworkManager/system-connections/sos-mesh.nmconnection

# Create hotspot fallback profile
cat > /etc/NetworkManager/system-connections/sos-hotspot.nmconnection <<'HOTSPOT'
[connection]
id=SOS-Hotspot
type=wifi
autoconnect=false

[wifi]
mode=ap
ssid=SOS-EMERGENCY
band=bg
channel=6

[wifi-security]
key-mgmt=wpa-psk
psk=resgatesos

[ipv4]
method=shared
address1=192.168.73.1/24

[ipv6]
method=ignore
HOTSPOT
chmod 600 /etc/NetworkManager/system-connections/sos-hotspot.nmconnection

# ------------------------------------------------------------------------------
# 3. AUTO-START MESH ON BOOT
# ------------------------------------------------------------------------------
cat > /etc/systemd/system/sos-mesh.service <<'SVCFILE'
[Unit]
Description=SOS Mesh Network — Auto Start
After=network.target NetworkManager.service
Wants=NetworkManager.service

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 5
ExecStart=/bin/bash -c 'nmcli connection up SOS-Mesh-AdHoc 2>/dev/null || nmcli connection up SOS-Hotspot 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SVCFILE
systemctl enable sos-mesh.service

# ------------------------------------------------------------------------------
# 4. EMERGENCY BEACON (lightweight SOS broadcast)
# ------------------------------------------------------------------------------
cat > /opt/sos-mesh/beacon.sh <<'BEACON'
#!/bin/bash
# Lightweight SOS beacon — broadcasts UDP heartbeat on mesh network
while true; do
    PAYLOAD=$(printf '{"type":"beacon","node":"%s","time":"%s","edition":"scout"}' \
        "$(hostname)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")
    echo "$PAYLOAD" | socat - UDP-DATAGRAM:255.255.255.255:5073,broadcast 2>/dev/null || true
    sleep 30
done
BEACON
chmod +x /opt/sos-mesh/beacon.sh

# Beacon service
cat > /etc/systemd/system/sos-beacon.service <<'BEACONSVC'
[Unit]
Description=SOS Emergency Beacon
After=sos-mesh.service

[Service]
Type=simple
ExecStart=/opt/sos-mesh/beacon.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
BEACONSVC
systemctl enable sos-beacon.service

# Install socat for beacon
apt-get install -y -qq socat

# ------------------------------------------------------------------------------
# 6. INSTALLER & EXPANSION TOOLS
# ------------------------------------------------------------------------------
echo ">>> [SCOUT] Installing SOS Installer & Expansion Tools..."

# Install GUI dependencies for installer.py
apt-get install -y -qq python3-tk parted gparted rsync

# Copy installer script -> /usr/local/bin/sos-install
# (Assumes BUILD_ISO.sh copies iso_builder/assets/installer/installer.py to /opt/sos-mesh/installer.py)
cat > /usr/local/bin/sos-install <<'INSTALL_CMD'
#!/bin/bash
xhost +local:root 2>/dev/null
sudo python3 /opt/sos-mesh/installer.py
INSTALL_CMD
chmod +x /usr/local/bin/sos-install

# Create Desktop Shortcut
mkdir -p /home/sos/Desktop
cat > /home/sos/Desktop/install-sos.desktop <<'INSTALL_DESK'
[Desktop Entry]
Name=Install SOS to Disk
Comment=Install System & Expand Edition
Exec=sudo /usr/local/bin/sos-install
Icon=system-installer
Terminal=false
Type=Application
Categories=System;
INSTALL_DESK
chown -R sos:sos /home/sos/Desktop
chmod +x /home/sos/Desktop/install-sos.desktop

# ------------------------------------------------------------------------------
# 7. CLEANUP
# ------------------------------------------------------------------------------
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ">>> [SCOUT] Setup complete. Minimal mesh node ready."
