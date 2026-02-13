import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class AcousticTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'acoustic',
    name: 'Acoustic Modem',
    technologyIds: [
      'acoustic_voice',
      'acoustic_ultrasound',
      'acoustic_underwater',
      'acoustic_sonar',
      'acoustic_hydro_modem',
      'acoustic_usbl',
      'acoustic_janus',
      'acoustic_haptic',
      'acoustic_structure_vibration',
    ],
    mediums: ['acoustic'],
    requiresGateway: true,
    notes: 'Requer modem acustico ou hardware ultrassom.',
  );

  final bool enabled;
  String? _localId;

  AcousticTransport({this.enabled = false});

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
      markUnavailable('Acustico desativado.');
      return;
    }
    markUnavailable('Acustico ainda nao implementado.');
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
