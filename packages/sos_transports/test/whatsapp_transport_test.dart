import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/transport/whatsapp_transport.dart';

void main() {
  group('WhatsappTransport', () {
    test('descriptor is correct', () {
      final t = WhatsappTransport(
        apiUrl: 'https://api.example.com',
        authToken: 'token',
        fromNumber: '123',
      );
      expect(t.descriptor.id, equals('whatsapp'));
      expect(t.descriptor.technologyIds, contains('whatsapp'));
    });

    test('setLocalId works', () {
      final t = WhatsappTransport(
        apiUrl: 'https://api.example.com',
        authToken: 'token',
        fromNumber: '123',
      );
      t.setLocalId('wa-node-1');
      expect(t.localId, equals('wa-node-1'));
    });
  });
}
