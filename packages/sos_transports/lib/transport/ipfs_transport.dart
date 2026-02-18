import 'dart:async';
import 'package:http/http.dart' as http;

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// IPFS Transport Layer.
/// Decentralized content-addressed messaging via IPFS/libp2p.
class IpfsTransport extends TransportLayer {
  final String _gatewayUrl;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'ipfs',
    name: 'IPFS / libp2p',
    technologyIds: ['ipfs', 'libp2p'],
    mediums: ['internet', 'p2p'],
    requiresGateway: false,
    notes: 'IPFS content-addressed storage with libp2p pubsub for messaging.',
  );

  IpfsTransport({String gatewayUrl = 'http://127.0.0.1:5001'})
      : _gatewayUrl = gatewayUrl;

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
      // Connect to IPFS daemon at _gatewayUrl
      // Subscribe to SOS pubsub topic
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
    try {
      // Publish to IPFS pubsub topic 'sos-mesh' via API
      final response = await http.post(
        Uri.parse('$_gatewayUrl/api/v0/pubsub/pub?topic=sos-mesh&arg=$message'),
      );

      if (response.statusCode == 200) {
        _health = _health.copyWith(lastOkAt: DateTime.now());
      } else {
        throw Exception('IPFS Gateway error: ${response.statusCode}');
      }
    } catch (e) {
      _health = _health.copyWith(
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {
    // Connect to IPFS peer via multiaddr
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
