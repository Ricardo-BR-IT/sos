#!/bin/bash
# ==============================================================================
# SOS-ROM FIRST BOOT SETUP
# ==============================================================================
# Runs once on first boot after SOS-ROM flash.
# Detects hardware, downloads needed drivers, configures mesh.
# ==============================================================================

set -e

MARKER="/system/etc/sos_first_boot"
LOG="/data/sos/first_boot.log"

[ ! -f "$MARKER" ] && exit 0

mkdir -p /data/sos
echo "$(date) - SOS First Boot Starting..." > "$LOG"

# 1. DETECT HARDWARE
echo ">>> Detecting hardware..." >> "$LOG"

CHIPSET=$(getprop ro.board.platform)
ARCH=$(uname -m)
WIFI_CHIP=$(lsmod | grep -oE 'wlan|ath|rtl|bcm|mt76' | head -1)
BT_VERSION=$(hciconfig hci0 version 2>/dev/null | grep "HCI Ver" | awk '{print $3}')
HAS_NFC=$(pm list features | grep -c nfc || echo 0)
HAS_IR=$(pm list features | grep -c ir_emitter || echo 0)
RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
STORAGE_GB=$(df /data | tail -1 | awk '{print int($2/1024/1024)}')

cat > /data/sos/hardware.json << EOF
{
  "chipset": "$CHIPSET",
  "arch": "$ARCH",
  "wifi_chip": "$WIFI_CHIP",
  "bt_version": "$BT_VERSION",
  "has_nfc": $HAS_NFC,
  "has_ir": $HAS_IR,
  "ram_mb": $RAM_MB,
  "storage_gb": $STORAGE_GB,
  "detected_at": "$(date -Iseconds)"
}
EOF

echo ">>> Hardware: $CHIPSET / $ARCH / RAM: ${RAM_MB}MB / Storage: ${STORAGE_GB}GB" >> "$LOG"

# 2. CONFIGURE NETWORK ROLE
echo ">>> Configuring mesh role..." >> "$LOG"

if [ $RAM_MB -ge 2048 ]; then
    ROLE="gateway"
    echo ">>> Role: GATEWAY (high-performance node)" >> "$LOG"
else
    ROLE="relay"
    echo ">>> Role: RELAY (lightweight forwarding)" >> "$LOG"
fi

setprop persist.sys.sos.role $ROLE

# 3. ENABLE IP FORWARDING & NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# Auto-NAT on any WAN interface
for iface in wlan0 rmnet_data0 eth0 usb0 bt-pan; do
    iptables -t nat -A POSTROUTING -o $iface -j MASQUERADE 2>/dev/null || true
done

# 4. SETUP WIREGUARD
echo ">>> Configuring WireGuard VPN..." >> "$LOG"

if command -v wg &>/dev/null; then
    mkdir -p /data/sos/wireguard
    
    # Generate keypair on first boot
    if [ ! -f /data/sos/wireguard/privatekey ]; then
        wg genkey | tee /data/sos/wireguard/privatekey | wg pubkey > /data/sos/wireguard/publickey
        chmod 600 /data/sos/wireguard/privatekey

        cat > /data/sos/wireguard/wg-sos.conf << WGEOF
[Interface]
PrivateKey = $(cat /data/sos/wireguard/privatekey)
Address = 10.73.0.$(shuf -i 2-254 -n 1)/24
DNS = 1.1.1.1

# Peers are auto-discovered via mesh beacon
# and added dynamically by sos-mesh-daemon
WGEOF
        echo ">>> WireGuard keypair generated." >> "$LOG"
    fi
else
    echo ">>> WARNING: WireGuard not available. VPN disabled." >> "$LOG"
fi

# 5. START MESH SERVICES
echo ">>> Starting SOS Mesh services..." >> "$LOG"

# Create mesh Wi-Fi network
nmcli con add type wifi ifname wlan0 con-name SOS-MESH \
    ssid "SOS-RESGATE-MESH" mode adhoc \
    ipv4.method shared ipv6.method ignore \
    wifi-sec.key-mgmt wpa-psk wifi-sec.psk "sos-resgate-2026" \
    2>/dev/null || true

# 6. ENABLE BLUETOOTH PAN
echo ">>> Enabling Bluetooth PAN bridge..." >> "$LOG"
bt-network -s nap br0 2>/dev/null &

# 7. CLEANUP
rm -f "$MARKER"
echo "$(date) - SOS First Boot Complete! Role: $ROLE" >> "$LOG"
echo ">>> FIRST BOOT COMPLETE. Device is now a SOS Mesh Node ($ROLE)." >> "$LOG"
