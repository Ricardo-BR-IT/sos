import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/transport/ipfs_transport.dart';

void main() {
  group('IpfsTransport', () {
    test('descriptor is correct', () {
      final t = IpfsTransport();
      expect(t.descriptor.id, equals('ipfs'));
      expect(t.descriptor.technologyIds, contains('ipfs'));
    });

    test('setLocalId works', () {
      final t = IpfsTransport();
      t.setLocalId('ipfs-node-1');
      expect(t.localId, equals('ipfs-node-1'));
    });
  });
}
