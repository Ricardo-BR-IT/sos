import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Z-Wave IoT Transport Layer.
/// Home automation mesh for panic buttons and sensors.
class ZwaveTransport extends TransportLayer {
  final String _serialPort;
  final int _homeId;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  final Map<int, ZwaveNode> _nodes = {};

  static const kDescriptor = TransportDescriptor(
    id: 'zwave',
    name: 'Z-Wave',
    technologyIds: ['zwave', 'zwave-lr'],
    mediums: ['radio', 'sub-ghz'],
    requiresGateway: true,
    notes: 'Sub-GHz mesh (908/868 MHz). Up to 232 nodes. Z-Wave LR: 1.6km.',
  );

  ZwaveTransport({required String serialPort, int homeId = 0})
      : _serialPort = serialPort,
        _homeId = homeId;

  @override
  TransportDescriptor get descriptor => kDescriptor;
  @override
  TransportHealth get health => _health;
  @override
  String? get localId => _localId;
  @override
  void setLocalId(String id) => _localId = id;
  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Initialize Z-Wave USB controller (e.g. Aeotec Z-Stick)
      await _initController();
      await _discoverNodes();

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startEventMonitoring();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<void> _initController() async {
    // Send SOF frame to Z-Wave controller
    // Get home ID and node list
  }

  Future<void> _discoverNodes() async {
    // Query controller for all node IDs
    // Get node info (device class, supported command classes)
  }

  void _startEventMonitoring() {
    // Listen for unsolicited events from nodes:
    // - Alarm/Notification CC (panic buttons, smoke detectors)
    // - Sensor Multilevel CC (temperature, humidity)
    // - Door Lock CC (security status)
  }

  /// Include new node (start pairing)
  Future<void> includeNode() async {
    // Put controller in inclusion mode
  }

  /// Exclude node (remove from network)
  Future<void> excludeNode(int nodeId) async {
    _nodes.remove(nodeId);
  }

  /// Send command to node
  Future<void> sendCommand(
      int nodeId, int commandClass, List<int> payload) async {
    // Build Z-Wave frame and send
  }

  /// Trigger alarm on all siren nodes
  Future<void> triggerSosAlarm() async {
    for (final node in _nodes.values) {
      if (node.type == ZwaveDeviceType.siren) {
        await sendCommand(node.id, 0x71, [0x05, 0x01]); // Notification CC
      }
    }
  }

  @override
  Future<void> broadcast(String message) async {
    // Z-Wave doesn't support broadcast data
    await triggerSosAlarm();
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      await triggerSosAlarm();
    }
  }

  @override
  Future<void> connect(String peerId) async {}
  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

class ZwaveNode {
  final int id;
  final ZwaveDeviceType type;
  final String name;
  final List<int> commandClasses;

  ZwaveNode({
    required this.id,
    required this.type,
    required this.name,
    required this.commandClasses,
  });
}

enum ZwaveDeviceType {
  siren,
  panicButton,
  motionSensor,
  doorLock,
  smokeSensor,
  floodSensor,
  thermostat,
  switchBinary,
  dimmer,
  other,
}
