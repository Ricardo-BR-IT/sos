/// sos_kernel.dart
/// Core entry point implementing real CryptoManager integration.

import 'identity/crypto_manager.dart';
export 'identity/crypto_manager.dart';

export 'mesh/mesh_peer.dart';
export 'mesh/mesh_service.dart';
export 'mesh/sos_frame.dart';
export 'mesh/mesh_diagnostics.dart';
export 'mesh/routing_table.dart';
export 'sync/message_queue_manager.dart';
export 'protocol/sos_envelope.dart';
export 'protocol/protocol_adapter.dart';
export 'protocol/protocol_registry.dart';
export 'protocol/cap_alert.dart';
export 'protocol/robotics_protocol.dart';
export 'edition.dart';
export 'tech/technology.dart';
export 'tech/tech_registry.dart';
export 'tech/tech_matrix.dart';
export 'tech/tech_service.dart';
export 'tech/tech_coverage.dart';
export 'telemetry/telemetry_service.dart';
export 'hardware/hardware_profile.dart';
export 'services/health_service.dart';
export 'services/environmental_service.dart';
export 'services/drone_service.dart';
export 'services/dashboard_service.dart';

/// Abstract plugin class for future extensions.
abstract class SosPlugin {
  String get name;
  Future<void> initialize();
}

/// Singleton core class that holds user identity.
class SosCore {
  SosCore._internal();
  static final SosCore _instance = SosCore._internal();
  factory SosCore() => _instance;

  final CryptoManager _crypto = CryptoManager();
  bool _ready = false;

  /// Returns the actual Public Key or "LOADING" if not ready.
  String get publicKey =>
      _ready ? _crypto.publicKeyBase64 : "LOADING_IDENTITY...";

  /// Returns the crypto manager for advanced operations (signing, verification).
  CryptoManager get crypto => _crypto;

  final List<SosPlugin> _plugins = [];

  /// Initializes the Kernel: Crypto, Database, etc.
  Future<void> initialize() async {
    if (_ready) return;

    // 1. Init Crypto (Heavy lifting)
    await _crypto.initialize();

    // 2. Init Plugins
    for (var plugin in _plugins) {
      await plugin.initialize();
    }

    _ready = true;
  }

  void registerPlugin(SosPlugin plugin) {
    _plugins.add(plugin);
  }

  // Expose Crypto for signing
  Future<String> sign(String data) async => _crypto.signData(data);

  bool verifySignature({
    required String message,
    required String signatureB64,
    required String publicKeyB64,
  }) {
    return _crypto.verifySignature(message, signatureB64, publicKeyB64);
  }
}
