---
description: Counter-measures against signal interception
---

# Workflow: SIGINT Defensive Ops

This workflow provides procedures for protecting the SOS mesh and its users from hostile signal intelligence (SIGINT) and electronic surveillance.

## Steps

1. **Spectral Awareness**
   - Use the `ELECTRONIC_WARFARE_SPEC` persona to analyze the noise floor.
   - Look for "Periodic Sweeps" or "Broadband Noise" indicating active monitoring or jamming.

2. **EMCON (Emission Control)**
   - Trigger "Silent Mode" on all non-essential nodes.
   - Reduce beacon frequency from 5s to 60s.
   - Use the `TacticalModulation` skill to enable High-Rate Burst mode.

3. **Polarization Obfuscation**
   - Randomly change the physical orientation of antennas (if possible) to complicate signal reception by stationary listeners.
   - Use circular polarization for base stations to mitigate multi-path and cross-pol issues.

4. // turbo
   **Traffic Decoys**
   - Deploy "Chaff Nodes" (cheap ESP32s) that emit random encrypted noise to camouflage real SOS message timing.
   - Mix real traffic with dummy "Heartbeat" packets of identical size.

5. **Location Guarding**
   - Strip all GPS metadata from non-SOS packets.
   - Encrypt the "Sender ID" inside an onion layer (using the `OnionRouting` skill) before the packet leaves the local node.

6. **Validation**
   - Use a secondary listener node to attempt to "Fingerprint" the mesh.
   - If the listener cannot distinguish between SOS traffic and decoy noise, the defensive state is verified.
