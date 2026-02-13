---
name: CustomFirmwareHacking
description: Procedures for rooting commercial devices and installing custom SOS-ready firmware (OpenWrt/Custom).
---

# Skill: Custom Firmware Hacking

This skill covers the repurposing of commodity hardware into specialized SOS nodes.

## 1. Initial Reconnaissance
- **Identify Hardware**: Open the case and find the CPU/Wi-Fi chipset model.
- **Find the Ports**: Locate UART (GND, TX, RX, VCC) or JTAG pins.
- **Chipset Compatibility**: Cross-reference with the [OpenWrt Table of Hardware](https://openwrt.org/toh/start).

## 2. Serial Access (The UART Shell)
1. Connect a USB-to-UART adapter (3.3V logic level is standard).
2. Set terminal to 115200 8N1.
3. Interrupt the bootloader (U-Boot) by pressing a key during boot.
4. From the bootloader shell, you can often override kernel parameters to get a root shell (`init=/bin/sh`).

## 3. Flash Memory Dumping
- Use `flashrom` or an External Programmer (CH341A) to dump the raw binary from the SPI flash chip.
- Use `binwalk -e firmware_dump.bin` to extract the filesystem (SquashFS/JFFS2).

## 4. Promiscuous Mode Enablement
- In OpenWrt, use `iw dev wlan0 set monitor none` to enable monitor mode.
- If the stock driver doesn't support it, you may need to cross-compile a patched driver (e.g., `ath9k-htc`) using the OpenWrt SDK.

## 5. Security Best Practices
- **Watchdog Timer**: Always configure the hardware watchdog to reboot the node if the custom SOS service crashes.
- **Signed Boot**: Do not disable secure boot unless necessary; try to sign your custom firmware with keys accepted by the hardware if possible.
