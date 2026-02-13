---
description: Guide for setting up new hardware nodes
---

# Workflow: Provision Mesh Node

This workflow guides the user or technical expert through the initial setup and registration of a new physical SOS node into the mesh.

## Pre-requisites
- Hardware node with supported transport (ESP32, TVBox, Java Node).
- SOS Core software installed.
- Unique Node ID (Hash of the public key).

## Steps

1. **Hardware Preparation**
   - Connect the LoRa antenna (if applicable). *Warning: Powering a LoRa module without an antenna can damage the RF core.*
   - Connect the battery and verify stable voltage (3.7V - 4.2V for Li-Ion).

2. **Firmware/Software Setup**
   - Flash the SOS firmware or start the Node application.
   - For Java Nodes: `java -jar sos-node.jar --id [UNIQUE_ID] --port 4001`.

3. **Connectivity Verification**
   - Open the `Desktop Station` and navigate to the `Tecnologias` tab.
   - Verify if the new node is detected via `wifi_direct` or `bluetooth_le`.
   - Run a `Ping` test from the `Diagnóstico` tab targeting the new node ID.

4. **Mesh Registration**
   - The node will automatically broadcast a `HELLO` packet.
   - Neighboring nodes will respond with `HELLO_ACK`.
   - Verify the node appears in the `Peers detectados` list on the `Rede` tab.

5. **Sync Test**
   - Send a test message from the new node.
   - Confirm it is propagated through at least one jump.
   - Check the `Telemetry log` to ensure the packet TTL was correctly decremented.
