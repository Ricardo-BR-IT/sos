---
name: DistributedConsensus
description: Implementing lightweight consensus (Raft/Paxos variants) to manage global state in a decentralized mesh.
---

# Skill: Distributed Consensus

This skill provides the mechanisms for reaching agreement on critical mesh parameters (e.g., node registration, shared schedules) without a central server.

## 1. Consensus Models for Mesh
- **Raft (Leader-Based)**: Good for stable pockets of nodes. Elect a leader to coordinate updates. Not ideal for highly dynamic meshes.
- **Paxos (Leaderless)**: Highly resilient but bandwidth-intensive.
- **Lamport Timestamps**: A simple way to order events ($O_1 \to O_2$) to resolve conflicts in eventual consistency scenarios.

## 2. The "Gossip-Consensus" Hybrid
Instead of a full global lock, use:
1. **Local Consensus**: Nodes in physical proximity agree on a state (e.g., "This bridge is down").
2. **Gossip Propagation**: The signed consensus result is propagated to the rest of the mesh.
3. **Conflict Resolution**: If two areas report different states, use the most recent signed timestamp or the report with the most "witness" signatures.

## 3. Quorum Requirements
- A change is only committed if $Q = \frac{N}{2} + 1$ nodes sign it.
- **Dynamic Quorums**: In a fragmented mesh, the "N" (total nodes) is unknown. Use a localized quorum of known neighbors.

## 4. Byzantine Fault Tolerance (BFT)
Implement "Proof of Authority" where only nodes with specific high-trust key-pair can participate in critical state voting (e.g., Rescue Ops Coordinators).
