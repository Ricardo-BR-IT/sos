import 'dart:convert';
import 'dart:collection';

import '../sos_kernel.dart';

class SosEnvelope {
  final int version;
  final String type;
  final String sender;
  final int timestamp;
  final Map<String, dynamic> payload;
  final String signature;

  SosEnvelope({
    required this.version,
    required this.type,
    required this.sender,
    required this.timestamp,
    required this.payload,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
        'v': version,
        'type': type,
        'sender': sender,
        'timestamp': timestamp,
        'payload': payload,
        'signature': signature,
      };

  String toJsonString() => jsonEncode(toJson());

  String? get target {
    final value = payload['target'];
    return value == null ? null : value.toString();
  }

  bool get isBroadcast {
    final t = target;
    return t == null || t.isEmpty || t == '*';
  }

  static SosEnvelope fromJson(Map<String, dynamic> json) {
    return SosEnvelope(
      version: json['v'] as int? ?? 1,
      type: json['type'] as String,
      sender: json['sender'] as String,
      timestamp: json['timestamp'] as int,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      signature: json['signature'] as String,
    );
  }

  static SosEnvelope fromJsonString(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return SosEnvelope.fromJson(data);
  }

  static Future<SosEnvelope> sign({
    required SosCore core,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sender = core.publicKey;
    final body = _canonicalBody(
      version: 1,
      type: type,
      sender: sender,
      timestamp: timestamp,
      payload: payload,
    );
    final signature = await core.sign(body);
    return SosEnvelope(
      version: 1,
      type: type,
      sender: sender,
      timestamp: timestamp,
      payload: payload,
      signature: signature,
    );
  }

  Future<bool> verifyWith(SosCore core) async {
    final body = _canonicalBody(
      version: version,
      type: type,
      sender: sender,
      timestamp: timestamp,
      payload: payload,
    );
    return core.verifySignature(
      message: body,
      signatureB64: signature,
      publicKeyB64: sender,
    );
  }

  static String _canonicalBody({
    required int version,
    required String type,
    required String sender,
    required int timestamp,
    required Map<String, dynamic> payload,
  }) {
    final body = {
      'v': version,
      'type': type,
      'sender': sender,
      'timestamp': timestamp,
      'payload': payload,
    };
    return jsonEncode(_normalize(body));
  }

  String canonicalBody() => _canonicalBody(
        version: version,
        type: type,
        sender: sender,
        timestamp: timestamp,
        payload: payload,
      );

  static Object _normalize(Object value) {
    if (value is Map) {
      final sorted = SplayTreeMap<String, dynamic>();
      value.forEach((key, v) {
        sorted[key.toString()] = _normalize(v);
      });
      return sorted;
    }
    if (value is List) {
      return value.map((item) => _normalize(item)).toList();
    }
    return value;
  }
}
