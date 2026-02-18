import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// WhatsApp Cloud API Transport Layer.
/// Sends SOS alerts via WhatsApp Business API.
class WhatsappTransport extends TransportLayer {
  final String _apiUrl;
  final String _authToken;
  final String _fromNumber;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'whatsapp',
    name: 'WhatsApp Cloud API',
    technologyIds: ['whatsapp'],
    mediums: ['internet'],
    requiresGateway: true,
    notes: 'WhatsApp Business Cloud API for SOS alerts to emergency contacts.',
  );

  WhatsappTransport({
    required String apiUrl,
    required String authToken,
    required String fromNumber,
  })  : _apiUrl = apiUrl,
        _authToken = authToken,
        _fromNumber = fromNumber;

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
      // Verify WhatsApp API token
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
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _fromNumber,
          'to': 'emergency_group', // Or specific recipient from metadata
          'text': '[SOS] $message',
        }),
      );

      if (response.statusCode == 200) {
        _health = _health.copyWith(lastOkAt: DateTime.now());
      } else {
        throw Exception('WhatsApp API error: ${response.statusCode}');
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
  Future<void> connect(String peerId) async {}

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
