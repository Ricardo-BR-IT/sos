import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Sigfox LPWAN Transport Layer.
/// Ultra-narrow-band IoT network for emergency beacons.
class SigfoxTransport extends TransportLayer {
  final String _deviceId;
  final String _pac;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'sigfox',
    name: 'Sigfox LPWAN',
    technologyIds: ['sigfox', 'unb'],
    mediums: ['radio', 'uhf'],
    requiresGateway: false,
    notes: '12 bytes up, 8 bytes down. 140 msg/day. Range 30-50km rural.',
  );

  SigfoxTransport({required String deviceId, required String pac})
      : _deviceId = deviceId,
        _pac = pac;

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
      // Configure Sigfox modem via AT commands
      await _sendAt('AT');
      await _sendAt('AT\$ID=$_deviceId');
      await _sendAt('AT\$PAC=$_pac');
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

  Future<String> _sendAt(String cmd) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'OK';
  }

  /// Send 12-byte Sigfox message (max payload)
  Future<void> sendPayload(List<int> payload) async {
    if (payload.length > 12) throw Exception('Sigfox max 12 bytes');
    final hex = payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _sendAt('AT\$SF=$hex');
  }

  /// Send SOS beacon (lat/lon/type in 12 bytes)
  Future<void> sendSosBeacon({
    required double latitude,
    required double longitude,
    int alertType = 0,
  }) async {
    // Pack lat(4) + lon(4) + type(1) + reserved(3) = 12 bytes
    final lat = (latitude * 1e6).toInt();
    final lon = (longitude * 1e6).toInt();
    final payload = [
      (lat >> 24) & 0xFF,
      (lat >> 16) & 0xFF,
      (lat >> 8) & 0xFF,
      lat & 0xFF,
      (lon >> 24) & 0xFF,
      (lon >> 16) & 0xFF,
      (lon >> 8) & 0xFF,
      lon & 0xFF,
      alertType & 0xFF,
      0,
      0,
      0,
    ];
    await sendPayload(payload);
  }

  @override
  Future<void> broadcast(String message) async {
    // Sigfox is ultra-constrained: 12 bytes max
    final bytes = message.codeUnits.take(12).toList();
    await sendPayload(bytes);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      final lat = (packet.payload['lat'] as num?)?.toDouble() ?? 0.0;
      final lon = (packet.payload['lon'] as num?)?.toDouble() ?? 0.0;
      await sendSosBeacon(latitude: lat, longitude: lon);
    } else {
      await broadcast(packet.toJson().substring(0, 12));
    }
  }

  @override
  Future<void> connect(String peerId) async {}
  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
