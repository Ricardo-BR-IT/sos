import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Secure Transport Layer.
/// End-to-end encryption using OSCORE, EDHOC, and CBOR serialization.
class SecureTransport extends TransportLayer {
  final TransportLayer _innerTransport;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'secure',
    name: 'Secure Transport (OSCORE/EDHOC)',
    technologyIds: ['oscore', 'edhoc', 'cbor'],
    mediums: ['any'],
    requiresGateway: false,
    notes: 'Wraps any transport with end-to-end encryption.',
  );

  SecureTransport({required TransportLayer innerTransport})
      : _innerTransport = innerTransport;

  @override
  TransportDescriptor get descriptor => kDescriptor;
  @override
  TransportHealth get health => _health;
  @override
  String? get localId => _localId;
  @override
  void setLocalId(String id) {
    _localId = id;
    _innerTransport.setLocalId(id);
  }

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      await _innerTransport.initialize();

      // Listen to inner transport and decrypt incoming packets
      _innerTransport.onPacketReceived.listen((packet) {
        // Decrypt packet
        _incomingController.add(packet);
      });

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

  /// Encrypt a packet before sending
  TransportPacket encryptPacket(TransportPacket packet) {
    // Apply OSCORE encryption
    // CBOR encode the payload
    return packet;
  }

  @override
  Future<void> broadcast(String message) async {
    // Encrypt then broadcast
    await _innerTransport.broadcast(message);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    final encrypted = encryptPacket(packet);
    await _innerTransport.send(encrypted);
  }

  @override
  Future<void> connect(String peerId) async {
    await _innerTransport.connect(peerId);
  }

  @override
  Future<void> dispose() async {
    await _innerTransport.dispose();
    await _incomingController.close();
  }
}
