---
description: Workflow for responding to critical medical alerts from the mesh.
---

# Workflow: Medical Emergency Response

Use the `BioSensorIntegration` skill for sensor details.

## Steps

1. **Receive Medical Alert Packet**
   - Mesh receives a packet with `type: MEDICAL_SOS`.
   - Validate signature and decrypt payload.

2. **Parse Vital Signs**
   - Extract `hr`, `spo2`, `ecg_data`, `fall_detected`, `temp_c` from JSON.
   - Display on the "First Responder View" of the Desktop Station.

3. **Triage & Prioritize**
   - Apply QoS rules (use `qos_priority_management` workflow).
   - If `spo2 < 90` or `fall_detected == true`, elevate to P0 (highest priority).

4. **Dispatch Responder**
   - Show location on map (if GPS available in packet).
   - Notify nearest responder via SMS or push notification (if backhaul is available).

5. **Log to Telemetry**
   - Write anonymized event to the `TelemetryService`.
   - **CRITICAL**: Do NOT log specific medical values to general telemetry without explicit user consent.

6. **Follow Up**
   - When responder confirms contact, update packet status to `RESOLVED`.
