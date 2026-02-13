---
description: Bootstrapping a zero-infrastructure P2P network
---

# Workflow: Deploy P2P Gossip Mesh

This workflow provides the sequence for bootstrapping a fully decentralized SOS network in a zero-infrastructure environment.

## Steps

1. **Local Discovery**
   - Nodes start by broadcasting `HELLO` packets on all available physical transports (Wi-Fi, BLE, LoRa).
   - Use the `DECENTRALIZED_P2P_SPECIALIST` guidelines for initial handshake.

2. **DHT Joining**
   - If at least one "Anchor Node" is reachable via IP, join the global Kademlia DHT.
   - If not, the initial cluster of local nodes forms a "Private Island DHT".

3. **Gossip Initialization**
   - Configure the `fanout` factor (default: 3). Each node will relay a new unique packet to at least 3 neighbors.
   - Implement "Digest Exchange": nodes periodically exchange hashes of their seen packets to fill gaps in their local history.

4. **Trust Establishment**
   - Perform OOB (Out-of-Band) key verification if possible (QR code scan).
   - Use the `DistributedConsensus` skill to agree on the "Network Time" (using lamport timestamps) to prevent replay attacks.

5. // turbo
   **Network Expansion**
   - As new nodes join, the DHT automatically re-balances.
   - Verify the "Graph Diameter" using diagnostic pings. If a ping requires too many hops (> 15), trigger a "Relay Density Increase" alert.

6. **Validation**
   - Send a test DATA packet from one end of the mesh.
   - Confirm all active nodes eventually receive the packet via the gossip layer.
