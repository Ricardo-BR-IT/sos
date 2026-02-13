import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// APRS (Automatic Packet Reporting System) Transport.
/// Connects to APRS-IS servers for amateur radio mesh.
class AprsTransport extends TransportLayer {
  final String _host;
  final int _port;
  final String _callsign;
  final String _passcode;

  Socket? _socket;
  StreamSubscription? _socketSubscription;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'aprs',
    name: 'APRS (Automatic Packet Reporting System)',
    technologyIds: ['ham_aprs', 'aprs-is'],
    mediums: ['radio', 'internet'],
    requiresGateway: false,
    notes:
        'Amateur radio APRS via APRS-IS TCP. 144.39 MHz (NA) / 144.80 MHz (EU).',
  );

  AprsTransport({
    String host = 'rotate.aprs2.net',
    int port = 14580,
    required String callsign,
    String passcode = '-1',
  })  : _host = host,
        _port = port,
        _callsign = callsign,
        _passcode = passcode;

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

      _socket = await Socket.connect(_host, _port,
          timeout: const Duration(seconds: 10));

      // Login to APRS-IS
      _socket!.write('user $_callsign pass $_passcode vers SOS-Mesh 1.0\r\n');

      _socketSubscription = utf8.decoder.bind(_socket!).listen(
        (data) {
          for (final line in data.split('\n')) {
            if (line.startsWith('#')) continue; // Server comment
            if (line.trim().isEmpty) continue;
            _parseAprsPacket(line.trim());
          }
        },
        onError: (e) {
          _health = _health.copyWith(
            availability: TransportAvailability.unavailable,
            lastError: e.toString(),
            errorCount: _health.errorCount + 1,
          );
        },
      );

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

  void _parseAprsPacket(String raw) {
    // Parse APRS packet: CALLSIGN>DEST,PATH:DATA
    final headerData = raw.split(':');
    if (headerData.length < 2) return;

    final header = headerData[0];
    final payload = headerData.sublist(1).join(':');
    final parts = header.split('>');
    if (parts.length < 2) return;

    final source = parts[0];

    final packet = TransportPacket(
      type: SosPacketType.data,
      senderId: _localId ?? _callsign,
      recipientId: null,
      payload: {
        'raw': raw,
        'source_callsign': source,
        'data': payload,
      },
    );
    _incomingController.add(packet);
  }

  @override
  Future<void> broadcast(String message) async {
    if (_socket == null) return;
    // Send APRS message
    _socket!.write('$_callsign>APSOS,TCPIP*:>$message\r\n');
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {}

  @override
  Future<void> dispose() async {
    await _socketSubscription?.cancel();
    _socket?.destroy();
    await _incomingController.close();
  }
}
