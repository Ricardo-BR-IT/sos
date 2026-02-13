library sos_transports_web;

// Safe exports for Web
export 'transport/transport_layer.dart';
export 'transport/base_transport.dart';
export 'transport/hybrid_transport.dart'; // Safe because it uses Registry
export 'transport/transport_descriptor.dart';
export 'transport/transport_packet.dart';
export 'transport/transport_health.dart';
export 'transport/transport_metrics.dart';
export 'transport/transport_hub.dart';
export 'transport/transport_registry.dart'; // Safe because it uses conditional imports

// Export agnostic transports if they are safe (e.g. UDP might NOT be safe depending on implementation, but let's assume pure dart logic or guarded)
// Actually UDP uses dart:io usually.
// So strict web exports should avoid anything using dart:io.

// We export the basics needed for `main.dart` to compile.
// main.dart uses:
// - HybridTransport
// - TransportBroadcaster (mixin on HybridTransport)
// - TelemetryService (from sos_kernel, not here)
// - MeshPeer (sos_kernel)
// So mainly HybridTransport.

// Note: Do NOT export BleTransport, etc. here.
