import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sos_transports/sos_transports.dart';
import 'package:sos_kernel/sos_kernel.dart';

// Manual mock implementation to avoid build_runner and mockito boilerplate errors
class MockSosCore extends Mock implements SosCore {
  @override
  String get publicKey => 'node_a';

  @override
  Future<void> initialize() async {}

  @override
  Future<String> sign(String data) async {
    return 'sig_$data';
  }

  @override
  bool verifySignature({
    required String message,
    required String signatureB64,
    required String publicKeyB64,
  }) {
    return signatureB64 == 'sig_$message';
  }

  @override
  void registerPlugin(SosPlugin plugin) {}

  @override
  CryptoManager get crypto => throw UnimplementedError();
}

class TestTransport extends BaseTransport {
  final List<TransportPacket> sentPackets = [];
  String? _localId;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  TransportDescriptor get descriptor => const TransportDescriptor(
        id: 'test_transport',
        name: 'Test Transport',
        technologyIds: ['test'],
        mediums: ['test'],
      );

  @override
  Future<void> initialize() async {}

  @override
  Future<void> send(TransportPacket packet) async {
    sentPackets.add(packet);
  }

  @override
  Future<void> broadcast(String message) async {}

  Future<void> toggle() async {}

  bool get enabled => true;

  @override
  Future<void> connect(String peerId) async {}
}

TransportPacket signPacket(TransportPacket packet) {
  final authPayload =
      '${packet.id}|${packet.senderId}|${packet.type.index}|${packet.timestamp.millisecondsSinceEpoch}';
  return packet.copyWith(signature: 'sig_$authPayload');
}

SosEnvelope createSignedEnvelope({
  required String sender,
  required String type,
  required Map<String, dynamic> payload,
  required int timestamp,
}) {
  final envelope = SosEnvelope(
    version: 1,
    type: type,
    sender: sender,
    timestamp: timestamp,
    payload: payload,
    signature: '',
  );
  final signature = 'sig_${envelope.canonicalBody()}';
  return SosEnvelope(
    version: envelope.version,
    type: envelope.type,
    sender: envelope.sender,
    timestamp: envelope.timestamp,
    payload: envelope.payload,
    signature: signature,
  );
}

void main() {
  group('MeshService', () {
    late MeshService meshService;
    late MockSosCore mockCore;
    late TestTransport transport;
    const localId = 'node_a';

    setUp(() {
      mockCore = MockSosCore();
      transport = TestTransport();

      meshService = MeshService(
        core: mockCore,
        transport: transport,
      );
    });

    test('should receive and deduplicate valid signed packets', () async {
      final packet = signPacket(TransportPacket(
        id: 'msg_1',
        senderId: 'node_b',
        type: SosPacketType.data,
        payload: {'msg': 'hello'},
      ));

      final future = meshService.incomingPackets.first;

      await meshService.receivePacket(packet);

      final incoming = await future;
      expect(incoming.id, equals('msg_1'));
    });

    test('should reject packets with invalid signatures', () async {
      final packet = TransportPacket(
        id: 'msg_bad',
        senderId: 'node_b',
        type: SosPacketType.sos,
        payload: {'alert': 'fake'},
        signature: 'invalid_sig',
      );

      bool received = false;
      meshService.incomingPackets.listen((_) => received = true);

      await meshService.receivePacket(packet);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(received, isFalse);
    });

    test('should forward valid broadcast signed packets with decremented TTL',
        () async {
      final now = DateTime.now();
      final packet = signPacket(TransportPacket(
        id: 'msg_2',
        senderId: 'node_b',
        recipientId: null, // Broadcast
        type: SosPacketType.data,
        payload: {'msg': 'hello'},
        timestamp: now,
        ttl: 5,
      ));

      await meshService.receivePacket(packet);

      expect(transport.sentPackets.length, equals(1));
      expect(transport.sentPackets.first.id, equals('msg_2'));
      expect(transport.sentPackets.first.ttl, equals(4));
    });

    test('should sign new outgoing packets', () async {
      await meshService.sendNewPacket(
        type: SosPacketType.sos,
        payload: {'alert': 'help'},
      );

      expect(transport.sentPackets.last.signature, isNotNull);
      expect(transport.sentPackets.last.signature!.startsWith('sig_'), isTrue);
      expect(transport.sentPackets.last.ttl, equals(10));
    });

    test('should NOT forward packets destined for local node', () async {
      final now = DateTime.now();
      final packet = signPacket(TransportPacket(
        id: 'msg_3',
        senderId: 'node_b',
        recipientId: localId,
        type: SosPacketType.data,
        payload: {'msg': 'for you'},
        timestamp: now,
        ttl: 5,
      ));

      await meshService.receivePacket(packet);

      expect(transport.sentPackets.isEmpty, isTrue);
    });

    test('should use differentiated TTLs for new packets', () async {
      await meshService.sendNewPacket(
        type: SosPacketType.sos,
        payload: {'alert': 'help'},
      );
      expect(transport.sentPackets.last.ttl, equals(10));

      await meshService.sendNewPacket(
        type: SosPacketType.ping,
        payload: {},
      );
      expect(transport.sentPackets.last.ttl, equals(4));
    });

    test('should automatically respond to diag_ping with signed diag_pong',
        () async {
      final pingAt = DateTime.now().millisecondsSinceEpoch;
      final pingEnvelope = createSignedEnvelope(
        sender: 'node_b',
        type: 'diag_ping',
        payload: {
          'diagId': 'test_diag',
          'sentAt': pingAt,
        },
        timestamp: pingAt,
      );

      final pingPacket = signPacket(TransportPacket(
        senderId: 'node_b',
        type: SosPacketType.data,
        payload: pingEnvelope.toJson(),
        rxTransportId: 'udp_1',
      ));

      await meshService.receivePacket(pingPacket);
      await Future.delayed(const Duration(milliseconds: 25));

      // Verify a pong was sent back
      final pongPacket = transport.sentPackets.firstWhere(
        (p) => p.type == SosPacketType.pong,
        orElse: () => throw Exception('Pong not sent'),
      );

      expect(pongPacket.recipientId, equals('node_b'));
      final pongEnvelope = SosEnvelope.fromJson(pongPacket.payload);
      expect(pongEnvelope.type, equals('diag_pong'));
      expect(pongEnvelope.payload['diagId'], equals('test_diag'));
      expect(pongEnvelope.payload['sentAt'], equals(pingAt));
      expect(pongEnvelope.payload['txTransportId'], equals('udp_1'));
    });

    test('should deduplicate packets using Bloom Filter and Set', () async {
      final packet = signPacket(TransportPacket(
        id: 'unique_msg_100',
        senderId: 'node_b',
        type: SosPacketType.data,
        payload: {'msg': 'bloom test'},
      ));

      int receiveCount = 0;
      meshService.incomingPackets.listen((_) => receiveCount++);

      await meshService.receivePacket(packet);
      await meshService.receivePacket(packet); // Duplicate

      expect(receiveCount, equals(1));
    });
  });
}
