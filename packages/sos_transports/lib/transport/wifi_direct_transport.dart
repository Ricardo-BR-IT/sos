import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'transport_packet.dart';
import 'transport_descriptor.dart';
import 'base_transport.dart';

/// Transporte via Wi-Fi LAN usando mDNS para descoberta e TCP para comunicação.
class WiFiDirectTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'wifi_direct',
    name: 'Wi-Fi Direct / LAN',
    technologyIds: ['wifi', 'lan'],
    mediums: ['ip'],
  );

  final String _nodeId;
  final int port;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  ServerSocket? _serverSocket;
  final Map<String, _WiFiPeer> _peers = {};
  bool _running = false;

  WiFiDirectTransport({String localNodeId = 'unknown', this.port = 4000})
      : _nodeId = localNodeId;

  @override
  String? get localId => _nodeId;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  Future<void> initialize() async {
    await start();
  }

  Future<void> start() async {
    if (_running) return;
    try {
      // 1. Iniciar Servidor TCP para receber mensagens
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _serverSocket!.listen((socket) {
        socket.listen((data) {
          try {
            final packet = TransportPacket.fromJson(utf8.decode(data));
            emitPacket(packet);
          } catch (_) {}
        });
      });

      // 2. Anunciar presença na rede (mDNS)
      final service = BonsoirService(
        name: 'SOS-$_nodeId',
        type: '_sos-mesh._tcp',
        port: port,
        attributes: {'id': _nodeId},
      );
      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.initialize();
      await _broadcast!.start();

      // 3. Descobrir outros nós
      _discovery = BonsoirDiscovery(type: '_sos-mesh._tcp');
      await _discovery!.initialize();
      _discovery!.eventStream!.listen((event) {
        if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final service = event.service;
          // In Bonsoir 6.x, service is already the resolved one in this event
          final remoteId = service.attributes['id'];
          if (remoteId != null && remoteId != _nodeId) {
            // Try to get IP from service (dynamic check for ipAddresses)
            final dynamic dService = service;
            String discoveredIp = '';
            try {
              if (dService.ipAddresses != null) {
                discoveredIp = (dService.ipAddresses as List)
                    .firstWhere(
                      (element) => !element.toString().contains(':'),
                      orElse: () => '',
                    )
                    .toString();
              }
            } catch (_) {}

            if (discoveredIp.isNotEmpty) {
              _peers[remoteId] = _WiFiPeer(
                id: remoteId,
                ip: discoveredIp,
                port: service.port,
              );
            }
          }
        } else if (event is BonsoirDiscoveryServiceFoundEvent) {
          event.service.resolve(_discovery!.serviceResolver);
        } else if (event is BonsoirDiscoveryServiceLostEvent) {
          final remoteId = event.service.attributes['id'];
          if (remoteId != null) {
            _peers.remove(remoteId);
          }
        }
      });
      await _discovery!.start();
      _running = true;
      markAvailable();
    } catch (e) {
      markUnavailable('Wifi Direct indisponivel: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _broadcast?.stop();
    } catch (_) {}
    try {
      await _discovery?.stop();
    } catch (_) {}
    try {
      await _serverSocket?.close();
    } catch (_) {}

    _broadcast = null;
    _discovery = null;
    _serverSocket = null;
    _peers.clear();
    _running = false;
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> broadcast(String message) async {
    final data = utf8.encode(message);
    for (final peer in _peers.values) {
      try {
        final socket = await Socket.connect(peer.ip, peer.port,
            timeout: const Duration(seconds: 2));
        socket.add(data);
        await socket.flush();
        await socket.close();
      } catch (e) {
        // Peer pode ter saído ou IP mudou
      }
    }
  }

  Future<void> toggle() async {
    if (_running) {
      await stop();
    } else {
      await start();
    }
  }

  @override
  bool get isEnabled => _running;

  @override
  void setLocalId(String id) {
    //
  }

  @override
  Future<void> connect(String peerId) async {
    //
  }

  @override
  Future<void> dispose() async {
    await stop();
    await super.dispose();
  }
}

class _WiFiPeer {
  final String id;
  final String ip;
  final int port;
  _WiFiPeer({required this.id, required this.ip, required this.port});
}
