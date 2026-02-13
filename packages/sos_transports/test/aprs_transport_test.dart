import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/transport/aprs_transport.dart';

void main() {
  group('AprsTransport', () {
    test('descriptor is correct', () {
      final t = AprsTransport(callsign: 'PX2ABC');
      expect(t.descriptor.id, equals('aprs'));
      expect(t.descriptor.name,
          equals('APRS (Automatic Packet Reporting System)'));
      expect(t.descriptor.technologyIds, contains('ham_aprs'));
    });

    test('setLocalId works', () {
      final t = AprsTransport(callsign: 'PX2ABC');
      t.setLocalId('node-1');
      expect(t.localId, equals('node-1'));
    });
  });
}
