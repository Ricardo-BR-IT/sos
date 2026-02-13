import 'dart:async';
import 'package:sos_kernel/sos_kernel.dart';
import '../protocol/robotics_protocol.dart';

/// Service to manage decentralized drone fleets and robotics telemetry.
class DroneService {
  static final DroneService _instance = DroneService._internal();
  static DroneService get instance => _instance;

  DroneService._internal();

  MeshService? _meshService;
  final Map<String, DroneTelemetry> _activeDrones = {};

  final _telemetryController = StreamController<DroneTelemetry>.broadcast();
  Stream<DroneTelemetry> get telemetryStream => _telemetryController.stream;

  final _peerDronesController =
      StreamController<List<DroneTelemetry>>.broadcast();
  Stream<List<DroneTelemetry>> get activeDronesStream =>
      _peerDronesController.stream;

  void initialize(MeshService meshService) {
    _meshService = meshService;

    // Listen for robotics envelopes on the mesh
    _meshService!.messages.listen((envelope) {
      if (envelope.type == RoboticsProtocol.topicTelemetry) {
        _handleTelemetry(envelope);
      }
    });
  }

  void _handleTelemetry(SosEnvelope envelope) {
    try {
      final tlm = DroneTelemetry.fromJson(envelope.sender, envelope.payload);
      _activeDrones[tlm.droneId] = tlm;
      _telemetryController.add(tlm);
      _peerDronesController.add(_activeDrones.values.toList());

      TelemetryService.instance.logEvent('drone_tlm_rx', data: {
        'droneId': tlm.droneId,
        'bat': tlm.battery,
        'st': tlm.status,
      });
    } catch (e) {
      // Invalid telemetry format
    }
  }

  /// Sends a command to a specific drone.
  Future<void> sendCommand(String droneId, int commandId,
      {Map<String, dynamic>? params}) async {
    final payload = RoboticsProtocol.createCommand(
      commandId: commandId,
      params: params,
    );

    await _meshService?.sendDirect(
      targetId: droneId,
      type: RoboticsProtocol.topicCommand,
      payload: payload,
    );

    TelemetryService.instance.logEvent('drone_cmd_tx', data: {
      'droneId': droneId,
      'cmd': commandId,
    });
  }

  List<DroneTelemetry> get allDrones => _activeDrones.values.toList();

  void dispose() {
    _telemetryController.close();
    _peerDronesController.close();
  }
}
