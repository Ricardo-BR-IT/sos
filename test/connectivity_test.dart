import 'package:flutter_test/flutter_test.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_transports/sos_transports_io.dart';

void main() {
  group('Connectivity Tests', () {
    test('All transports can be instantiated', () {
      final transports = [
        BleTransport(),
        BluetoothClassicTransport(),
        BluetoothMeshTransport(),
        LoRaWanTransport(),
        DtnTransport(),
        SecureTransport(innerTransport: BleTransport()),
        WebRtcTransport(),
      ];

      for (final transport in transports) {
        expect(transport.descriptor.id, isNotEmpty);
        expect(transport.descriptor.name, isNotEmpty);
      }
    });

    test('Supported transports list is correct', () {
      final descriptors = TransportRegistry.knownDescriptors();

      expect(descriptors.length, greaterThan(10));

      final transportIds = descriptors.map((d) => d.id).toList();
      expect(transportIds, contains('ble'));
      expect(transportIds, contains('bluetooth_classic'));
      expect(transportIds, contains('bluetooth_mesh'));
      expect(transportIds, contains('lorawan'));
      expect(transportIds, contains('aprs'));
      expect(transportIds, contains('iridium_sbd'));
    });

    test('Technology registry is consistent', () {
      final allTechs = TechRegistry.all;

      expect(allTechs.length, greaterThan(100));

      final supportedCount =
          allTechs.where((t) => t.status == TechnologyStatus.supported).length;
      expect(supportedCount, greaterThan(0));
    });
  });
}
