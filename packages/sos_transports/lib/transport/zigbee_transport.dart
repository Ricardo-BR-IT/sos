import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Zigbee/802.15.4 Transport Layer.
class ZigbeeTransport extends TransportLayer {
  final String _serialPort;
  final int _panId;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'zigbee',
    name: 'Zigbee / 802.15.4',
    technologyIds: ['zigbee', '802_15_4'],
    mediums: ['radio'],
    requiresGateway: false,
    notes:
        'Zigbee mesh via XBee modules. 250 kbps, 2.4 GHz. PAN-based routing.',
  );

  ZigbeeTransport({String serialPort = '/dev/ttyUSB0', int panId = 0x1234})
      : _serialPort = serialPort,
        _panId = panId;

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
      // Open serial to XBee on _serialPort
      // Send AT commands: ATID=$_panId, ATAP=2 (API mode)
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
    // Send XBee API frame with broadcast address 0xFFFF
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
