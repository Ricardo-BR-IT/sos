import 'dart:async';
import 'dart:io';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Iridium Short Burst Data (SBD) Transport Layer.
/// Provides satellite fallback for areas with no terrestrial connectivity.
class IridiumSbdTransport extends TransportLayer {
  final String _serialPort;
  final int _baudRate;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );
  int _signalQuality = 0;
  Timer? _pollTimer;

  static const kDescriptor = TransportDescriptor(
    id: 'iridium_sbd',
    name: 'Iridium Satellite SBD',
    technologyIds: ['iridium', 'sbd'],
    mediums: ['satellite', 'l-band'],
    requiresGateway: false,
    notes: 'Requires Iridium 9602/9603 modem and active SBD subscription.',
  );

  IridiumSbdTransport({
    required String serialPort,
    int baudRate = 19200,
  })  : _serialPort = serialPort,
        _baudRate = baudRate;

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

  int get signalQuality => _signalQuality;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Configure serial port
      if (Platform.isWindows) {
        await Process.run('mode', [
          '$_serialPort:',
          'baud=$_baudRate',
          'parity=n',
          'data=8',
          'stop=1'
        ]);
      } else {
        await Process.run('stty', ['-F', _serialPort, '$_baudRate', 'raw']);
      }

      // Initialize modem
      await _sendAt('AT');
      await _sendAt('AT&F0');
      await _sendAt('AT&K0');
      await _sendAt('AT+SBDMTA=1');

      await _checkSignal();

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      _startPolling();
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<String> _sendAt(String command) async {
    final file = File(_serialPort);
    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln(command);
    await sink.flush();
    await sink.close();
    await Future.delayed(const Duration(milliseconds: 500));
    return 'OK'; // Simplified
  }

  Future<void> _checkSignal() async {
    final response = await _sendAt('AT+CSQ');
    final match = RegExp(r'\+CSQ:(\d)').firstMatch(response);
    if (match != null) {
      _signalQuality = int.parse(match.group(1)!);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_health.availability != TransportAvailability.available) return;

      final response = await _sendAt('AT+SBDIX');
      if (response.contains('+SBDIX:')) {
        final parts = response.split(',');
        if (parts.length >= 5) {
          final mtLength = int.tryParse(parts[4]) ?? 0;
          if (mtLength > 0) {
            final msgResponse = await _sendAt('AT+SBDRT');
            _handleIncomingMessage(msgResponse);
          }
        }
      }
    });
  }

  void _handleIncomingMessage(String data) {
    final packet = TransportPacket(
      senderId: 'IRIDIUM_GW',
      recipientId: null,
      type: SosPacketType.sos,
      payload: {'message': data, 'source': 'Iridium SBD'},
      rxTransportId: descriptor.id,
      metadata: {'signal': _signalQuality},
    );
    _incomingController.add(packet);
  }

  @override
  Future<void> broadcast(String message) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('Iridium modem not connected');
    }
    if (_signalQuality < 2) {
      throw Exception('Iridium signal too weak: $_signalQuality');
    }

    await _sendAt('AT+SBDWT=$message');
    await _sendAt('AT+SBDIX');
  }

  @override
  Future<void> send(TransportPacket packet) async {
    final message = packet.payload['message']?.toString() ?? packet.toJson();
    await broadcast(message);
  }

  @override
  Future<void> connect(String peerId) async {
    // Satellite is broadcast-only, no direct peer connections
  }

  @override
  Future<void> dispose() async {
    _pollTimer?.cancel();
    await _incomingController.close();
  }
}
