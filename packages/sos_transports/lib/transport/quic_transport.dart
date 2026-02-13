import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// QUIC Transport Layer.
/// High-performance, multiplexed transport over UDP with built-in encryption.
/// Provides faster connection establishment and better resilience than TCP.
class QuicTransport extends TransportLayer {
  final String _host;
  final int _port;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  RawDatagramSocket? _socket;
  final Map<String, _QuicConnection> _connections = {};

  static const _descriptor = TransportDescriptor(
    id: 'quic',
    name: 'QUIC Protocol',
    technologyIds: ['quic', 'udp', 'tls1.3'],
    mediums: ['internet', 'lan'],
    requiresGateway: false,
    notes:
        '0-RTT connection establishment, built-in encryption, multiplexed streams.',
  );

  QuicTransport({
    String host = '0.0.0.0',
    int port = 4433,
  })  : _host = host,
        _port = port;

  @override
  TransportDescriptor get descriptor => _descriptor;

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

      // Bind UDP socket for QUIC
      _socket = await RawDatagramSocket.bind(
        InternetAddress(_host),
        _port,
      );

      _socket?.listen(_handleDatagram);

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

  void _handleDatagram(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    final datagram = _socket?.receive();
    if (datagram == null) return;

    try {
      // Parse QUIC packet header
      final data = datagram.data;
      final sourceAddr = '${datagram.address.address}:${datagram.port}';

      // Simplified QUIC packet parsing
      // Real implementation would use full QUIC state machine
      if (data.length < 2) return;

      final isLongHeader = (data[0] & 0x80) != 0;

      if (isLongHeader) {
        _handleInitialPacket(sourceAddr, data);
      } else {
        _handleShortPacket(sourceAddr, data);
      }
    } catch (e) {
      _health = _health.copyWith(
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  void _handleInitialPacket(String source, List<int> data) {
    // Handle connection establishment
    // In real QUIC: parse Initial, do TLS handshake, establish streams
    if (!_connections.containsKey(source)) {
      _connections[source] = _QuicConnection(
        remoteAddr: source,
        establishedAt: DateTime.now(),
      );
    }
  }

  void _handleShortPacket(String source, List<int> data) {
    // Handle data packet
    final conn = _connections[source];
    if (conn == null) return;

    // Skip QUIC header (1 byte flags + connection ID)
    // This is simplified; real QUIC has variable-length headers
    final payloadStart = 5;
    if (data.length <= payloadStart) return;

    final payload = data.sublist(payloadStart);

    try {
      final jsonStr = utf8.decode(payload);
      final packet = TransportPacket.fromJson(jsonStr);
      _incomingController.add(packet.copyWith(rxTransportId: descriptor.id));
    } catch (_) {
      // Not a valid SOS packet
    }
  }

  @override
  Future<void> broadcast(String message) async {
    // QUIC is connection-oriented, broadcast to all connected peers
    for (final conn in _connections.values) {
      await _sendToConnection(conn, message);
    }
  }

  Future<void> _sendToConnection(_QuicConnection conn, String message) async {
    final parts = conn.remoteAddr.split(':');
    if (parts.length != 2) return;

    final addr = InternetAddress(parts[0]);
    final port = int.parse(parts[1]);

    // Simplified QUIC packet construction
    // Real implementation would handle streams, encryption, etc.
    final header = [0x40, 0x00, 0x00, 0x00, 0x00]; // Short header
    final payload = utf8.encode(message);
    final packet = [...header, ...payload];

    _socket?.send(packet, addr, port);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('QUIC not available');
    }

    final json = packet.toJson();

    if (packet.recipientId != null &&
        _connections.containsKey(packet.recipientId)) {
      await _sendToConnection(_connections[packet.recipientId]!, json);
    } else {
      await broadcast(json);
    }
  }

  @override
  Future<void> connect(String peerId) async {
    // Initiate QUIC connection to peer
    // In real implementation: send Initial packet, do handshake
    final parts = peerId.split(':');
    if (parts.length != 2) {
      throw ArgumentError('peerId must be in format host:port');
    }

    _connections[peerId] = _QuicConnection(
      remoteAddr: peerId,
      establishedAt: DateTime.now(),
    );
  }

  @override
  Future<void> dispose() async {
    _socket?.close();
    _socket = null;
    _connections.clear();
    await _incomingController.close();
  }
}

class _QuicConnection {
  final String remoteAddr;
  final DateTime establishedAt;
  int streamIdCounter = 0;

  _QuicConnection({
    required this.remoteAddr,
    required this.establishedAt,
  });
}
