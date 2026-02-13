import 'transport_provider.dart';
import 'transport_layer.dart';
import 'transport_descriptor.dart';

class WebTransportProvider implements TransportProvider {
  @override
  List<TransportLayer> buildLayers(TransportActivation activation) {
    // For now, return empty list or mock.
    // In future, implement WebRTC or WebSocket transport here.
    return [];
  }

  @override
  List<TransportDescriptor> get knownDescriptors => [];
}

TransportProvider getProvider() => WebTransportProvider();
