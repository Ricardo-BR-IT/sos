---
name: HardwareInterface
description: Instructions for low-level hardware communication, serial ports, and I/O management across OS platforms.
---

# Skill: Hardware Interface

This skill covers the technical requirements for communicating with physical hardware (LoRa modules, BLE cards, GPS receivers) from the SOS core.

## 1. Serial Port Communication (UART)
When interacting with serial devices (e.g., via `serial_port_win32` or `bluez`):
- **Baud Rate Matching**: Ensure the software baud rate matches the device firmware (standard: 9600, 115200).
- **Flow Control**: Verify if the hardware requires RTS/CTS (Hardware) or XON/XOFF (Software) flow control.
- **Buffering**: Use a buffer to collect partial writes/reads. Many serial modules return data in small chunks.
- **AT Commands**: When sending AT commands (e.g., `AT+TX`), always Wait for the `OK` or `ERROR` response before sending the next command.

## 2. Power over Ethernet (PoE) Management
Instructions for nodes utilizing PoE:
- **802.3af (PoE)**: Up to 15.4W. Sufficient for simple repeaters.
- **802.3at (PoE+)**: Up to 30W. Required for gateways with multiple high-power RF cards.
- **802.3bt (Hi-PoE)**: Up to 60W/90W. Required for server-grade base stations.

## 3. Platform Specifics
- **Windows**: Use registry keys under `HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM` to discover available COM ports.
- **Linux**: Check `/dev/ttyUSB*` or `/dev/ttyACM*`. Use `udev` rules to ensure persistent naming.
- **Android/iOS**: Communication with external hardware is restricted to BLE or USB-OTG (with manufacturer-specific drivers).

## 4. Hardware Diagnostics
- **Loopback Test**: Connect TX to RX on the serial port to verify software/driver stack integrity.
- **Voltage Drop Analysis**: If a module reboots during transmission, check if the power supply can handle the peak current (especially LoRa/Satellite).
