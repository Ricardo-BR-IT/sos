import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Protocol Integration Layer.
/// Coordinates DTN, secure, and base transports.
class ProtocolIntegration extends TransportLayer {
  final List<TransportLayer> _transports;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'protocol_integration',
    name: 'Protocol Integration Layer',
    technologyIds: ['dtn', 'oscore', 'edhoc'],
    mediums: ['any'],
    requiresGateway: false,
    notes: 'Coordinates multiple transport layers for protocol failover.',
  );

  ProtocolIntegration({required List<TransportLayer> transports})
      : _transports = transports;

  @override
  TransportDescriptor get descriptor => kDescriptor;
  @override
  TransportHealth get health => _health;
  @override
  String? get localId => _localId;
  @override
  void setLocalId(String id) {
    _localId = id;
    for (final t in _transports) {
      t.setLocalId(id);
    }
  }

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      for (final transport in _transports) {
        await transport.initialize();
        transport.onPacketReceived.listen((packet) {
          _incomingController.add(packet);
        });
      }

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  /// Get the best available transport
  TransportLayer? getBestTransport() {
    for (final t in _transports) {
      if (t.health.availability == TransportAvailability.available) {
        return t;
      }
    }
    return _transports.isNotEmpty ? _transports.first : null;
  }

  @override
  Future<void> broadcast(String message) async {
    final best = getBestTransport();
    if (best != null) await best.broadcast(message);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    final best = getBestTransport();
    if (best != null) await best.send(packet);
  }

  @override
  Future<void> connect(String peerId) async {
    for (final t in _transports) {
      await t.connect(peerId);
    }
  }

  @override
  Future<void> dispose() async {
    for (final t in _transports) {
      await t.dispose();
    }
    await _incomingController.close();
  }
}
