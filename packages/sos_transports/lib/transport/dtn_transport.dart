import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// DTN (Delay-Tolerant Networking) Transport Layer.
/// Bundle Protocol for store-and-forward in disrupted networks.
class DtnTransport extends TransportLayer {
  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  final List<TransportPacket> _bundleStore = [];

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'dtn',
    name: 'DTN (Delay-Tolerant Networking)',
    technologyIds: ['dtn', 'bundle_protocol'],
    mediums: ['any'],
    requiresGateway: false,
    notes:
        'RFC 5050 Bundle Protocol. Store-carry-forward for disconnected mesh.',
  );

  @override
  TransportDescriptor get descriptor => kDescriptor;
  @override
  TransportHealth get health => _health;
  @override
  String? get localId => _localId;
  @override
  void setLocalId(String id) => _localId = id;
  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);
      // Initialize bundle store
      // Start custody transfer timer
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

  /// Store a bundle for later delivery
  void storeBundle(TransportPacket packet) {
    _bundleStore.add(packet);
  }

  /// Attempt to deliver all stored bundles
  Future<void> flushBundles() async {
    final toSend = List<TransportPacket>.from(_bundleStore);
    _bundleStore.clear();
    for (final bundle in toSend) {
      await send(bundle);
    }
  }

  @override
  Future<void> broadcast(String message) async {
    // Store-and-forward broadcast
  }

  @override
  Future<void> send(TransportPacket packet) async {
    storeBundle(packet);
  }

  @override
  Future<void> connect(String peerId) async {}

  @override
  Future<void> dispose() async {
    _bundleStore.clear();
    await _incomingController.close();
  }
}
