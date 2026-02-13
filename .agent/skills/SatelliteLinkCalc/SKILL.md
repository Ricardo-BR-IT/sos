---
name: SatelliteLinkCalc
description: Link budget calculations for satellite ground stations, accounting for orbital dynamics and atmospheric loss.
---

# Skill: Satellite Link Calculation

This skill provides the calculations needed to verify a successful data link between an SOS ground node and a satellite constellation (LEO/MEO/GEO).

## 1. General Link Budget Equation
$Pr = Pt + Gt + Gr - Lk - La - Lm$
- **Pr**: Received power (dBW)
- **Pt**: Transmitter power (dBW)
- **Gt/Gr**: Transmit/Receive antenna gains (dBi)
- **Lk**: Free Space Path Loss (dB)
- **La**: Atmospheric absorption loss (dB)
- **Lm**: Miscellaneous losses (polarization mismatch, cable loss, antenna pointing error)

## 2. Free Space Path Loss (FSPL) - Satellite
$FSPL (dB) = 20 \log_{10}(d) + 20 \log_{10}(f) + 92.45$
*where d is distance in km and f is frequency in GHz.*
For LEO satellites (Starlink), d varies between ~550km (zenith) to ~1500km (horizon).

## 3. Signal-to-Noise Ratio (C/N0)
$C/N_0 = Pr - 10 \log_{10}(k T_{sys})$
- **k**: Boltzmann constant ($-228.6$ dBW/K/Hz)
- **Tsys**: System noise temperature (K)

## 4. Doppler Shift Adjustment
For LEO satellites moving at ~7.5 km/s:
$\Delta f = f \times \frac{v_{relative}}{c}$
At 10GHz, Doppler shift can reach $\pm 250$ kHz. The modem must implement AFC (Automatic Frequency Control) or use ephemeris data to pre-compensate.

## 5. Fresnel Zone for Ground Stations
Ensure the field of view (FOV) is clear of obstacles down to the minimum elevation angle (typically 25-40 degrees for LEO).
$FOV_{clear} = 360^\circ \text{ Azimuth} \times \text{Elevation}_{min}$
