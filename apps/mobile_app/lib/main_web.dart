import 'package:flutter/material.dart';
import 'package:sos_transports/sos_transports.dart';

void main() {
  runApp(const MinimalWebApp());
}

class MinimalWebApp extends StatelessWidget {
  const MinimalWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force usage of HybridTransport to test compilation
    final t = HybridTransport();
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('SOS Web Minimal: ${t.descriptor.id}')),
      ),
    );
  }
}
