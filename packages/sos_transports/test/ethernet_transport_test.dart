import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/transport/ethernet_transport.dart';

void main() {
  group('EthernetTransport', () {
    test('descriptor is correct', () {
      final t = EthernetTransport();
      expect(t.descriptor.id, equals('ethernet'));
      expect(t.descriptor.technologyIds, contains('ethernet_lan'));
    });

    test('setLocalId works', () {
      final t = EthernetTransport();
      t.setLocalId('eth-node-1');
      expect(t.localId, equals('eth-node-1'));
    });
  });
}
