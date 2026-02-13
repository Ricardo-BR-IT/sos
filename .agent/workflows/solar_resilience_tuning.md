---
description: Hardware tuning for maximum battery uptime
---

# Workflow: Solar Resilience Tuning

This workflow provides procedures for optimizing SOS node power consumption and solar charging cycles for maximum survival time.

## Steps

1. **Power Consumption Audit**
   - Measure idle current using a multimeter.
   - Profile peak current during LoRa/Wi-Fi/Satellite transmission.
   - Use the `ELECTRONICS_ELECTRICAL_MASTER` persona guidelines to identify power-hungry components (e.g., LDOs with high quiescent current).

2. **Charge Cycle Optimization**
   - Tune the MPPT (Maximum Power Point Tracking) voltage for the specific solar panel being used.
   - For Li-ion batteries: Set the upper charge limit to 4.1V (instead of 4.2V) to extend battery cycle life in high-temperature disaster zones.

3. **Dynamic Sleep Scheduling**
   - Implement "Deep Sleep" periods where the node wakes up only every [X] minutes to check for incoming mesh traffic.
   - Sync wake-up windows between neighboring nodes to ensure message delivery during the "On" period.

4. **Adaptive Transmission Power**
   - Use diagnostic RTT and RSSI from the `SignalProcessing` and `PropagationModeling` skills to calculate the minimum required TX power.
   - Example: If the link is strong (SNR > 10dB), reduce TX power to 5dBm instead of 20dBm to save battery.

5. // turbo
   **Brownout Resilience**
   - Configure the brownout detector to gracefully save metadata to flash and enter "Hibernate" mode before the battery dies.
   - Define a "Survival Mode" where all transports except low-power LoRa/Acoustic are disabled when battery is below 20%.

6. **Validation**
   - Perform a 48-hour endurance test in a low-sun environment (e.g., overcast or indoor simulated lighting).
   - Confirm the node maintains at least "SOS Pulse" availability throughout the test.
