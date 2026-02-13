---
name: BioSensorIntegration
description: Protocols for integrating health sensors (HR, SpO2, ECG) into the SOS mesh.
---

# Skill: Bio-Sensor Integration

This skill covers the technical aspects of connecting medical-grade biosensors to the SOS node and transmitting vital data.

## 1. Common Sensor ICs
| Sensor Type | IC Model    | Interface | Key Metric       | Note                               |
|-------------|-------------|-----------|------------------|------------------------------------|
| Heart Rate  | MAX30102    | I2C       | HR (bpm), SpO2 (%)| Uses red/IR LEDs, reflective mode. |
| ECG         | AD8232      | Analog    | Raw Voltage (mV) | Requires signal conditioning.      |
| Temperature | MLX90614    | I2C       | Surface °C       | Non-contact IR thermometer.        |
| Accelerometer| MPU6050    | I2C       | G-Force, Gyro    | For fall detection and motion.     |

## 2. Data Packet Format
The medical payload within a `TransportPacket` should be structured as:
```json
{
  "med": {
    "hr": 75,
    "spo2": 98,
    "ecg_lead": "II",
    "ecg_data_b64": "...",
    "temp_c": 36.7,
    "fall_detected": false,
    "ts": 1707450000
  }
}
```

## 3. Privacy and Encryption
- **CRITICAL**: All medical data MUST be end-to-end encrypted.
- Use the `MeshSecurityAudit` skill to verify payload is encrypted before leaving the local node.
- The `recipientId` for medical packets should be a pre-shared public key of an authorized "Rescue Coordinator".

## 4. On-Device Anomaly Detection
- **Arrhythmia**: Detect irregular R-R intervals from ECG.
- **Hypoxia**: SpO2 < 90% for > 30 seconds triggers an automatic SOS event escalation.
- **Fall**: Sudden high G-force followed by no motion for > 60 seconds.
