import 'transport_provider.dart';
import 'transport_layer.dart';
import 'transport_descriptor.dart';

import 'acoustic_transport.dart';
import 'bluetooth_classic_transport.dart';
import 'bluetooth_mesh_transport.dart';
import 'ble_transport.dart';
import 'lorawan_transport.dart';
import 'mqtt_transport.dart';
import 'optical_transport.dart';
import 'sat_d2d_transport.dart';
import 'aprs_transport.dart';
import 'iridium_sbd_transport.dart';
import 'wifi_direct_transport.dart';
import 'udp_transport.dart';

class IoTransportProvider implements TransportProvider {
  @override
  List<TransportLayer> buildLayers(TransportActivation activation) {
    return [
      BleTransport(),
      WiFiDirectTransport(),
      UdpBroadcastTransport(),
      if (activation.mqtt) MqttTransport(),
      if (activation.bluetoothClassic) BluetoothClassicTransport(),
      if (activation.bluetoothMesh) BluetoothMeshTransport(),
      if (activation.acoustic) AcousticTransport(),
      if (activation.optical) OpticalTransport(),
      if (activation.lorawan) LoRaWanTransport(),
      if (activation.satD2d) SatD2DTransport(),
    ];
  }

  @override
  List<TransportDescriptor> get knownDescriptors => [
        BleTransport.kDescriptor,
        BluetoothClassicTransport.kDescriptor,
        BluetoothMeshTransport.kDescriptor,
        WiFiDirectTransport.kDescriptor,
        UdpBroadcastTransport.kDescriptor,
        MqttTransport.kDescriptor,
        LoRaWanTransport.kDescriptor,
        SatD2DTransport.kDescriptor,
        AcousticTransport.kDescriptor,
        OpticalTransport.kDescriptor,
        AprsTransport.kDescriptor,
        IridiumSbdTransport.kDescriptor,
      ];
}

TransportProvider getProvider() => IoTransportProvider();
