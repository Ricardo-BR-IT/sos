import 'dart:async';
import 'package:sos_transports/sos_transports.dart';
import '../sos_kernel.dart';

/// Serviço central do Mesh responsável por roteamento, deduplicação e TTL.
/// Integra com SosCore para segurança e TransportLayer para comunicação.
class MeshService {
  static MeshService? _instance;
  static MeshService get instance => _instance!;

  final SosCore core;
  final TransportLayer transport;
  final MessageQueueManager _messageQueue = MessageQueueManager();

  // Cache de IDs de mensagens processadas para evitar loops (Flooding Control)
  final Set<String> _seenMessageIds = {};

  // Peermap: Rastreamento de nós vizinhos e métricas (MESH-CORE-004)
  final Map<String, MeshPeer> _peers = {};

  // Tabela de Roteamento (MESH-V5-RT)
  final RoutingTable _routingTable = RoutingTable();

  // Bloom Filter para pré-checagem rápida de duplicatas (MESH-CORE-005)
  late List<int> _bloomFilter;
  static const int _bloomSize = 1024 * 8; // 8K bits

  // Stream de pacotes que são destinados a este nó ou broadcast (Envelopes)
  final _messagesController = StreamController<SosEnvelope>.broadcast();
  Stream<SosEnvelope> get messages => _messagesController.stream;

  // Stream de atualizações de peers no mesh
  final _peerUpdatesController = StreamController<MeshPeer>.broadcast();
  Stream<MeshPeer> get peerUpdates => _peerUpdatesController.stream;

  // Compatibilidade com interface antiga (para apps que ainda usam TransportPacket diretamente)
  final _incomingPacketsController =
      StreamController<TransportPacket>.broadcast();
  Stream<TransportPacket> get incomingPackets =>
      _incomingPacketsController.stream;

  MeshService({
    required this.core,
    required this.transport,
  }) {
    _instance = this;
    _bloomFilter = List<int>.filled(_bloomSize ~/ 8, 0);
  }

  /// Inicializa o serviço mesh e atesta a identidade
  Future<void> initialize({required String displayName}) async {
    // 1. Garantir que o core está pronto
    await core.initialize();
    await _messageQueue.initialize();

    _messageQueue.onRetry.listen((TransportPacket packet) {
      transport.send(packet);
    });

    // 2. Ouvir o transporte físico
    transport.onPacketReceived.listen((packet) {
      receivePacket(packet);
    });

    TelemetryService.instance.logEvent('mesh_init', data: {
      'nodeId': core.publicKey,
      'transport': transport.descriptor.id,
    });

    // 3. Emitir "Hello" para anunciar presença (Broadcast)
    await sendNewPacket(
      type: SosPacketType.hello,
      payload: {
        'name': displayName,
        'platform': 'generic',
      },
    );
  }

  /// Processa um pacote recebido de qualquer transporte
  Future<void> receivePacket(TransportPacket packet) async {
    // 1. Bloom Filter Check (MESH-CORE-005)
    if (_checkBloomFilter(packet.id)) {
      // Se passar no bloom filter, checamos o set real (evitar falso positivo)
      if (_seenMessageIds.contains(packet.id)) {
        return;
      }
    }

    _addToSeenCache(packet.id);

    // 2. Verificação de Assinatura
    if (!_verifyPacketAuth(packet)) {
      TelemetryService.instance
          .logEvent('packet_auth_fail', level: 'warning', data: {
        'id': packet.id,
        'sender': packet.senderId,
      });
      return;
    }

    // 3. Encaminhar para o stream interno se for para nós
    final isForMe = packet.recipientId == core.publicKey;
    final isBroadcast = packet.recipientId == null;

    if (isForMe || isBroadcast) {
      _incomingPacketsController.add(packet);

      // Tentar converter para SosEnvelope se possível
      try {
        if (packet.type == SosPacketType.data ||
            packet.type == SosPacketType.sos ||
            packet.type == SosPacketType.pong) {
          final envelope =
              SosEnvelope.fromJson(Map<String, dynamic>.from(packet.payload));
          if (await envelope.verifyWith(core)) {
            _messagesController.add(envelope);
            _handleEnvelope(envelope, rxTransportId: packet.rxTransportId);
          }
        } else if (packet.type == SosPacketType.hello) {
          final peer = MeshPeer(
            id: packet.senderId,
            name: packet.payload['name'] ?? 'Unknown',
            platform: packet.payload['platform'] ?? 'generic',
            appVersion: packet.payload['version'] ?? 'unk',
            lastTransportId: packet.rxTransportId,
            lastSeen: DateTime.now(),
            hopCount: packet.ttl, // Distância em hops
          );
          _peers[peer.id] = peer;
          _peerUpdatesController.add(peer);
        } else if (packet.type == SosPacketType.routeRequest) {
          _handleRouteRequest(packet);
        } else if (packet.type == SosPacketType.routeReply) {
          _handleRouteReply(packet);
        }
      } catch (_) {
        // Ignorar erros de formato de payload
      }
    }

    // 4. Roteamento (Forwarding): Se não for apenas para nós, tentamos repassar
    if (!isForMe || isBroadcast) {
      unawaited(_forwardPacket(packet));
    }
  }

