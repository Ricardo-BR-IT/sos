import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class OpticalTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'optical',
    name: 'Optical/LED Link',
    technologyIds: [
      'opt_fiber_smf',
      'opt_fiber_mmf',
      'opt_cwdm',
      'opt_dwdm',
      'opt_coherent',
      'opt_polarization',
      'opt_sdm',
      'lifi_vlc',
      'opt_fso',
      'opt_ir_fso',
      'opt_uv',
      'opt_thz',
      'opt_ir_remote',
      'opt_irda',
      'opt_underwater_vlc',
      'opt_silicon_photonics',
      'opt_optical_switching',
      'opt_qkd_fiber',
      'opt_quantum_repeaters',
    ],
    mediums: ['optical'],
    requiresGateway: true,
    notes: 'Requer emissor/receptor optico ou LED modulado.',
  );

  final bool enabled;
  String? _localId;

  OpticalTransport({this.enabled = false});

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
      markUnavailable('Optico desativado.');
      return;
    }
    markUnavailable('Optico ainda nao implementado.');
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
