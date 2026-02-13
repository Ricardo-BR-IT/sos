---
description: Workflow for porting C/Assembly modules to the Flutter/Kotlin core
---

# Workflow: Legacy Code Integration

This workflow provides instructions for integrating low-level code (Assembly, C, C++, C#) into the modern SOS high-level repositories.

## Steps

1. **Module Isolation**
   - Identify the legacy logic (e.g., a specific encryption algorithm in C or a serial driver in Assembly).
   - Wrap the logic in a clean C-interface (extern "C") to prevent name mangling.

2. **Cross-Compilation**
   - Use the appropriate toolchain (GCC for ARM/Linux, Clang for Android/iOS, MSVC for Windows).
   - Compile into a shared library:
     - `.so` for Linux/Android.
     - `.dll` for Windows.
     - `.dylib` for macOS/iOS.

3. **Dart/Flutter Binding (FFI)**
   - Use `package:ffi` in the Dart side.
   - Map C-types to Dart-FFI types (e.g., `Int32`, `Pointer<Uint8>`).
   - Example binding:
     ```dart
     final DynamicLibrary nativeLib = DynamicLibrary.open('liblegacy_modem.so');
     final int Function(int, int) calculateCrc = nativeLib
       .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('calculate_crc')
       .asFunction();
     ```

4. **Kotlin Binding (JNI)**
   - For the JVM Node, use JNI (Java Native Interface).
   - Create a Kotlin `external` function and generate headers using `javac -h`.
   - Implement the JNI bridge in C++.

5. **Memory Safety Check**
   - Be extremely careful with manual memory allocation (`malloc`, `free`).
   - Use `NativeFinalizer` in Dart to ensure native resources are freed when the Dart object is garbage collected.

6. **Validation**
   - Create a unit test that compares the output of the legacy bridge against a reference implementation.
   - Check for memory leaks using Valgrind (Linux) or LeakDiag (Windows).
