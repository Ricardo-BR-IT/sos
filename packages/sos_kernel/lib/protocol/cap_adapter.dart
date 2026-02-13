import 'dart:convert';

import 'cap_alert.dart';
import 'protocol_adapter.dart';

class CapProtocolAdapter extends ProtocolAdapter {
  @override
  String get id => 'protocol_cap';

  @override
  String get name => 'CAP (Common Alerting Protocol)';

  @override
  bool get implemented => true;

  @override
  ProtocolMessage encode(Map<String, dynamic> payload) {
    final alert = CapAlert.fromMap(payload);
    final xml = alert.toXml();
    return ProtocolMessage(
      protocolId: id,
      contentType: 'application/cap+xml',
      bytes: utf8.encode(xml),
    );
  }

  @override
  Map<String, dynamic> decode(ProtocolMessage message) {
    final xml = utf8.decode(message.bytes);
    final alert = CapAlert.fromXml(xml);
    return alert.toMap();
  }
}
