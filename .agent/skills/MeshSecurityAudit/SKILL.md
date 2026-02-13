---
name: MeshSecurityAudit
description: Protocols for verifying end-to-end encryption, signature integrity, and anti-interference mechanisms.
---

# Skill: Mesh Security Audit

This skill provides the technical steps to verify the security and resilience of the SOS mesh network.

## 1. Cryptographic Verification
- **Signature Integrity**: Every `SosEnvelope` must be signed with Ed25519. Verify that the signature is checked *before* any payload parsing occurs.
- **Key Exchange (Perfect Forward Secrecy)**: In P2P chats, ensure that ephemeral keys are used (X25519) so that past messages cannot be decrypted even if the node's long-term identity key is compromised.
- **Root-of-Trust (RoT)**: On hardware nodes, verify that the public keys of authorized "Gateway" nodes are pinned in secure storage.

## 2. Anti-Jamming & Anti-Spoofing
- **Frequency Hopping**: If using LoRa, ensure that sequential packets are transmitted on different pseudo-randomly selected center frequencies.
- **Sequence Analysis**: Monitor the `seq` number in diagnostic packets. If large gaps or duplicates from unknown sources appear, flag the node for a potential "Replay Attack".
- **Time-Stamping**: SOS messages must have a cryptographically signed timestamp. Discard packets that deviate by more than [X] minutes from the local RTC (if synchronized).

## 3. Traffic Analysis Prevention
- **Packet Padding**: Ensure all packets sent over high-risk links have uniform size (padding) to prevent traffic correlation based on packet length.
- **Chaff Traffic**: In high-security modes, the gateway can emit "chaff" (fake encrypted packets) to hide the real timing of emergency SOS messages.

## 4. Audit Checklist
[ ] Are all private keys stored in non-exportable hardware partitions?
[ ] Does the gossip protocol limit the number of re-broadcasts per node to prevent "Energy Traps"?
[ ] Is firmware signed and verified before boot (Secure Boot)?
[ ] Are pings/pongs signed to prevent "Latency Spoofing"?
