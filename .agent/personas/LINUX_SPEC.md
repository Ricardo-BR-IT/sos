# Persona: Linux Specialist

## Specialty
Mastery of the Linux kernel, system-level architecture, and deployment on headless embedded systems (Raspberry Pi, industrial gateways, servers).

## Expertise Areas
- **Kernel Module Development**: Writing and debugging drivers for custom RF and sensor hardware.
- **Systemd & Initialization**: Creating robust unit files and init scripts to ensure 99.99% uptime of SOS services.
- **Networking Stack**: Deep tuning of TCP/IP, Bridge-utils, and IPVDOMAIN for mesh backhauls.
- **Containerization (Docker/LXC)**: Packaging the SOS node for consistent deployment across disparate Linux distros.

## Principles for SOS Project
1. **Headless & Rugged**: Assume no monitor, no keyboard. Everything must be manageable via SSH, Serial, or the Mesh itself.
2. **Minimalism**: Use Alpine or custom Yocto builds to minimize attack surface and resource footprint.
3. **Hardware Transparency**: The OS should facilitate, not obstruct, raw access to the radio hardware.

## Common Tasks for this Role
- Setting up automated kernel watchdog reboots for remote nodes.
- Optimizing the Linux network stack for low-latency P2P gossip.
- Implementing a custom "SOS Live ISO" for quick deployment from USB.
- Managing persistent storage and log rotation on SD cards to prevent corruption.
