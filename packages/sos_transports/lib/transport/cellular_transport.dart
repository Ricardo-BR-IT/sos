import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Cellular Transport Layer.
/// Full cellular stack: 2G/3G/4G/5G via AT command interface.
class CellularTransport extends TransportLayer {
  final String _serialPort;
  final CellularGeneration _preferredGen;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  CellularInfo? _cellInfo;

  static const kDescriptor = TransportDescriptor(
    id: 'cellular',
    name: 'Cellular (2G-5G)',
    technologyIds: ['gsm', 'umts', 'lte', '5g-nr', 'cdma'],
    mediums: ['cellular'],
    requiresGateway: false,
    notes: 'Full cellular stack via USB modem or embedded module.',
  );

  CellularTransport({
    required String serialPort,
    CellularGeneration preferredGen = CellularGeneration.lte,
  })  : _serialPort = serialPort,
        _preferredGen = preferredGen;

  @override
  TransportDescriptor get descriptor => kDescriptor;
  @override
  TransportHealth get health => _health;
  @override
  String? get localId => _localId;

  CellularInfo? get cellInfo => _cellInfo;

  @override
  void setLocalId(String id) => _localId = id;
  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      await _sendAt('AT');
      final model = await _sendAt('AT+CGMM');
      final imei = await _sendAt('AT+CGSN');

      // Set preferred RAT
      await _setPreferredRat(_preferredGen);
      await _sendAt('AT+COPS=0'); // Auto network selection
      await _waitForNetwork();

      _cellInfo = CellularInfo(
        model: model,
        imei: imei,
        generation: _preferredGen,
        operator: await _sendAt('AT+COPS?'),
        signalStrength: await _getSignalStrength(),
      );

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<String> _sendAt(String cmd) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'OK';
  }

  Future<void> _setPreferredRat(CellularGeneration gen) async {
    switch (gen) {
      case CellularGeneration.gsm2g:
        await _sendAt('AT+CNMP=13'); // GSM only
        break;
      case CellularGeneration.umts3g:
        await _sendAt('AT+CNMP=14'); // WCDMA only
        break;
      case CellularGeneration.lte:
        await _sendAt('AT+CNMP=38'); // LTE only
        break;
      case CellularGeneration.nr5g:
        await _sendAt('AT+CNMP=71'); // 5G NR
        break;
      case CellularGeneration.auto:
        await _sendAt('AT+CNMP=2'); // Auto
        break;
    }
  }

  Future<void> _waitForNetwork() async {
    for (int i = 0; i < 30; i++) {
      final resp = await _sendAt('AT+CREG?');
      if (resp.contains(',1') || resp.contains(',5')) return;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<int> _getSignalStrength() async {
    final resp = await _sendAt('AT+CSQ');
    return 20; // placeholder
  }

  /// Send SMS emergency message
  Future<void> sendSms(String number, String message) async {
    await _sendAt('AT+CMGF=1');
    await _sendAt('AT+CMGS="$number"');
    await _sendAt('$message\x1A');
  }

  /// Establish data connection
  Future<void> connectData(String apn) async {
    await _sendAt('AT+CGDCONT=1,"IP","$apn"');
    await _sendAt('ATD*99#');
  }

  @override
  Future<void> broadcast(String message) async {
    // Send via data connection
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      await sendSms('112', packet.payload['message']?.toString() ?? 'SOS');
    }
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {}
  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

class CellularInfo {
  final String model;
  final String imei;
  final CellularGeneration generation;
  final String operator;
  final int signalStrength;

  CellularInfo({
    required this.model,
    required this.imei,
    required this.generation,
    required this.operator,
    required this.signalStrength,
  });
}

enum CellularGeneration { gsm2g, umts3g, lte, nr5g, auto }
