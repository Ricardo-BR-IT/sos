import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

/// Transporte via Ethernet LAN usando UDP Broadcast para descoberta e TCP para comunicação.
class EthernetTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'ethernet',
    name: 'Ethernet LAN',
    technologyIds: ['ethernet_lan', 'lan_poe'],
    mediums: ['lan', 'wired'],
    requiresGateway: false,
  );

  final int port;
  final int discoveryPort;
  String? _localId;
  ServerSocket? _serverSocket;
  RawDatagramSocket? _udpSocket;
  bool _running = false;
  final Map<String, _EthernetPeer> _peers = {};
  Timer? _discoveryTimer;

  EthernetTransport({this.port = 4001, this.discoveryPort = 4002});

  @override
  bool get isEnabled => _running;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
  }

  @override
  Future<void> initialize() async {
    await start();
  }

  Future<void> start() async {
    if (_running) return;
    try {
      // 1. Iniciar Servidor TCP
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _serverSocket!.listen(_handleTcpConnection);

      // 2. Iniciar UDP para descoberta (Broadcast)
      _udpSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
      _udpSocket!.broadcastEnabled = true;
      _udpSocket!.listen(_handleUdpPacket);

      // 3. Loop de anúncio
      _discoveryTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _announcePresence();
      });

      _running = true;
      markAvailable();
      _announcePresence();
    } catch (e) {
      markUnavailable('Ethernet init failed: $e');
    }
  }

  void _handleTcpConnection(Socket socket) {
    socket.listen((data) {
      try {
        final packet = TransportPacket.fromJson(utf8.decode(data));
        emitPacket(packet);
      } catch (_) {}
    });
  }

  void _handleUdpPacket(event) {
    if (event == RawSocketEvent.read) {
      final dg = _udpSocket?.receive();
      if (dg == null) return;
      try {
        final data = utf8.decode(dg.data);
        if (data.startsWith('SOS_HELLO:')) {
          final parts = data.split(':');
          if (parts.length >= 3) {
            final remoteId = parts[1];
            final remotePort = int.tryParse(parts[2]) ?? port;
            if (remoteId != _localId) {
              _peers[remoteId] = _EthernetPeer(
                id: remoteId,
                ip: dg.address.address,
                port: remotePort,
                lastSeen: DateTime.now(),
              );
            }
          }
        }
      } catch (_) {}
    }
  }

  void _announcePresence() {
    if (_udpSocket == null || _localId == null) return;
    final message = utf8.encode('SOS_HELLO:$_localId:$port');
    _udpSocket!
        .send(message, InternetAddress('255.255.255.255'), discoveryPort);
  }

  @override
  Future<void> broadcast(String message) async {
    final data = utf8.encode(message);
    _peers.removeWhere((id, peer) =>
        DateTime.now().difference(peer.lastSeen) > const Duration(minutes: 2));

    for (final peer in _peers.values) {
      try {
        final socket = await Socket.connect(peer.ip, peer.port,
            timeout: const Duration(seconds: 1));
        socket.add(data);
        await socket.flush();
        await socket.close();
      } catch (_) {
        // Peer pode estar offline
      }
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {
    // Discovery handles this automatically
  }

  Future<void> stop() async {
    _discoveryTimer?.cancel();
    await _serverSocket?.close();
    _udpSocket?.close();
    _serverSocket = null;
    _udpSocket = null;
    _running = false;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await super.dispose();
  }
}

class _EthernetPeer {
  final String id;
  final String ip;
  final int port;
  final DateTime lastSeen;
  _EthernetPeer(
      {required this.id,
      required this.ip,
      required this.port,
      required this.lastSeen});
}
