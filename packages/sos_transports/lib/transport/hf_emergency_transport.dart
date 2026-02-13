import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// HF Emergency Transport Layer.
/// Long-range HF radio for maritime/wilderness distress.
class HfEmergencyTransport extends TransportLayer {
  final String _serialPort;
  final HfBand _band;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'hf_emergency',
    name: 'HF Emergency Radio',
    technologyIds: ['hf', 'ssb', 'gmdss', 'mfhf'],
    mediums: ['radio', 'hf'],
    requiresGateway: false,
    notes: 'Long-range (1000s km) emergency. GMDSS DSC on 2187.5 kHz.',
  );

  HfEmergencyTransport({
    required String serialPort,
    HfBand band = HfBand.maritime2mhz,
  })  : _serialPort = serialPort,
        _band = band;

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
    // Configure HF transceiver for emergency band
    final freq = _getBandFrequency(_band);
    await _sendCommand('FA$freq');
    await _sendCommand('MD1'); // USB mode
  }

  int _getBandFrequency(HfBand band) {
    switch (band) {
      case HfBand.maritime2mhz:
        return 2182000; // 2182 kHz international calling/distress
      case HfBand.maritime4mhz:
        return 4125000;
      case HfBand.maritime6mhz:
        return 6215000;
      case HfBand.maritime8mhz:
        return 8291000;
      case HfBand.maritime12mhz:
        return 12290000;
      case HfBand.maritime16mhz:
        return 16420000;
      case HfBand.hamEmergency:
        return 7095000; // 40m emergency net
    }
  }

  Future<String> _sendCommand(String command) async {
    return 'OK';
  }

  void _startListening() {
    // Monitor for DSC distress alerts
    // Monitor voice channel for distress calls
  }

  /// Send Digital Selective Calling (DSC) distress
  Future<void> sendDscDistress({
    required String mmsi,
    required DscDistressType nature,
    required double latitude,
    required double longitude,
  }) async {
    // Format DSC distress message
    // Includes MMSI, position, nature of distress
    // Automatically sent to all stations and coast stations
  }

  /// Send MAYDAY on voice channel
  Future<void> sendMayday({
    required String vessel,
    required String position,
    required String nature,
    required int personsOnBoard,
  }) async {
    final message = 'MAYDAY MAYDAY MAYDAY '
        'THIS IS $vessel $vessel $vessel '
        'MAYDAY $vessel '
        'MY POSITION IS $position '
        '$nature '
        '$personsOnBoard PERSONS ON BOARD '
        'OVER';
    await broadcast(message);
  }

  @override
  Future<void> broadcast(String message) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('HF Radio not connected');
    }
    // Transmit on current frequency
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      await sendMayday(
        vessel: packet.senderId,
        position: packet.payload['position']?.toString() ?? 'UNKNOWN',
        nature: packet.payload['message']?.toString() ?? 'EMERGENCY',
        personsOnBoard: packet.payload['persons'] as int? ?? 1,
      );
    }
  }

  @override
  Future<void> connect(String peerId) async {
    // HF is broadcast
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

enum HfBand {
  maritime2mhz,
  maritime4mhz,
  maritime6mhz,
  maritime8mhz,
  maritime12mhz,
  maritime16mhz,
  hamEmergency,
}

enum DscDistressType {
  fire,
  flooding,
  collision,
  grounding,
  listing,
  sinking,
  disabled,
  abandoning,
  piracy,
  personOverboard,
  undesignated,
}
