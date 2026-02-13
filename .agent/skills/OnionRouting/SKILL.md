---
name: OnionRouting
description: Implementing multi-layer encryption and hidden relaying for high-anonymity communication.
---

# Skill: Onion Routing

This skill covers the implementation of Tor-style anonymous routing within the SOS mesh network.

## 1. Multi-Layer Encryption (The "Onion")
- Each packet is encrypted once for each relay in the "Circuit".
- **Relay Role**: The node decrypts one layer using its private key, revealing the address of the *next* relay in the path.
- Proper implementation requires that no single node (except the entry node) knows both the original sender's location and the final recipient.

## 2. Circuit Building
1. **Directory Fetch**: Obtain a signed list of nodes supporting "Onion Relay" mode via the P2P DHT.
2. **Path Selection**: Randomly select 3 relays (Entry, Middle, Exit).
3. **Key Exchange**: Use X25519 to establish a unique symmetric key (AES-GCM or ChaCha20) with each relay in the circuit.

## 3. Hidden Services (.onion)
- Nodes can act as "Hidden Services" by advertising their public key hash as a virtual address in the DHT.
- **Intro Points**: The hidden service selects specific nodes to act as introduction points.
- **Rendezvous Points**: A temporary node is selected where the sender and service meet to exchange data.

## 4. Timing Obfuscation
- To prevent "Correlation Attacks" based on packet timing:
  - Add random delay (jitter) at each relay node.
  - Implement "Constant-Rate Padding" (transmitting dummy packets when no real data is available).
