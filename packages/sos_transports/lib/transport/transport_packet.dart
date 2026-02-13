import 'dart:convert';

enum SosPacketType {
  hello, // Início do handshake
  helloAck, // Resposta do handshake
  data, // Mensagem de aplicação (chat, incidentes)
  sos, // Alerta crítico (broadcast prioritário)
  ping, // Diagnóstico de latência
  pong, // Resposta de diagnóstico
  discovery, // Descoberta de nós e serviços
  media, // Media storage (photos/videos)
  routeRequest, // AODV RREQ
  routeReply, // AODV RREP
  routeError // AODV RERR
}

class TransportPacket {
  final String id;
  final String senderId; // Hash da chave pública do remetente
  final String? recipientId; // Nulo para broadcast
  final SosPacketType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int ttl; // Time To Live (Hops)
  final String? signature; // Assinatura Ed25519 do payload
  final String?
      rxTransportId; // ID do transporte que recebeu este pacote (runtime only)
  final Map<String, dynamic>
      metadata; // Metadados de transporte (RSSI, SNR, etc)

  TransportPacket({
    String? id,
    required this.senderId,
    this.recipientId,
    required this.type,
    required this.payload,
    DateTime? timestamp,
    this.ttl = 3,
    this.signature,
    this.rxTransportId,
    Map<String, dynamic>? metadata,
  })  : id = id ??
            '${senderId}_${timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now(),
        metadata = metadata ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      's': senderId,
      'r': recipientId,
      't': type.index,
      'p': payload,
      'ts': timestamp.millisecondsSinceEpoch,
      'ttl': ttl,
      'sig': signature,
      'm': metadata,
    };
  }

  factory TransportPacket.fromMap(Map<String, dynamic> map) {
    return TransportPacket(
      id: map['id'] as String?,
      senderId: map['s'] as String,
      recipientId: map['r'] as String?,
      type: SosPacketType.values[map['t'] as int],
      payload: Map<String, dynamic>.from(map['p'] as Map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['ts'] as int),
      ttl: map['ttl'] as int? ?? 3,
      signature: map['sig'] as String?,
      metadata:
          map['m'] != null ? Map<String, dynamic>.from(map['m'] as Map) : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TransportPacket.fromJson(String source) =>
      TransportPacket.fromMap(jsonDecode(source) as Map<String, dynamic>);

  bool get isExpired => ttl <= 0;

  TransportPacket decrementTtl() => copyWith(ttl: ttl - 1);

  TransportPacket copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    SosPacketType? type,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? ttl,
    String? signature,
    String? rxTransportId,
    Map<String, dynamic>? metadata,
  }) {
    return TransportPacket(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      ttl: ttl ?? this.ttl,
      signature: signature ?? this.signature,
      rxTransportId: rxTransportId ?? this.rxTransportId,
      metadata: metadata ?? this.metadata,
    );
  }
}
