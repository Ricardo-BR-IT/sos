import 'dart:async';
import 'transport_packet.dart';

enum PeerState { discovered, authenticating, connected, failed }

class HandshakeManager {
  final String localNodeId;
  final Function(TransportPacket) sendPacket;

  // Mapa de PeerId -> Estado
  final Map<String, PeerState> _peers = {};
  final _stateController = StreamController<Map<String, PeerState>>.broadcast();

  HandshakeManager({required this.localNodeId, required this.sendPacket});

  Stream<Map<String, PeerState>> get peerStates => _stateController.stream;

  /// Inicia o handshake ao descobrir um novo peer
  void initiateHandshake(String remoteId) {
    if (_peers[remoteId] == PeerState.connected) return;

    _peers[remoteId] = PeerState.authenticating;
    _stateController.add(_peers);

    final hello = TransportPacket(
      senderId: localNodeId,
      recipientId: remoteId,
      type: SosPacketType.hello,
      payload: {'pubKey': 'TODO_GET_FROM_CRYPTO_MANAGER'},
    );

    sendPacket(hello);
  }

  /// Processa pacotes de handshake recebidos
  void handlePacket(TransportPacket packet) {
    if (packet.type == SosPacketType.hello &&
        packet.recipientId == localNodeId) {
      // Recebeu HELLO, responde com HELLO_ACK
      _peers[packet.senderId] = PeerState.connected;
      _stateController.add(_peers);

      // TODO: Validar assinatura e chave pública aqui
    } else if (packet.type == SosPacketType.helloAck &&
        packet.recipientId == localNodeId) {
      _peers[packet.senderId] = PeerState.connected;
      _stateController.add(_peers);
    }
  }
}
