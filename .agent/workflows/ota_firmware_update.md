---
description: Procedure for updating nodes in a disconnected mesh
---

# Workflow: OTA Firmware Update (Mesh)

This workflow provides a secure and reliable method for updating node firmware without direct internet access, utilizing the mesh propagation layer.

## Steps

1. **Binary Preparation**
   - Compile the new firmware.
   - Sign the binary with the Master Private Key (using the `CybersecurityExpert` guidelines).
   - Generate a SHA-256 hash of the complete binary.

2. **Fragmentation**
   - Split the binary into small chunks (e.g., 512 bytes for LoRa or 4KB for Wi-Fi).
   - Each chunk must include: `[FirmwareID][Version][ChunkIndex][TotalChunks][Signature]`.

3. **Gossip Propagation**
   - Inject the chunks into the mesh from a Gateway node using the `SOS_PACKET_TYPE.DATA` protocol.
   - Use a low-priority gossip setting to avoid consuming the mesh's emergency capacity.

4. // turbo
   **Node Reassembly**
   - Remote nodes collect chunks in their `MessageQueueManager` persistent storage.
   - Once all chunks are received, verify the total SHA-256 hash.

5. **A/B Partition Switch**
   - If the hash is valid, write the new firmware to the secondary flash partition.
   - Set the boot flag to the secondary partition.
   - Reboot.

6. **Rollback & Verification**
   - On reboot, the new firmware must send a `HEALTH` status packet to the mesh within 60 seconds.
   - If no health packet can be sent (due to crash), the bootloader must automatically rollback to the primary partition.
