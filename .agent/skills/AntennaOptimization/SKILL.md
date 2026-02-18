---
name: AntennaOptimization
description: Procedures for designing, tuning, and optimizing antennas for maximum range and efficiency.
---

# Skill: Antenna Optimization

This skill provides the fundamental knowledge for antenna design in the SOS project.

## 1. Antenna Selection by Use Case
| Use Case              | Recommended Type      | Gain    | Notes                                      |
|-----------------------|-----------------------|---------|--------------------------------------------|
| Handheld/Wearable     | Quarter-wave Whip     | 2 dBi   | Omnidirectional, compact.                  |
| Fixed Base Station    | Yagi-Uda (5-elem)     | 9-12 dBi| Directional, requires alignment.           |
| Vehicle Mount         | 5/8 Wave Ground Plane | 5 dBi   | Omnidirectional, good mobile range.        |
| Gateway/Relay         | Helical (RHCP)        | 10 dBi  | Circular polarization, multi-path resist. |

## 2. Impedance Matching
- **Target**: 50 Ω for most RF equipment.
- **Tool**: Use a NanoVNA to measure $VSWR$ (Voltage Standing Wave Ratio). Target $VSWR < 1.5$.
- **Matching Network**: L-networks (Series L, Shunt C) are simple and effective. Use the Smith Chart.

## 3. Fresnel Zone Clearance
For Line of Sight (LOS), the first Fresnel zone must be at least 60% clear:
$$r = 17.32 \times \sqrt{\frac{d}{4 \times f}}$$
- $r$: Fresnel radius in meters.
- $d$: Total link distance in km.
- $f$: Frequency in GHz.

## 4. Polarization
- **Mismatch Loss**: A -3dB penalty if one antenna is vertical and the other horizontal.
- **Recommendation**: Use consistent polarization (vertical is standard for LoRa).
