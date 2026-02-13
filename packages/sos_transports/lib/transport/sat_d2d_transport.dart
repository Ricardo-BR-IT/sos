import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class SatD2DTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'sat_d2d',
    name: 'Satélite Direct-to-Device',
    technologyIds: ['sat_d2d', 'sat_ntn_3gpp', 'sat_lband', 'sat_iot'],
    mediums: ['satellite'],
    requiresGateway: true,
    notes: 'Requer modem satelital compatível (NTN/L-band).',
  );

  final bool enabled;
  String? _localId;

  SatD2DTransport({this.enabled = false});

  @override
  bool get isEnabled => enabled;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
  }

  @override
  Future<void> initialize() async {
    if (!enabled) {
      markUnavailable('Satélite D2D desativado.');
      return;
    }
    markUnavailable('Satélite D2D ainda nao implementado.');
  }

  @override
  Future<void> broadcast(String message) async {
    if (!enabled) return;
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {
    if (!enabled) return;
  }
}
