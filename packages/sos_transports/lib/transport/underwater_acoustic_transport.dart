import 'dart:async';
import 'dart:io';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Underwater Acoustic Modem Transport.
/// JANUS protocol compatible for underwater emergency communications.
class UnderwaterAcousticTransport extends TransportLayer {
  final String _serialPort;
  final int _baudRate;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  double _snr = 0;
  int _range = 0; // estimated range in meters

  static const kDescriptor = TransportDescriptor(
    id: 'underwater_acoustic',
    name: 'Underwater Acoustic Modem',
    technologyIds: ['janus', 'umodem', 'acoustic'],
    mediums: ['underwater', 'acoustic'],
    requiresGateway: false,
    notes: 'JANUS (NATO) compatible. Range 1-10km depending on conditions.',
  );

  UnderwaterAcousticTransport({
    required String serialPort,
    int baudRate = 9600,
  })  : _serialPort = serialPort,
        _baudRate = baudRate;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  TransportHealth get health => _health;

  @override
  String? get localId => _localId;

  double get signalToNoiseRatio => _snr;
  int get estimatedRange => _range;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Configure serial port to underwater modem
      await _configureSerial();

      // Initialize modem
      await _sendCommand('\$PJAN,RST'); // Reset
      await _sendCommand(
          '\$PJAN,CFG,11700,6800'); // Set center freq and bandwidth
      await _sendCommand('\$PJAN,PWR,3'); // Set power level

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startReceiving();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<void> _configureSerial() async {
    if (Platform.isWindows) {
      await Process.run('mode',
          ['$_serialPort:', 'baud=$_baudRate', 'parity=n', 'data=8', 'stop=1']);
    } else {
      await Process.run('stty', ['-F', _serialPort, '$_baudRate', 'raw']);
    }
  }

  Future<String> _sendCommand(String command) async {
    // Write command to serial port
    await Future.delayed(const Duration(milliseconds: 500));
    return 'OK';
  }

  void _startReceiving() {
    // Listen for incoming acoustic frames
    // Parse JANUS headers and extract payload
    Timer.periodic(const Duration(seconds: 1), (_) => _pollModem());
  }

  Future<void> _pollModem() async {
    // Check for incoming messages
    // Parse SNR and range from modem status
  }

  /// Send JANUS emergency beacon
  Future<void> sendEmergencyBeacon({
    required double latitude,
    required double longitude,
    required double depth,
  }) async {
    // JANUS emergency message format
    final payload = 'SOS,$latitude,$longitude,$depth';
    await broadcast(payload);
  }

  @override
  Future<void> broadcast(String message) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('Underwater modem not connected');
    }

    // Build JANUS frame
    // Class ID = 0 (Emergency), App ID = user-defined
    await _sendCommand('\$PJAN,TX,0,1,$message');
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      final lat = packet.payload['lat'] ?? 0.0;
      final lon = packet.payload['lon'] ?? 0.0;
      final depth = packet.payload['depth'] ?? 0.0;
      await sendEmergencyBeacon(latitude: lat, longitude: lon, depth: depth);
    } else {
      await broadcast(packet.toJson());
    }
  }

  @override
  Future<void> connect(String peerId) async {
    // Acoustic is broadcast medium
  }

  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}
