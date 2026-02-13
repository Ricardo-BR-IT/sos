import 'transport_descriptor.dart';
import 'transport_layer.dart';
// Conditional Import
import 'transport_provider.dart'
    if (dart.library.io) 'transport_provider_io.dart'
    if (dart.library.html) 'transport_provider_web.dart';

export 'transport_provider.dart' show TransportActivation;

class TransportRegistry {
  static const TransportDescriptor cellularGateway = TransportDescriptor(
    id: 'cellular_gateway',
    name: 'Gateway Celular (2G-6G)',
    technologyIds: [
      'cell_4g_lte',
      'cell_5g_nr',
      'cell_ltem',
      'cell_nbiot',
    ],
    mediums: ['cellular'],
    requiresGateway: true,
  );

  static const TransportDescriptor iotGateway = TransportDescriptor(
    id: 'iot_gateway',
    name: 'Gateway IoT de Curta Distância',
    technologyIds: ['zigbee', 'thread', 'matter', 'nfc'],
    mediums: ['rf', 'iot'],
    requiresGateway: true,
  );

  static const TransportDescriptor radioGateway = TransportDescriptor(
    id: 'radio_gateway',
    name: 'Gateway Rádio (HF/VHF/UHF/LPWAN)',
    technologyIds: [
      'radio_ham_hf',
      'radio_ham_vhf',
      'radio_cb',
      'lpwan_sigfox'
    ],
    mediums: ['rf'],
    requiresGateway: true,
  );

  static const TransportDescriptor plcGateway = TransportDescriptor(
    id: 'plc_gateway',
    name: 'Gateway PLC/Smart Grid',
    technologyIds: ['plc_narrowband', 'plc_g3'],
    mediums: ['plc'],
    requiresGateway: true,
  );

  static const TransportDescriptor broadcastGateway = TransportDescriptor(
    id: 'broadcast_gateway',
    name: 'Gateway Broadcast',
    technologyIds: ['broadcast_dvb_t2', 'broadcast_isdb_t'],
    mediums: ['broadcast'],
    requiresGateway: true,
  );

  static const TransportDescriptor navigationGateway = TransportDescriptor(
    id: 'navigation_gateway',
    name: 'Gateway Navegação',
    technologyIds: ['nav_gps', 'nav_glonass'],
    mediums: ['navigation'],
    requiresGateway: true,
  );

  static const TransportDescriptor satelliteGateway = TransportDescriptor(
    id: 'satellite_gateway',
    name: 'Gateway Satélite',
    technologyIds: ['sat_leo', 'sat_starlink'],
    mediums: ['satellite'],
    requiresGateway: true,
  );

  static const TransportDescriptor meshOverlay = TransportDescriptor(
    id: 'mesh_overlay',
    name: 'Mesh Overlay',
    technologyIds: ['mesh_overlay'],
    mediums: ['mesh'],
    requiresGateway: false,
  );

  static const TransportDescriptor audioStack = TransportDescriptor(
    id: 'audio_stack',
    name: 'Camada de Audio/VoIP',
    technologyIds: ['audio_voip', 'audio_webrtc'],
    mediums: ['audio'],
    requiresGateway: false,
  );

  static const TransportDescriptor protocolStack = TransportDescriptor(
    id: 'protocol_stack',
    name: 'Camada de Protocolos',
    technologyIds: ['protocol_tcp', 'protocol_udp', 'protocol_mqtt'],
    mediums: ['protocol'],
    requiresGateway: false,
  );

  static const TransportDescriptor emergingGateway = TransportDescriptor(
    id: 'emerging_gateway',
    name: 'Gateway Tecnologias Emergentes',
    technologyIds: ['emerging_backscatter', 'emerging_molecular'],
    mediums: ['emerging'],
    requiresGateway: true,
  );

  static List<TransportDescriptor> knownDescriptors() {
    final providerDescriptors = getProvider().knownDescriptors;
    return [
      ...providerDescriptors,
      cellularGateway,
      iotGateway,
      radioGateway,
      plcGateway,
      broadcastGateway,
      navigationGateway,
      satelliteGateway,
      meshOverlay,
      audioStack,
      protocolStack,
      emergingGateway,
    ];
  }

  static List<TransportLayer> buildActiveLayers({
    TransportActivation activation = const TransportActivation(),
  }) {
    return getProvider().buildLayers(activation);
  }
}
