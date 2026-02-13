import 'dart:async';

import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_layer.dart';
import 'transport_packet.dart';

abstract class BaseTransport extends TransportLayer {
  final StreamController<TransportPacket> _packetController =
      StreamController.broadcast();
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  @override
  Stream<TransportPacket> get onPacketReceived => _packetController.stream;

  @override
  TransportHealth get health => _health;

  bool get isEnabled => true;

  void emitPacket(TransportPacket packet) {
    _packetController.add(packet);
    _health = _health.copyWith(
      availability: TransportAvailability.available,
      lastOkAt: DateTime.now(),
      lastError: null,
    );
  }

  void reportError(Object error) {
    _health = _health.copyWith(
      availability: TransportAvailability.degraded,
      lastError: error.toString(),
      errorCount: _health.errorCount + 1,
    );
  }

  void markUnavailable(String reason) {
    _health = _health.copyWith(
      availability: TransportAvailability.unavailable,
      lastError: reason,
    );
  }

  void markAvailable() {
    _health = _health.copyWith(
      availability: TransportAvailability.available,
      lastOkAt: DateTime.now(),
      lastError: null,
    );
  }

  void reportStatus(String status) {
    // Log transport status update
    print('[${descriptor.id}] $status');
  }

  void startAdvertising({String? name, dynamic serviceUuid}) async {
    // Override in subclasses that support advertising
  }

  void stopAdvertising() async {
    // Override in subclasses that support advertising
  }

  @override
  Future<void> dispose() async {
    await _packetController.close();
  }

  @override
  TransportDescriptor get descriptor;
}
