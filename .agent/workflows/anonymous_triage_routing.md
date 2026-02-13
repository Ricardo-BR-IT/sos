---
description: Routing critical alerts through darknet layers
---

# Workflow: Anonymous Triage Routing

This workflow ensures that even when the sender's identity and location must remain hidden, a critical SOS alert can still reach responders and be prioritized.

## Steps

1. **Anonymous Envelope Creation**
   - Use an ephemeral one-time identity for the `senderId`.
   - Strip all device-specific metadata (IMEI, Device Name).
   - Encrypt the precise location and triage data with the Public Key of the "Master Rescue Coordinator" node.

2. **Onion Circuit Setup**
   - Follow the `OnionRouting` skill to select 3 relays.
   - Construct the multi-layer encrypted bundle.

3. **Multi-Path Injection**
   - Inject the anonymous bundle into at least two different mesh transports (e.g., Wi-Fi and LoRa) to prevent single-path failure.

4. // turbo
   **Triage Prioritization**
   - Even though the packet is encrypted, the outermost header must include a verifiable "Priority Block" (signed by the sender's one-time key).
   - Mesh nodes prioritize forwarding this bundle following the `qos_priority_management` workflow.

5. **Secure Rendezvous**
   - The Rescue Coordinator decrypts the payload.
   - Help is dispatched to the coordinate.
   - Status updates are sent back through the reverse onion path.

6. **Validation**
   - Confirm that middle-relay nodes have no access to the `senderId` or the plain-text content.
   - Verify that the alert reached the Coordinator despite the multi-layer overhead.
