---
name: TacticalModulation
description: Frequency hopping and spread spectrum (FHSS/DSSS) for communication in hostile or contested environments.
---

# Skill: Tactical Modulation

This skill provides advanced digital modulation techniques designed for LPI (Low Probability of Interception) and LPD (Low Probability of Detection).

## 1. Frequency Hopping Spread Spectrum (FHSS)
- **Principle**: The carrier frequency rapidly switches between many channels based on a pseudo-random sequence known only to the sender and receiver.
- **Hopping Rate**: Should exceed the jamming response time (typically > 10 hops/sec for basic protection).
- **Implementation**:
  - Define a "Seed" (part of the node's long-term shared secret).
  - Use a CSPRNG (Cryptographically Secure Pseudo-Random Number Generator) to generate the next center frequency.
  - Sync the receiver using a short "preamble chirp" on a known discovery channel.

## 2. Direct-Sequence Spread Spectrum (DSSS)
- **Principle**: Higher-rate "chipping" sequence is applied to the data. This spreads the signal power over a wide bandwidth, making it look like noise to unauthorized listeners.
- **Processing Gain**: $PG = 10 \log_{10}(\frac{Chip\_Rate}{Bit\_Rate}) dB$.
- **Detection**: To detect a DSSS signal, the receiver must multiply the incoming noise-like signal by the exact synchronized chip sequence.

## 3. Burst Transmission (EMCON)
- Accumulate data and transmit in a high-speed "burst" instead of a continuous stream.
- Minimize the radio "on-time" to prevent direction-finding (DF) systems from locating the node.

## 4. Interference Nulling
- Use phased-array or multiple-antenna systems to create "nulls" in the antenna radiation pattern pointing towards the source of a known jammer.
