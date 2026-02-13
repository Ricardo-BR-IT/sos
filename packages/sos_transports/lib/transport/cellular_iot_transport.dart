import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// LTE-M / NB-IoT Cellular Transport Layer.
/// Low-power wide-area cellular for IoT devices.
class CellularIotTransport extends TransportLayer {
  final String _apn;
  final CellularMode _mode;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  int _signalStrength = 0; // 0-31 CSQ scale
  String? _imei;
  String? _iccid;

  static const kDescriptor = TransportDescriptor(
    id: 'cellular_iot',
    name: 'LTE-M / NB-IoT',
    technologyIds: ['lte-m', 'nb-iot', 'cat-m1', 'cat-nb1'],
    mediums: ['cellular', 'lpwan'],
    requiresGateway: false,
    notes: 'Low-power cellular for IoT. Requires SIM card with IoT data plan.',
  );

  CellularIotTransport({
    String apn = 'iot.provider.com',
    CellularMode mode = CellularMode.lteM,
  })  : _apn = apn,
        _mode = mode;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  TransportHealth get health => _health;

  @override
  String? get localId => _localId;

  int get signalStrength => _signalStrength;
  String? get imei => _imei;
  String? get iccid => _iccid;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Initialize cellular modem via AT commands
      await _sendAt('AT');
      await _sendAt('AT+CFUN=1'); // Full functionality

      // Get modem info
      _imei = await _sendAt('AT+CGSN');
      _iccid = await _sendAt('AT+CCID');

      // Configure for IoT mode
      if (_mode == CellularMode.lteM) {
        await _sendAt('AT+COPS=0,,,7'); // LTE Cat-M1
      } else {
        await _sendAt('AT+COPS=0,,,9'); // NB-IoT
      }

      // Set APN
      await _sendAt('AT+CGDCONT=1,"IP","$_apn"');

      // Enable network registration
      await _sendAt('AT+CEREG=2');

      // Wait for registration
      await _waitForRegistration();

      // Check signal
      await _checkSignal();

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startSignalMonitoring();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<String> _sendAt(String command) async {
    // In real implementation, send via serial port to modem
    await Future.delayed(const Duration(milliseconds: 100));
    return 'OK';
  }

  Future<void> _waitForRegistration() async {
    for (int i = 0; i < 60; i++) {
      final response = await _sendAt('AT+CEREG?');
      if (response.contains(',1') || response.contains(',5')) {
        return; // Registered home or roaming
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Network registration timeout');
  }

  Future<void> _checkSignal() async {
    final response = await _sendAt('AT+CSQ');
    final match = RegExp(r'\+CSQ:\s*(\d+)').firstMatch(response);
    if (match != null) {
      _signalStrength = int.parse(match.group(1)!);
    }
  }

  void _startSignalMonitoring() {
    Timer.periodic(const Duration(minutes: 5), (_) => _checkSignal());
  }

  @override
  Future<void> broadcast(String message) async {
    // Cellular is point-to-point, send to configured server
    await _sendData(message);
  }

  Future<void> _sendData(String data) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('Cellular not connected');
    }

    // Open socket and send
    await _sendAt('AT+USOCR=6'); // Create TCP socket
    await _sendAt('AT+USOCO=0,"sos-server.example.com",8080');
    await _sendAt('AT+USOWR=0,${data.length},"$data"');
    await _sendAt('AT+USOCL=0'); // Close socket
  }

  @override
  Future<void> send(TransportPacket packet) async {
    final json = packet.toJson();
    await _sendData(json);
  }

  @override
  Future<void> connect(String peerId) async {
    // Cellular connects to servers, not peers directly
  }

  @override
  Future<void> dispose() async {
    await _sendAt('AT+CFUN=0'); // Minimum functionality
    await _incomingController.close();
  }
}

enum CellularMode { lteM, nbIot }
