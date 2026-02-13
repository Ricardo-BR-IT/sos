#!/bin/bash
# ==============================================================================
# SOS-BOX HYDRATION — ARM/TVBOX OPTIMIZATION
# ==============================================================================
# Focus: Performance tuning, headless reliability, and mesh enforcement.
# ==============================================================================

set -e

echo ">>> [SOS-BOX] Hydrating TVBox Edition..."

# 1. HEADLESS OPTIMIZATIONS
echo ">>> Disabling unnecessary services for headless performance..."
systemctl disable gdm3 || true
systemctl disable lightdm || true
systemctl set-default multi-user.target

# 2. PERFORMANCE TUNING (ZRAM & SWAPPINESS)
echo ">>> Configuring ZRAM for low-memory TVBoxes..."
apt-get install -y zram-tools
echo "PERCENT=50" > /etc/default/zramswap
systemctl restart zramswap

# 3. MESH GATEWAY ENFORCEMENT
echo ">>> Reinforcing Mesh & Gateway rules..."
# Ensure the NAT rules are always re-applied on every interface change
cat > /etc/network/if-up.d/sos-nat <<'EOF'
#!/bin/sh
if [ "$METHOD" = "dhcp" ] || [ "$METHOD" = "static" ]; then
    iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE 2>/dev/null || true
fi
EOF
chmod +x /etc/network/if-up.d/sos-nat

# 4. POWER MANAGEMENT (TVBox Always-On)
echo ">>> Tuning CPU governor for stability..."
apt-get install -y cpufrequtils
echo 'GOVERNOR="ondemand"' > /etc/default/cpufrequtils

# 5. CLEANUP
apt-get clean
rm -rf /var/lib/apt/lists/*

echo ">>> [SOS-BOX] TVBox Hydration Complete. Node is optimized for 24/7 Mesh Gateway operation."
