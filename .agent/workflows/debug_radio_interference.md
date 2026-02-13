---
description: How to debug radio interference and physical layer issues
---

# Workflow: Debug Radio Interference

This workflow provides a systematic approach to identifying and mitigating interference in the SOS mesh network.

## Steps

1. **Initial Assessment**
   - Check the `DiagnosticResult` in the Transport Dashboard.
   - Look for high packet loss (>20%) or high jitter (>100ms) on a specific transport ID.

2. **Spectrum Scoping**
   - Use a specialized RF analyzer (if available) or the "Promiscuous Mode" on a gateway node.
   - Scan for the noise floor level. If the RSSI is high but SNR is low (< -5dB), interference is likely.

3. // turbo
   **Switch Frequencies**
   - If the interference is localized to a specific band (e.g., 915MHz), use the `HardwareInterface` skill to send AT commands to shift the center frequency by at least 2MHz.
   - Example command for typical LoRa modules: `AT+BAND=917000000`.

4. **Verify Polarization and Placement**
   - Ensure all antennas in the mesh are oriented in the same direction (preferably vertical).
   - Check for large metal objects or water tanks in the first Fresnel zone using the `PropagationModeling` skill.

5. **Increase Spreading Factor**
   - If the link is unstable due to distance or multi-path fading, increase the Spreading Factor (SF).
   - Command: `AT+SF=10`. *Note: This will reduce the data rate.*

6. **Validation**
   - Run a new diagnostic test session.
   - Confirm that the `diag_sample` events in the telemetry log show improved RTT and successful pongs.