  bool _verifyPacketAuth(TransportPacket packet) {
    final needsAuth =
        packet.type == SosPacketType.sos || packet.type == SosPacketType.data;

    if (packet.signature == null) {
      return !needsAuth;
    }

    final payload = _getPacketAuthPayload(packet);
    return core.verifySignature(
      message: payload,
      signatureB64: packet.signature!,
      publicKeyB64: packet.senderId,
    );
  }

  String _getPacketAuthPayload(TransportPacket packet) {
    return '${packet.id}|${packet.senderId}|${packet.type.index}|${packet.timestamp.millisecondsSinceEpoch}';
  }

  void _addToSeenCache(String id) {
    if (_seenMessageIds.contains(id)) {
      _seenMessageIds.remove(id); // Move to the end (LRU)
    }
    _seenMessageIds.add(id);
    _updateBloomFilter(id);

    if (_seenMessageIds.length > 2000) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
  }

  // MESH-CORE-005: Bloom Filter Helpers (Multiple Hash Functions)
  void _updateBloomFilter(String id) {
    for (final h in _getHashes(id)) {
      final idx = h % _bloomSize;
      _bloomFilter[idx ~/ 8] |= (1 << (idx % 8));
    }
  }

  bool _checkBloomFilter(String id) {
    for (final h in _getHashes(id)) {
      final idx = h % _bloomSize;
      if ((_bloomFilter[idx ~/ 8] & (1 << (idx % 8))) == 0) {
        return false;
      }
    }
    return true;
  }

  List<int> _getHashes(String id) {
    final h1 = id.hashCode.abs();
    // Custom mixing for h2 and h3
    int h2 = 0;
    int h3 = 0;
    for (int i = 0; i < id.length; i++) {
      h2 = (h2 << 5) - h2 + id.codeUnitAt(i);
      h3 = (h3 << 7) ^ h3 ^ id.codeUnitAt(i);
    }
    return [h1, h2.abs(), h3.abs()];
  }

  /// Encaminha o pacote para outros peers se o TTL permitir
  Future<void> _forwardPacket(TransportPacket packet) async {
    if (packet.isExpired) return;

    // Se for um pacote direcionado e tivermos rota, enviamos apenas para o próximo hop
    if (packet.recipientId != null) {
      final nextHop = _routingTable.getNextHop(packet.recipientId!);
      if (nextHop != null) {
        // Se o transporte for capaz de envio direcionado, implementamos aqui.
        // Por enquanto, ainda usamos o transporte base para simplificar,
        // mas a lógica de routing está pronta para otimizações de flooding seletivo.
      }
    }

    // MESH-CORE-002: Max Hops Check
    const int maxHops = 15;
    if (packet.ttl < (8 - maxHops)) {
      TelemetryService.instance.logEvent('packet_max_hops_reached', data: {
        'id': packet.id,
        'hops': 8 - packet.ttl,
      });
      return;
    }

    final forwardedPacket = packet.decrementTtl();

    TelemetryService.instance.logEvent('packet_forward', data: {
      'id': packet.id,
      'type': packet.type.name,
      'ttl': forwardedPacket.ttl,
    });

    await transport.send(forwardedPacket);
  }

  /// Envia uma nova mensagem originada neste nó
  Future<void> sendNewPacket({
    required SosPacketType type,
    required Map<String, dynamic> payload,
    String? recipientId,
  }) async {
    final packet = TransportPacket(
      senderId: core.publicKey,
      recipientId: recipientId,
      type: type,
      payload: payload,
      ttl: _getInitialTtl(type),
    );

    // Sign the packet
    final authPayload = _getPacketAuthPayload(packet);
    final signature = await core.sign(authPayload);
    final signedPacket = packet.copyWith(signature: signature);

    _addToSeenCache(signedPacket.id);

    TelemetryService.instance.logEvent('packet_sent', data: {
      'id': signedPacket.id,
      'type': signedPacket.type.name,
      'recipient': signedPacket.recipientId,
    });

    try {
      await transport.send(signedPacket);
      // Opcional: Se for uma mensagem crítica que falhou, podemos enfileirar aqui também
      // se o transporte retornar erro ou se soubermos que falhou.
    } catch (e) {
      if (signedPacket.type == SosPacketType.data ||
          signedPacket.type == SosPacketType.sos) {
        await _messageQueue.enqueue(signedPacket);
      }
    }
  }

  /// Atalho para enviar Alerta SOS (Broadcast)
  Future<void> broadcastSos({required String message}) async {
    final envelope = await SosEnvelope.sign(
      core: core,
      type: 'sos_alert',
      payload: {'txt': message},
    );

    await sendNewPacket(
      type: SosPacketType.sos,
      payload: envelope.toJson(),
    );
  }

