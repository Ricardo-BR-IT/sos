#!/bin/sh
# SOS NODE SETUP SCRIPT (OPENWRT) - V15.0
# Transforms a standard OpenWrt router into an SOS Mesh Node.

echo ">>> INITIATING SOS PROTOCOL V15 (OPENWRT)..."

# 1. Basic Config
uci set system.@system[0].hostname='SOS_NODE_$(cat /proc/sys/kernel/random/uuid | cut -c1-6)'
uci set system.@system[0].timezone='UTC'

# 2. Wireless (802.11s Mesh)
# Assumes 'radio0' is the 2.4GHz radio. Adjust if needed.
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.channel='1'
uci set wireless.radio0.htmode='HT20'

# Remove default wifi-iface
uci delete wireless.@wifi-iface[0]

# Create Mesh Interface
uci set wireless.sos_mesh=wifi-iface
uci set wireless.sos_mesh.device='radio0'
uci set wireless.sos_mesh.mode='mesh'
uci set wireless.sos_mesh.mesh_id='SOS_NET'
uci set wireless.sos_mesh.network='lan'
uci set wireless.sos_mesh.encryption='none' 
# (Encryption disabled for max compatibility in emergencies)

# 3. Network
uci set network.lan.ipaddr='10.0.0.1' 
# WARNING: This static IP is a placeholder. 
# Real mesh needs auto-IP (batman-adv or babeld).
# For V12 Vanilla, we rely on the user manually setting strict IPs or DHCP.

# 4. Commit
uci commit wireless
uci commit network
uci commit system

echo ">>> CONFIGURATION APPLIED. REBOOTING IN 5 SECONDS..."
echo ">>> WELCOME TO THE MESH."
/etc/init.d/network restart
