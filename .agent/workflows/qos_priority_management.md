---
description: Managing traffic priority (SOS > Voice > Chat)
---

# Workflow: QoS Priority Management

This workflow defines the prioritization rules for packets in the SOS mesh network to ensure critical alerts are never blocked by low-priority traffic.

## Steps

1. **Packet Classification**
   - Every `TransportPacket` must have a `Priority` field (derived from its `SosPacketType` or specific metadata).
   - **T1 - Critical (P0)**: `SosPacketType.SOS`. Absolute priority.
   - **T2 - High (P1)**: `SosPacketType.DATA` with 'triage' flag, `PING`/`PONG` for high-risk nodes.
   - **T3 - Medium (P2)**: standard `DATA` (chat), `HELLO`.
   - **T4 - Low (P3)**: Telemetry pings, OTA firmware chunks.

2. **Queue Scheduling**
   - Implement "Priority Queuing" (PQ) in the `MessageQueueManager`.
   - During transmission, always send all T1 packets before any T2, even if T2 has been in the queue longer.

3. // turbo
   **Congestion Control**
   - If the queue is > 80% full, automatically drop T4 packets.
   - If the SNR on a transport drops below -10dB, reduce the T3/T4 broadcast frequency to preserve T1/T2 airtime.

4. **Mesh Relay Priority**
   - Nodes relaying packets must prioritize forwarding T1/T2 packets from other nodes over their OWN T3/T4 packets.

5. **Validation**
   - Simulate a "Gossip Storm" by sending 100 T3 chat messages.
   - While the storm is active, trigger an SOS.
   - Confirm the SOS packet arrives at the destination with minimal latency, bypassing the chat queue.