  /// Send direct message to specific peer
  Future<void> sendDirect({
    required String targetId,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final envelope = await SosEnvelope.sign(
      core: core,
      type: type,
      payload: payload,
    );

    await sendNewPacket(
      type: SosPacketType.data,
      payload: envelope.toJson(),
      recipientId: targetId,
    );
  }

  /// Processa envelopes de nível de aplicação (Sistema)
  void _handleEnvelope(SosEnvelope envelope, {String? rxTransportId}) async {
    // Diagnósticos (MESH-CORE-004)
    if (envelope.type == 'diag_ping') {
      final diagId = envelope.payload['diagId'];
      final sentAt = envelope.payload['sentAt'];

      if (diagId != null && sentAt != null) {
        final pongEnvelope = await SosEnvelope.sign(
          core: core,
          type: 'diag_pong',
          payload: {
            'diagId': diagId,
            'sentAt': sentAt,
            'txTransportId': rxTransportId,
          },
        );

        await sendNewPacket(
          type: SosPacketType.pong,
          payload: pongEnvelope.toJson(),
          recipientId: envelope.sender,
        );
      }
    } else if (envelope.type == 'diag_pong') {
      final diagId = envelope.payload['diagId'];
      final sentAtRaw = envelope.payload['sentAt'];

      if (diagId != null && sentAtRaw != null) {
        final sentAt = DateTime.fromMillisecondsSinceEpoch(sentAtRaw as int);
        final rtt = DateTime.now().difference(sentAt);

        final peer = _peers[envelope.sender];
        if (peer != null) {
          final updatedPeer = peer.copyWith(
            rtt: rtt,
            lastSeen: DateTime.now(),
          );
          _peers[peer.id] = updatedPeer;
          _peerUpdatesController.add(updatedPeer);

          TelemetryService.instance.logEvent('mesh_rtt_update', data: {
            'peerId': peer.id,
            'rtt_ms': rtt.inMilliseconds,
          });
        }
      }
    }
  }

  /// Handles AODV Route Request (RREQ)
  void _handleRouteRequest(TransportPacket packet) async {
    final payload = packet.payload;
    final destinationId = payload['dst'];
    final senderId = packet.senderId;
    final seqNum = payload['seq'] as int;
    final hopCount = 8 - packet.ttl;

    // 1. Update reverse route (path back to sender)
    _routingTable.updateRoute(
      destinationId: senderId,
      nextHopId: packet.senderId, // Immediate neighbor who forwarded this RREQ
      hopCount: hopCount,
      rtt: const Duration(milliseconds: 100), // Estimation until measured
      sequenceNumber: seqNum,
    );

    // 2. Are we the destination or do we have a route?
    if (destinationId == core.publicKey) {
      // Send RREP back
      await sendNewPacket(
        type: SosPacketType.routeReply,
        payload: {
          'dst': senderId, // This RREP goes back to the RREQ sender
          'target': core.publicKey, // We are the target
          'seq': seqNum,
          'hops': 0,
        },
        recipientId: senderId,
      );
    }
  }

  /// Handles AODV Route Reply (RREP)
  void _handleRouteReply(TransportPacket packet) async {
    final payload = packet.payload;
    final targetId = payload['target'];
    final hopCount = (payload['hops'] as int) + 1;
    final seqNum = payload['seq'] as int;

    // Update forward route to the target
    _routingTable.updateRoute(
      destinationId: targetId,
      nextHopId: packet.senderId,
      hopCount: hopCount,
      rtt: const Duration(milliseconds: 100),
      sequenceNumber: seqNum,
    );
  }

  int _getInitialTtl(SosPacketType type) {
    switch (type) {
      case SosPacketType.sos:
        return 10;
      case SosPacketType.ping:
      case SosPacketType.pong:
        return 4;
      case SosPacketType.hello:
      case SosPacketType.helloAck:
        return 5;
      case SosPacketType.data:
      default:
        return 8;
    }
  }

  /// Envia um pacote através de um transporte específico (útil para diagnósticos)
  Future<void> broadcastVia({
    required String transportId,
    required String type,
    required Map<String, dynamic> payload,
    int ttl = 1,
  }) async {
    final packet = TransportPacket(
      senderId: core.publicKey,
      type: SosPacketType.data,
      payload: payload,
      ttl: ttl,
    );

    // Sign the packet
    final authPayload = _getPacketAuthPayload(packet);
    final signature = await core.sign(authPayload);
    final signedPacket = packet.copyWith(signature: signature);

    _addToSeenCache(signedPacket.id);

    final t = transport;
    if (t is TransportBroadcaster) {
      await (t as TransportBroadcaster)
          .sendToTransport(transportId, signedPacket);
    } else if (t.descriptor.id == transportId) {
      await t.send(signedPacket);
    }
  }

  void dispose() {
    _messagesController.close();
    _peerUpdatesController.close();
    _incomingPacketsController.close();
  }
}
