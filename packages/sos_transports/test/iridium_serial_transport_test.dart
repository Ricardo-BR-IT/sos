import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/transport/iridium_serial_transport.dart';

void main() {
  group('IridiumSerialTransport', () {
    test('descriptor is correct', () {
      final t = IridiumSerialTransport(portName: 'COM1');
      expect(t.descriptor.id, equals('iridium_serial'));
      expect(t.descriptor.name, equals('Iridium SBD Serial (Modem)'));
      expect(t.descriptor.technologyIds, contains('sat_iridium_sbd_modem'));
    });

    test('setLocalId works', () {
      final t = IridiumSerialTransport(portName: 'COM1');
      t.setLocalId('node-2');
      expect(t.localId, equals('node-2'));
    });
  });
}
