import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class UdpBroadcastTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'udp_broadcast',
    name: 'UDP Broadcast',
    technologyIds: [
      'protocol_udp',
    ],
    mediums: ['lan'],
  );

  final int port;
  RawDatagramSocket? _socket;
  String? _localId;

  UdpBroadcastTransport({this.port = 4001});

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
  }

  @override
  Future<void> initialize() async {
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        port,
        reuseAddress: true,
        reusePort: true,
      );
      _socket!.broadcastEnabled = true;
      _socket!.listen((event) {
        if (event != RawSocketEvent.read) return;
        final datagram = _socket!.receive();
        if (datagram == null) return;
        if (datagram.data.isEmpty) return;
        final payload = utf8.decode(datagram.data);
        try {
          final packet = TransportPacket.fromJson(payload);
          emitPacket(packet);
        } catch (_) {
          // Fallback for legacy raw messages
          emitPacket(TransportPacket(
            senderId: 'legacy_udp', // TODO: improve
            type: SosPacketType.data,
            payload: {'raw': payload},
          ));
        }
      });
      markAvailable();
    } catch (e) {
      markUnavailable('UDP broadcast indisponivel: $e');
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> broadcast(String message) async {
    if (_socket == null) return;
    try {
      final bytes = utf8.encode(message);
      _socket!.send(bytes, InternetAddress('255.255.255.255'), port);
    } catch (e) {
      reportError(e);
    }
  }

  @override
  Future<void> connect(String peerId) async {
    // UDP broadcast does not require direct connections.
  }

  @override
  Future<void> dispose() async {
    _socket?.close();
    _socket = null;
    await super.dispose();
  }

  @override
  TransportDescriptor get descriptor => kDescriptor;
}
