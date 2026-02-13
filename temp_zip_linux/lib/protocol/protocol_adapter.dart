import 'dart:convert';

class ProtocolMessage {
  final String protocolId;
  final String contentType;
  final List<int> bytes;

  const ProtocolMessage({
    required this.protocolId,
    required this.contentType,
    required this.bytes,
  });

  String asString() => utf8.decode(bytes);
}

abstract class ProtocolAdapter {
  String get id;
  String get name;
  bool get implemented;

  ProtocolMessage encode(Map<String, dynamic> payload);
  Map<String, dynamic> decode(ProtocolMessage message);
}
