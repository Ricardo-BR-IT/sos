import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Microwave Point-to-Point Transport Layer.
/// High-capacity backhaul links for mesh gateways.
class MicrowaveTransport extends TransportLayer {
  final double _frequencyGHz;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'microwave',
    name: 'Microwave Point-to-Point',
    technologyIds: ['microwave', 'p2p', 'backhaul'],
    mediums: ['radio', 'microwave'],
    requiresGateway: false,
    notes: 'Line-of-sight backhaul. 1-100 Gbps. Range 10-80km.',
  );

  MicrowaveTransport({double frequencyGHz = 18.0})
      : _frequencyGHz = frequencyGHz;

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
      // Configure microwave radio
      // Align antenna, configure modulation
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

  /// Get link metrics
  Map<String, double> getLinkMetrics() {
    return {
      'frequency_ghz': _frequencyGHz,
      'estimated_capacity_mbps': _frequencyGHz > 30 ? 10000.0 : 1000.0,
      'rain_fade_margin_dB': 20.0,
    };
  }

  @override
  Future<void> broadcast(String message) async {}
  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {}
  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
