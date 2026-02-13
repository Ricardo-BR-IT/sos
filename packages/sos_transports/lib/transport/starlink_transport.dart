import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Starlink Satellite Transport Layer.
/// High-speed LEO satellite internet for emergency gateway.
class StarlinkTransport extends TransportLayer {
  final String _apiEndpoint;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  StarlinkStatus? _status;

  static const kDescriptor = TransportDescriptor(
    id: 'starlink',
    name: 'Starlink LEO Satellite',
    technologyIds: ['starlink', 'leo', 'satellite'],
    mediums: ['satellite', 'ku-band'],
    requiresGateway: false,
    notes: 'High-speed (50-500 Mbps) LEO satellite. Requires Dishy terminal.',
  );

  StarlinkTransport({String apiEndpoint = 'http://192.168.100.1'})
      : _apiEndpoint = apiEndpoint;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  TransportHealth get health => _health;

  @override
  String? get localId => _localId;

  StarlinkStatus? get dishyStatus => _status;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Check Starlink Dishy status
      await _checkDishyStatus();

      if (_status?.state != 'CONNECTED') {
        throw Exception('Starlink not connected: ${_status?.state}');
      }

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startStatusPolling();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<void> _checkDishyStatus() async {
    try {
      final response = await HttpClient()
          .getUrl(Uri.parse('$_apiEndpoint/api/status'))
          .then((request) => request.close())
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        _status = StarlinkStatus.fromJson(json);
      }
    } catch (e) {
      _status = null;
    }
  }

  void _startStatusPolling() {
    Timer.periodic(const Duration(seconds: 30), (_) => _checkDishyStatus());
  }

  /// Get current satellite info
  Future<Map<String, dynamic>> getSatelliteInfo() async {
    await _checkDishyStatus();
    return {
      'state': _status?.state,
      'uptime': _status?.uptimeSeconds,
      'downlink_mbps': _status?.downlinkMbps,
      'uplink_mbps': _status?.uplinkMbps,
      'latency_ms': _status?.latencyMs,
      'obstruction_percent': _status?.obstructionPercent,
    };
  }

  /// Stow dish for emergency (e.g., hurricane)
  Future<void> stowDish() async {
    // Send stow command to Dishy
    await HttpClient()
        .postUrl(Uri.parse('$_apiEndpoint/api/stow'))
        .then((request) => request.close());
  }

  /// Unstow dish to resume operation
  Future<void> unstowDish() async {
    await HttpClient()
        .postUrl(Uri.parse('$_apiEndpoint/api/unstow'))
        .then((request) => request.close());
  }

  @override
  Future<void> broadcast(String message) async {
    // Starlink provides IP connectivity, use for relay
    if (_health.availability != TransportAvailability.available) {
      throw Exception('Starlink not connected');
    }
    // Send via SOS server over Starlink internet
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {
    // IP-based, use standard sockets
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

class StarlinkStatus {
  final String state;
  final int uptimeSeconds;
  final double downlinkMbps;
  final double uplinkMbps;
  final double latencyMs;
  final double obstructionPercent;

  StarlinkStatus({
    required this.state,
    required this.uptimeSeconds,
    required this.downlinkMbps,
    required this.uplinkMbps,
    required this.latencyMs,
    required this.obstructionPercent,
  });

  factory StarlinkStatus.fromJson(Map<String, dynamic> json) {
    final dish = json['dishGetStatus'] as Map<String, dynamic>? ?? {};
    return StarlinkStatus(
      state: dish['state'] as String? ?? 'UNKNOWN',
      uptimeSeconds: dish['deviceInfo']?['uptimeS'] as int? ?? 0,
      downlinkMbps: (dish['downlinkThroughputBps'] as num? ?? 0) / 1e6,
      uplinkMbps: (dish['uplinkThroughputBps'] as num? ?? 0) / 1e6,
      latencyMs: (dish['popPingLatencyMs'] as num?)?.toDouble() ?? 0,
      obstructionPercent:
          (dish['obstructionStats']?['fractionObstructed'] as num? ?? 0) * 100,
    );
  }
}
