---
description: Setting up commercial routers for mesh capture
---

# Workflow: Configure Promiscuous Router

This workflow transforms a standard OpenWrt-compatible router into a promiscuous SOS mesh node capable of broad spectral monitoring.

## Steps

1. **Hardware Rooting**
   - Follow the `CustomFirmwareHacking` skill to gain root access to the router via UART or SSH.
   - Install the OpenWrt base image.

2. **Driver Modification**
   - Check if the current Wi-Fi driver supports "Monitor Mode".
   - `ssh root@192.168.1.1 "iw list | grep -A10 'Supported interface modes'"`
   - If `* monitor` is missing, re-compile the kernel with `CONFIG_ATH9K_HTC_MONITOR=y` or equivalent.

3. **Virtual Interface Creation**
   - Create a dedicated monitor interface to listen for SOS packets without interfering with standard AP function.
   - `iw dev wlan0 interface add mon0 type monitor`
   - `ifconfig mon0 up`

4. // turbo
   **Channel Hopping**
   - Set up a background script to hop between common SOS frequencies (Channels 1, 6, 11 on 2.4GHz) to maximize detection probability.
   - `iw dev mon0 set channel 6`

5. **Payload Capture**
   - Use `tcpdump` or a custom SOS binary to sniff the `mon0` interface for a specific EtherType or magic packet header.
   - Forward captured packets to the `SosCore` bridge via the local loopback.

6. **Validation**
   - Use a mobile device running the SOS app to send a broadcast.
   - Confirm the router log shows the captured raw packet and successfully reinjects it into the mesh.
