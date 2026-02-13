import 'transport_layer.dart';
import 'transport_descriptor.dart';

class TransportActivation {
  final bool bluetoothClassic;
  final bool bluetoothMesh;
  final bool ethernet;
  final bool acoustic;
  final bool optical;
  final bool lorawan;
  final bool satD2d;
  final bool mqtt;

  const TransportActivation({
    this.bluetoothClassic = false,
    this.bluetoothMesh = false,
    this.ethernet = false,
    this.acoustic = false,
    this.optical = false,
    this.lorawan = false,
    this.satD2d = false,
    this.mqtt = false,
  });
}

abstract class TransportProvider {
  List<TransportLayer> buildLayers(TransportActivation activation);
  List<TransportDescriptor> get knownDescriptors;
}

TransportProvider getProvider() =>
    throw UnsupportedError('Platform logic failed');
