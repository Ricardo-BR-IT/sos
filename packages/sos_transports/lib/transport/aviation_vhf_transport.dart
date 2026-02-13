import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Aviation VHF Transport Layer.
/// Emergency communications on aviation frequencies (121.5 MHz).
class AviationVhfTransport extends TransportLayer {
  final String _serialPort;
  final double _frequency; // MHz

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'aviation_vhf',
    name: 'Aviation VHF Emergency',
    technologyIds: ['vhf_aviation', 'elt', 'acars'],
    mediums: ['radio', 'vhf'],
    requiresGateway: false,
    notes:
        '121.5 MHz international emergency. 243.0 MHz military. Requires license.',
  );

  AviationVhfTransport({
    required String serialPort,
    double frequency = 121.5, // International distress
  })  : _serialPort = serialPort,
        _frequency = frequency;

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
    // Configure aviation band radio
    // Set frequency, 8.33 kHz or 25 kHz channel spacing
    await _sendCommand('FA${(_frequency * 1e6).toInt()}'); // Set VFO A
    await _sendCommand('MD2'); // Set AM mode
  }

  Future<String> _sendCommand(String command) async {
    return 'OK';
  }

  void _startListening() {
    // Monitor guard frequency for distress calls
    // SELCAL decoding if equipped
  }

  /// Send MAYDAY distress call
  Future<void> sendMayday({
    required String callsign,
    required String position,
    required String nature,
  }) async {
    final message = 'MAYDAY MAYDAY MAYDAY '
        'THIS IS $callsign $callsign $callsign '
        'MAYDAY $callsign '
        'MY POSITION IS $position '
        '$nature '
        'OVER';
    await broadcast(message);
  }

  /// Send PAN-PAN urgency call
  Future<void> sendPanPan({
    required String callsign,
    required String situation,
  }) async {
    final message = 'PAN PAN PAN PAN PAN PAN '
        'ALL STATIONS ALL STATIONS ALL STATIONS '
        'THIS IS $callsign $callsign $callsign '
        '$situation '
        'OVER';
    await broadcast(message);
  }

  @override
  Future<void> broadcast(String message) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('Aviation VHF not connected');
    }
    // Transmit voice message
    // In real implementation, key PTT and send audio
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      await sendMayday(
        callsign: packet.senderId,
        position: packet.payload['position']?.toString() ?? 'UNKNOWN',
        nature: packet.payload['message']?.toString() ?? 'EMERGENCY',
      );
    }
  }

  @override
  Future<void> connect(String peerId) async {
    // Broadcast medium
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
