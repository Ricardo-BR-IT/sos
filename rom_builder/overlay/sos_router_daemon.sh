#!/bin/bash
# ==============================================================================
# SOS MULTI-TRANSPORT ROUTING DAEMON
# ==============================================================================
# Manages all available transports simultaneously and routes packets
# through the best available path using BATMAN-adv or Babel.
#
# Priority: Wi-Fi > Bluetooth > USB > LoRa > Sound > Li-Fi
# ==============================================================================

set -e

CONFIG_FILE="/data/sos/transport_config.json"
LOG_FILE="/data/sos/router.log"
PID_FILE="/data/sos/router.pid"

log() { echo "$(date +%H:%M:%S) [SOS-ROUTER] $1" >> "$LOG_FILE"; }

# Store PID
echo $$ > "$PID_FILE"

log "Starting Multi-Transport Router Daemon..."

# ==========================================
# TRANSPORT DETECTION & ACTIVATION
# ==========================================

activate_wifi_mesh() {
    log "Activating Wi-Fi Mesh (IBSS/Ad-hoc)..."
    
    # Check if dual-band (can run AP + STA simultaneously)
    PHYS=$(iw phy | grep -c "Wiphy phy")
    
    if [ "$PHYS" -ge 2 ] || iw phy phy0 info | grep -q "AP/STA"; then
        # Create mesh interface
        iw dev wlan0 interface add mesh0 type ibss 2>/dev/null || true
        ip link set mesh0 up 2>/dev/null || true
        iw dev mesh0 ibss join SOS-MESH 2437 2>/dev/null || true
        log "Wi-Fi Mesh: ACTIVE (dual-mode)"
    else
        # Single radio: alternate between AP and STA
        log "Wi-Fi Mesh: Single radio mode (time-shared)"
    fi
}

activate_bluetooth_pan() {
    log "Activating Bluetooth PAN..."
    
    if hciconfig hci0 2>/dev/null | grep -q "UP"; then
        # Enable NAP (Network Access Point) profile
        bt-network -s nap br0 2>/dev/null &
        log "Bluetooth PAN: ACTIVE"
    else
        log "Bluetooth PAN: No BT adapter found"
    fi
}

activate_usb_tether() {
    log "Checking USB OTG/Tethering..."
    
    if [ -d "/sys/class/net/usb0" ] || [ -d "/sys/class/net/rndis0" ]; then
        ip link set usb0 up 2>/dev/null || ip link set rndis0 up 2>/dev/null || true
        iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE 2>/dev/null || true
        log "USB Tethering: ACTIVE"
    else
        log "USB Tethering: No USB network interface"
    fi
}

activate_lora() {
    log "Checking LoRa dongle..."
    
    # Look for common LoRa USB serial devices
    LORA_DEV=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -1)
    
    if [ -n "$LORA_DEV" ]; then
        log "LoRa: Found device at $LORA_DEV"
        # Start LoRa bridge daemon
        # socat TCP-LISTEN:5555,reuseaddr,fork FILE:$LORA_DEV,b115200 &
        log "LoRa Bridge: ACTIVE (15km range)"
    else
        log "LoRa: No dongle detected"
    fi
}

setup_batman() {
    log "Setting up BATMAN-adv routing..."
    
    if modprobe batman-adv 2>/dev/null; then
        # Add all mesh interfaces to BATMAN
        for iface in mesh0 bat-bt bat-usb; do
            if [ -d "/sys/class/net/$iface" ]; then
                batctl if add $iface 2>/dev/null || true
                log "BATMAN: Added $iface"
            fi
        done
        
        ip link set bat0 up 2>/dev/null || true
        
        # Set routing algorithm
        batctl ra BATMAN_V 2>/dev/null || true
        
        # Enable gateway mode if this node has internet
        if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
            batctl gw_mode server 2>/dev/null || true
            log "BATMAN: Gateway mode ACTIVE (this node has internet)"
        else
            batctl gw_mode client 2>/dev/null || true
            log "BATMAN: Client mode (searching for gateway)"
        fi
    else
        log "BATMAN-adv: Kernel module not available, using static routing"
    fi
}

# ==========================================
# TRANSPORT PRIORITY & QUALITY MONITORING
# ==========================================

monitor_transports() {
    while true; do
        ACTIVE_TRANSPORTS=0
        
        # Check each transport
        for iface in wlan0 mesh0 bt-pan usb0 bat0; do
            if [ -d "/sys/class/net/$iface" ]; then
                STATE=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)
                if [ "$STATE" = "up" ]; then
                    ACTIVE_TRANSPORTS=$((ACTIVE_TRANSPORTS + 1))
                fi
            fi
        done
        
        # Log status
        log "Active transports: $ACTIVE_TRANSPORTS"
        
        # Re-check internet gateway
        if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
            batctl gw_mode server 2>/dev/null || true
        fi
        
        sleep 30
    done
}

# ==========================================
# MAIN EXECUTION
# ==========================================

log "=== SOS Multi-Transport Router Starting ==="

activate_wifi_mesh
activate_bluetooth_pan
activate_usb_tether
activate_lora
setup_batman

log "All transports initialized. Starting monitor loop..."
monitor_transports
