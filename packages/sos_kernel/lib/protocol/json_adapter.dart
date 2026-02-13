import 'dart:convert';

import 'protocol_adapter.dart';

class JsonProtocolAdapter extends ProtocolAdapter {
  @override
  final String id;
  @override
  final String name;

  JsonProtocolAdapter({
    required this.id,
    required this.name,
  });

  @override
  bool get implemented => true;

  @override
  ProtocolMessage encode(Map<String, dynamic> payload) {
    final bytes = utf8.encode(jsonEncode(payload));
    return ProtocolMessage(
      protocolId: id,
      contentType: 'application/json',
      bytes: bytes,
    );
  }

  @override
  Map<String, dynamic> decode(ProtocolMessage message) {
    final text = utf8.decode(message.bytes);
    final data = jsonDecode(text);
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'data': data};
  }
}
