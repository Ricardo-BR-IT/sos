import 'protocol_adapter.dart';

class StubProtocolAdapter extends ProtocolAdapter {
  @override
  final String id;
  @override
  final String name;
  final String reason;

  StubProtocolAdapter({
    required this.id,
    required this.name,
    required this.reason,
  });

  @override
  bool get implemented => false;

  @override
  ProtocolMessage encode(Map<String, dynamic> payload) {
    throw UnimplementedError(reason);
  }

  @override
  Map<String, dynamic> decode(ProtocolMessage message) {
    throw UnimplementedError(reason);
  }
}
