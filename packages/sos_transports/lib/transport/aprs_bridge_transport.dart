import 'dart:async';
import 'package:meta/meta.dart';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// APRS Bridge Transport - bridges APRS radio to mesh via TNC/KISS.
class AprsBridgeTransport extends TransportLayer {
  // ignore: unused_field
  final String _tncPath;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'aprs_bridge',
    name: 'APRS TNC Bridge',
    technologyIds: ['ham_aprs', 'tnc', 'kiss'],
    mediums: ['radio', 'serial'],
    requiresGateway: false,
    notes: 'APRS via hardware TNC with KISS protocol over serial port.',
  );

  AprsBridgeTransport({required String tncPath}) : _tncPath = tncPath;

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
      // Open serial connection to TNC at _tncPath
      // Send KISS mode init: 0xC0 0xFF 0xC0
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

  Stream<TransportPacket> get packetStream => onPacketReceived;
  bool get isAvailable =>
      health.availability == TransportAvailability.available;

  Map<String, dynamic> getAprsStatus() {
    return {
      'callsign': 'TEST-1', // Mock
      'useInternet': false,
      'useRadio': true,
      'stations': 0,
      'messages': 0,
      'stationsList': [],
    };
  }

  Future<void> sendPosition(double lat, double lon, {String? comment}) async {
    // Implementation stub
  }

  Future<void> sendTelemetry(List<int> values, List<String> labels) async {
    // Implementation stub
  }

  Future<void> sendEmergencyAlert(String type, String description) async {
    // Implementation stub
  }

  @visibleForTesting
  String formatLatitude(double lat) {
    // Mock implementation for test
    final absLat = lat.abs();
    final deg = absLat.floor();
    final min = (absLat - deg) * 60;
    final dir = lat >= 0 ? 'N' : 'S';
    return '${deg.toString().padLeft(2, '0')}${min.toStringAsFixed(2)}$dir';
  }

  @visibleForTesting
  String formatLongitude(double lon) {
    // Mock implementation for test
    final absLon = lon.abs();
    final deg = absLon.floor();
    final min = (absLon - deg) * 60;
    final dir = lon >= 0 ? 'E' : 'W';
    return '${deg.toString().padLeft(3, '0')}${min.toStringAsFixed(2)}$dir';
  }
}
