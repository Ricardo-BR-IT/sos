---
description: Escalation path for emergency messages
---

# Workflow: Incident Triage Flow

This workflow defines how the SOS system handles an incoming emergency request, from the victim's triggered action to the responder's arrival.

## Steps

1. **SOS Trigger**
   - User triggers SOS via `StressOptimizedUI` (One-Motion Action).
   - Local node captures location (GPS/mDNS) and basic victim vitals (if sensors available).

2. **Packet Generation**
   - `SosEnvelope` is created with `Priority=Critical`.
   - Message is signed and timestamped.
   - Initial `TTL` is set to maximum (e.g., 20) for deep mesh penetration.

3. **Mesh Propagation**
   - Node broadcasts via all available transports (BLE, Wi-Fi, LoRa, Acoustic) simultaneously.
   - Neighboring nodes receive, verify signature, and re-broadcast immediately, bypassing ordinary gossip queues.

4. **Gateway Escalation**
   - When a packet reaches a Gateway node (Satellite, Ethernet, or High-Power Radio):
     - Extract CAP (Common Alerting Protocol) metadata.
     - Transmit to the central command center (Desktop Station) via the most reliable backhaul.

5. **Responder Assignment**
   - Coordinator (using `RESCUE_OPS_COORDINATOR` guidelines) confirms receipt.
   - Status in the victim's UI changes to "Help is on the way" (Multi-Modal Feedback).
   - Responder is dispatched with the last known GPS coordinates.

6. **Closure**
   - Once responder arrives, a "Triage Closed" packet is sent to the mesh to stop further re-broadcasts of the original SOS to save energy.
