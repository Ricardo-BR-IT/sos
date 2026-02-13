---
name: PropagationModeling
description: Mathematical models for range estimation, path loss, and signal penetration across different mediums.
---

# Skill: Propagation Modeling

This skill includes the mathematical tools required to estimate the coverage and reliability of SOS mesh links.

## 1. Free Space Path Loss (FSPL)
The baseline model for clear line-of-sight (LoS) links:
$FSPL_{dB} = 20 \log_{10}(d) + 20 \log_{10}(f) + 20 \log_{10}(\frac{4 \pi}{c}) - G_{tx} - G_{rx}$
*where $d$ is distance, $f$ is frequency, and $G$ is antenna gain.*

## 2. Longley-Rice Model (ITM)
Used for irregular terrain. Account for:
- **Refraction**: Signal bending due to atmospheric layers.
- **Diffraction**: Signals "hugging" the curve of hills or buildings.
- **Scattering**: Signal dispersal due to vegetation or rain.

## 3. Fresnel Zone Clearance
To ensure maximum signal strength, a specific zone around the direct path must be clear of obstacles.
$R = \sqrt{\frac{\lambda \times d_1 \times d_2}{d_1 + d_2}}$
*where $R$ is the radius of the first Fresnel zone.*
**Rule of thumb**: At least 60% of the first Fresnel zone should be clear.

## 4. Link Budget Calculation
$P_{rx} (dBm) = P_{tx} (dBm) + G_{tx} (dBi) - L_{tx\_cable} (dB) - L_{path} (dB) + G_{rx} (dBi) - L_{rx\_cable} (dB)$
To maintain a connection: $P_{rx} > Sensitivity_{threshold} + FadeMargin$.
*Fade Margin recommended: 10-20dB for disaster scenarios.*

## 5. Acoustic Propagation
Sound speed depends on the medium (~343 m/s in air, ~1500 m/s in water).
Attenuation increases significantly with frequency and humidity in air.
$Loss = Absorption + Spreading$
For underwater: $Loss_{dB} = 20 \log_{10}(R) + \alpha R \times 10^{-3}$
*where $\alpha$ is the absorption coefficient in dB/km.*
