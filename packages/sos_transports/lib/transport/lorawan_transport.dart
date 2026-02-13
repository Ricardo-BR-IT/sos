import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// LoRaWAN Transport Layer.
/// Long range, low power mesh via LoRa/LoRaWAN protocol.
class LoRaWanTransport extends TransportLayer {
  final int _frequency;
  final int _spreadingFactor;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'lorawan',
    name: 'LoRa / LoRaWAN',
    technologyIds: ['lpwan_lora', 'lora'],
    mediums: ['radio'],
    requiresGateway: false,
    notes: 'LoRa chirp spread spectrum. SF7-12. 15+ km range, ~11 kbps max.',
  );

  LoRaWanTransport({int frequency = 915000000, int spreadingFactor = 7})
      : _frequency = frequency,
        _spreadingFactor = spreadingFactor;

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
      // Open serial to LoRa module
      // Configure: AT+FREQ=$_frequency, AT+SF=$_spreadingFactor
      // Start RX mode
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

  @override
  Future<void> broadcast(String message) async {
    // Send LoRa radio frame
  }

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
