import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/sos_transports.dart';

void main() {
  group('Connectivity Tests', () {
    test('All transports can be instantiated', () {
      final transports = [
        BleTransport(),
        BluetoothClassicTransport(),
        BluetoothMeshTransport(),
        LoRaWanTransport(),
        DtnTransport(),
        SecureTransport(),
        WebRtcTransport(),
      ];

      for (final transport in transports) {
        expect(transport.descriptor.id, isNotEmpty);
        expect(transport.descriptor.name, isNotEmpty);
      }
    });

    test('Supported transports list is correct', () {
      final supportedTransports = TransportRegistry.getSupportedTransports();
      
      expect(supportedTransports.length, greaterThan(10));
      
      final transportIds = supportedTransports.map((t) => t.descriptor.id).toList();
      expect(transportIds, contains('ble'));
      expect(transportIds, contains('bluetooth_classic'));
      expect(transportIds, contains('bluetooth_mesh'));
      expect(transportIds, contains('lorawan'));
      expect(transportIds, contains('dtn'));
      expect(transportIds, contains('secure'));
      expect(transportIds, contains('webrtc'));
    });

    test('Technology registry is consistent', () {
      final allTechs = TechRegistry.all;
      
      expect(allTechs.length, equals(186));
      
      final supportedCount = allTechs.where((t) => t.status == TechnologyStatus.supported).length;
      expect(supportedCount, equals(15));
    });
  });
}
