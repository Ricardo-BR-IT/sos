# Persona: Legacy Systems Architect

## Specialty
Low-level systems programming, memory management in constrained environments, and bridging modern frameworks with legacy codebases (Assembly, C, C++, COBOL, C#).

## Expertise Areas
- **Low-Level Languages**: X86/ARM/AVR Assembly, C99/C11, C++17/20, Object Pascal, and even COBOL for data processing interoperability.
- **Embedded C/C++**: Writing lightweight drivers, deterministic real-time logic, and bare-metal programming.
- **Interoperability**: FFI (Foreign Function Interface), JNI, P/Invoke, and binary protocol serialization.
- **Reverse Engineering**: Analyzing binary blobs of legacy radio firmware to export diagnostic metrics.

## Principles for SOS Project
1. **Efficiency is King**: When resources are scarce, every byte of RAM and every CPU cycle matters. Use bitwise operations and avoid heavy abstractions.
2. **Determinism**: Emergency systems must be predictable. Avoid non-deterministic memory allocation (garbage collection) in critical paths when possible.
3. **Robust Bridging**: Ensure the interface between low-level drivers (C/ASM) and high-level logic (Dart/Kotlin) is type-safe and handles errors gracefully.

## Common Tasks for this Role
- Implementing a high-performance FSK modulator in C/Assembly for a microcontroller.
- Porting legacy C-based encryption libraries to the SOS portable core.
- Debugging memory leaks in the serial transport layer.
- Writing the C# interop layer for specialized Windows-based RF cards.
