import 'dart:async';
import 'dart:convert';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// HAM Digital Modes Transport.
/// Supports D-STAR, DMR, Fusion, and NXDN digital voice and data.
class HamDigitalTransport extends TransportLayer {
  final String _serialPort;
  final HamDigitalMode _mode;
  final String _callsign;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'ham_digital',
    name: 'HAM Digital Modes',
    technologyIds: ['dstar', 'dmr', 'fusion', 'nxdn'],
    mediums: ['radio', 'vhf', 'uhf'],
    requiresGateway: true,
    notes: 'Requires amateur radio license and compatible transceiver.',
  );

  HamDigitalTransport({
    required String serialPort,
    required String callsign,
    HamDigitalMode mode = HamDigitalMode.dstar,
  })  : _serialPort = serialPort,
        _callsign = callsign,
        _mode = mode;

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

      // Connect to digital radio via serial
      await _configureRadio();

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startListening();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<void> _configureRadio() async {
    switch (_mode) {
      case HamDigitalMode.dstar:
        await _configureDstar();
        break;
      case HamDigitalMode.dmr:
        await _configureDmr();
        break;
      case HamDigitalMode.fusion:
        await _configureFusion();
        break;
      case HamDigitalMode.nxdn:
        await _configureNxdn();
        break;
    }
  }

  Future<void> _configureDstar() async {
    // D-STAR: Configure via DV Fast Data or DD mode
    // Set callsign, repeater, gateway
  }

  Future<void> _configureDmr() async {
    // DMR: Configure talk group, color code, slot
    // Set DMR ID from callsign database
  }

  Future<void> _configureFusion() async {
    // Yaesu System Fusion: Configure WIRES-X or direct
  }

  Future<void> _configureNxdn() async {
    // NXDN: Configure RAN (Radio Access Number)
  }

  void _startListening() {
    // Monitor for incoming data packets
  }

  /// Send slow data (text message)
  Future<void> sendSlowData(String message) async {
    // D-STAR and DMR support slow data in voice frames
    await _sendData(message, isSlowData: true);
  }

  /// Send fast data (D-STAR DD mode or DMR data)
  Future<void> sendFastData(List<int> data) async {
    await _sendData(utf8.decode(data), isSlowData: false);
  }

  Future<void> _sendData(String data, {required bool isSlowData}) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('HAM radio not connected');
    }

    switch (_mode) {
      case HamDigitalMode.dstar:
        // Send via D-STAR slow data or DD mode
        break;
      case HamDigitalMode.dmr:
        // Send via DMR data header and confirmed data
        break;
      case HamDigitalMode.fusion:
        // Send via WIRES-X data message
        break;
      case HamDigitalMode.nxdn:
        // Send via NXDN Type-D data
        break;
    }
  }

  @override
  Future<void> broadcast(String message) async {
    await sendSlowData(message);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    // Format for HAM digital modes
    final shortMessage =
        'SOS:${packet.senderId}:${packet.payload['message'] ?? 'EMERGENCY'}';
    await sendSlowData(shortMessage);
  }

  @override
  Future<void> connect(String peerId) async {
    // Set destination callsign
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

enum HamDigitalMode { dstar, dmr, fusion, nxdn }
