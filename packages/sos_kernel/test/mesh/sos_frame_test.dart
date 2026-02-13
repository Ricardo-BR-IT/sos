import 'package:flutter_test/flutter_test.dart';
import 'package:sos_kernel/sos_kernel.dart';

void main() {
  group('SosFrame', () {
    late SosEnvelope testEnvelope;

    setUp(() {
      // Create a test envelope
      testEnvelope = SosEnvelope(
        version: 1,
        sender: 'test_sender_key',
        type: 'test',
        payload: {'message': 'Hello World'},
        timestamp: DateTime.now().millisecondsSinceEpoch,
        signature: 'envelope_signature_mock',
      );
    });

    group('Frame Creation', () {
      test('should create frame with correct initial values', () {
        final frame = SosFrame.wrap(envelope: testEnvelope, ttl: 10);

        expect(frame.ttl, equals(10));
        expect(frame.hops, equals(0));
        expect(frame.signature, isNull);
        expect(frame.parentFrameId, isNull);
        expect(frame.envelope, equals(testEnvelope));
      });

      test('should compute unique ID based on envelope and timestamp', () {
        final frame1 = SosFrame.wrap(envelope: testEnvelope, ttl: 8);

        // Wait a tiny bit to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 10));
        final frame2 = SosFrame.wrap(envelope: testEnvelope, ttl: 8);

        expect(frame1.id, isNot(equals(frame2.id)));
      });

      test('should default TTL to 8 when not specified', () {
        final frame = SosFrame.wrap(envelope: testEnvelope);
        expect(frame.ttl, equals(8));
      });
    });

    group('Frame Forwarding', () {
      test('should create forward with decremented TTL', () {
        final frame = SosFrame.wrap(envelope: testEnvelope, ttl: 5);
        final forwarded = frame.createForward();

        expect(forwarded.ttl, equals(4));
        expect(forwarded.hops, equals(1));
        expect(forwarded.parentFrameId, equals(frame.id));
        expect(forwarded.signature, equals(frame.signature));
      });

      test('should throw when forwarding expired frame', () {
        final frame = SosFrame.wrap(envelope: testEnvelope, ttl: 0);

        expect(
          () => frame.createForward(),
          throwsA(isA<StateError>()),
        );
      });

      test('should track hop count through multiple forwards', () {
        var frame = SosFrame.wrap(envelope: testEnvelope, ttl: 3);

        for (var i = 0; i < 3; i++) {
          frame = frame.createForward();
        }

        expect(frame.ttl, equals(0));
        expect(frame.hops, equals(3));
      });
    });

    group('Serialization', () {
      test('should serialize and deserialize correctly', () {
        final frame = SosFrame.wrap(envelope: testEnvelope, ttl: 8);

        final json = frame.toJson();
        final restored = SosFrame.fromJson(json);

        expect(restored.id, equals(frame.id));
        expect(restored.ttl, equals(frame.ttl));
        expect(restored.hops, equals(frame.hops));
        expect(restored.signature, equals(frame.signature));
        expect(restored.parentFrameId, equals(frame.parentFrameId));
        expect(restored.envelope.sender, equals(frame.envelope.sender));
      });

      test('should handle JSON string serialization', () {
        final frame = SosFrame.wrap(envelope: testEnvelope, ttl: 8);

        final jsonString = frame.toJsonString();
        final restored = SosFrame.fromJsonString(jsonString);

        expect(restored.id, equals(frame.id));
        expect(restored.ttl, equals(frame.ttl));
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 'test_id_123',
          'ttl': 8,
          'hops': 0,
          'envelope': {
            'v': 1,
            'sender': 'sender_key',
            'type': 'test',
            'payload': {},
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'signature': 'env_sig',
          },
          'timestamp': DateTime.now().toIso8601String(),
        };

        final frame = SosFrame.fromJson(json);

        expect(frame.signature, isNull);
        expect(frame.parentFrameId, isNull);
        expect(frame.ttl, equals(8));
        expect(frame.hops, equals(0));
      });
    });

    group('FrameVerificationResult', () {
      test('should create valid result', () {
        final result = FrameVerificationResult.valid();
        expect(result.isValid, isTrue);
        expect(result.isReplay, isFalse);
        expect(result.error, isNull);
      });

      test('should create invalid result with error', () {
        final result = FrameVerificationResult.invalid('Test error');
        expect(result.isValid, isFalse);
        expect(result.isReplay, isFalse);
        expect(result.error, equals('Test error'));
      });

      test('should create replay result', () {
        final result = FrameVerificationResult.replay();
        expect(result.isValid, isFalse);
        expect(result.isReplay, isTrue);
        expect(result.error, isNull);
      });
    });
  });
}
