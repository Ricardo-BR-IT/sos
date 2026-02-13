---
description: Workflow for measuring, tuning, and validating antenna performance.
---

# Workflow: Antenna Tuning & Validation

Use the `AntennaOptimization` skill for theory.

## Steps

1. **Connect VNA (Vector Network Analyzer)**
   - Use a NanoVNA or similar.
   - Calibrate with SMA Open/Short/Load standards.

2. **Measure Initial S11 / VSWR**
   - Set frequency range to target band (e.g., 868-928 MHz for LoRa).
   - Record initial VSWR plot. Target: VSWR < 1.5 at center frequency.

3. **Diagnose Issues**
   - **VSWR High Everywhere**: Check cable, SMA connectors.
   - **Resonance Too Low**: Antenna element is too long. Trim slightly.
   - **Resonance Too High**: Antenna element is too short. Add extension or matching network.

4. **Apply Matching Network (if needed)**
   - Use Smith Chart tool (e.g., SimSmith) to calculate L/C values.
   - Solder components and re-measure.

5. **Validate in the Field**
   - Conduct a range test with two nodes.
   - Log RSSI values at 100m, 500m, 1km, 2km, etc.
   - Compare against calculated free-space path loss (FSPL).

6. **Document**
   - Photograph antenna, record tuning values, and commit to project docs.
