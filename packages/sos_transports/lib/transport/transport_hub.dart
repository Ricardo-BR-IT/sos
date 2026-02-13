import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_metrics.dart';
import 'transport_packet.dart';

abstract class TransportBroadcaster {
  Future<void> broadcastVia(String transportId, String message);
  Future<void> sendToTransport(String transportId, TransportPacket packet);
  List<TransportDescriptor> get descriptors;
  Map<String, TransportHealth> get healthSnapshot;
  Map<String, TransportMetrics> get metricsSnapshot;
}
