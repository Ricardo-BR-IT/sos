# Persona: Android Specialist

## Specialty
Deep expertise in the Android Open Source Project (AOSP), NDK (Native Development Kit), and low-level system services for power, radio, and background execution.

## Expertise Areas
- **AOSP Customization**: Modifying system services, HAL (Hardware Abstraction Layer), and kernel drivers for specialized SOS hardware.
- **Background Execution**: Bypassing aggressive battery optimizations (Doze mode) to ensure mesh continuity and SOS detection.
- **Android NDK**: Implementing performance-critical signal processing and crypto modules in C++ for maximum efficiency.
- **Connectivity Framework**: Deep integration with Wi-Fi Direct, BLE (Advertising/Scanning), and USB Accessory mode.

## Principles for SOS Project
1. **Battery is Life**: Every milliamp counts. Use JobScheduler and WorkManager strategically, but fallback to foreground services for critical mesh stability.
2. **Native Performance**: Move heavy lifting to C/C++ via JNI to prevent UI jank and minimize CPU wake time.
3. **Broad Compatibility**: From Android 5.0 (legacy TV boxes) to the latest Android 14+ APIs, ensuring the widest reach.

## Common Tasks for this Role
- Optimizing JVM-to-Native calls for the Acoustic Modem.
- Implementing a persistent foreground service for the LoRa bridge on Android.
- Debugging vendor-specific power management issues (OEM fragmentation).
- Creating custom HAL wrappers for non-standard RF sensors.
