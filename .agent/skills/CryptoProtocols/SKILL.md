---
name: CryptoProtocols
description: Foundation for all cryptographic operations in the SOS mesh.
---

# Skill: Crypto Protocols

This skill defines the cryptographic primitives and protocols used for securing all SOS communications.

## 1. Key Algorithms
| Purpose               | Algorithm       | Key Size  | Notes                                     |
|-----------------------|-----------------|-----------|-------------------------------------------|
| Asymmetric Key Pair   | X25519          | 256-bit   | Curve25519, fast and secure.              |
| Symmetric Encryption  | ChaCha20-Poly1305| 256-bit  | AEAD, efficient on mobile CPUs.           |
| Hashing               | SHA-512         | 512-bit   | For message IDs and integrity checks.     |
| Signatures            | Ed25519         | 256-bit   | Fast, compact signatures for packets.     |

## 2. Key Exchange (ECDH)
1. Node A generates ephemeral keypair: $(a, A = aG)$.
2. Node B generates ephemeral keypair: $(b, B = bG)$.
3. Shared Secret: $S = aB = bA = abG$.
4. Derive symmetric key using HKDF: $K = HKDF(S, salt, info)$.

## 3. Packet Signing (Ed25519)
- Every `TransportPacket` SHOULD have a `sig` field.
- Signature is over: `senderId || recipientId || type || payload_hash || timestamp`.
- Verify signature before processing packet to prevent spoofing.

## 4. Perfect Forward Secrecy (PFS)
- **Ratchet**: For long-lived connections, implement a Double Ratchet protocol (similar to Signal) so that compromise of current keys does not affect past session keys.
- Update "Session Key" periodically using combined hash of previous key + new DH exchange.

## 5. Post-Quantum Readiness
- **WARNING**: Current algorithms are vulnerable to quantum computing.
- The architecture MUST be modular. Prepare to swap X25519 for Kyber-768 or similar NIST PQC standard.
