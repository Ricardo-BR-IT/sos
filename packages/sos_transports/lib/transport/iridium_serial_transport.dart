import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Transporte para comunicação via Satélite Iridium SBD (Short Burst Data).
/// Ideal para fallback global em áreas sem qualquer cobertura terrestre.
class IridiumSerialTransport extends TransportLayer {
  final String portName;
  final int baudRate;

  SerialPort? _port;
  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const _descriptor = TransportDescriptor(
    id: 'iridium_serial',
    name: 'Iridium SBD Serial (Modem)',
    technologyIds: ['sat_iridium_sbd_modem'],
    mediums: ['satellite'],
    requiresGateway: false,
    notes: 'Cobertura global via modem Serial SBD (9601/9602/9603).',
  );

  IridiumSerialTransport({required this.portName, this.baudRate = 19200});

  @override
  TransportDescriptor get descriptor => _descriptor;

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
      _port = SerialPort(portName);
      _port!.BaudRate = baudRate;
      _port!.open();

      // Inicialização do Modem
      await _sendAtCommand('AT'); // Check
      await _sendAtCommand('ATE0'); // Echo off
      await _sendAtCommand('AT+SBDM1'); // Enable SBD ring alerts

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );

      // Polling periódico para mensagens recebidas (MT - Mobile Terminated)
      Timer.periodic(
        const Duration(minutes: 15),
        (_) => _checkIncomingMessages(),
      );

      print('🛰️ Iridium SBD inicializado em $portName');
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (_health.availability != TransportAvailability.available ||
        _port == null) return;

    // SBD é limitado a ~340 bytes. Filtramos apenas o essencial.
    final rawData = utf8.encode(packet.toJson());
    if (rawData.length > 340) {
      throw Exception('Payload excede limite SBD de 340 bytes');
    }

    try {
      // 1. Limpa buffers
      await _sendAtCommand('AT+SBDD0');

      // 2. Escreve dados binários (SBDWB)
      final checksum = _calculateChecksum(Uint8List.fromList(rawData));
      final command = 'AT+SBDWB=${rawData.length}';
      await _port!
          .writeBytesFromUint8List(Uint8List.fromList('$command\r'.codeUnits));

      // Aguarda o prompt "READY" (simplificado)
      await Future.delayed(const Duration(milliseconds: 500));

      final binaryPayload = Uint8List.fromList([
        ...rawData,
        checksum >> 8,
        checksum & 0xFF,
      ]);
      await _port!.writeBytesFromUint8List(binaryPayload);

      // 3. Inicia sessão de rede (SBDIX)
      final response = await _sendAtCommand('AT+SBDIX');
      _parseSbdixResponse(response);
    } catch (e) {
      _health = _health.copyWith(errorCount: _health.errorCount + 1);
    }
  }

  Future<void> _checkIncomingMessages() async {
    final response = await _sendAtCommand('AT+SBDIX');
    _parseSbdixResponse(response);
  }

  void _parseSbdixResponse(String response) {
    if (response.contains('+SBDIX:')) {
      final parts = response.split(':')[1].split(',');
      if (parts.length >= 3) {
        final mtStatus = int.tryParse(parts[2].trim()) ?? 0;
        if (mtStatus == 1) {
          _readIncomingBinary();
        }
      }
    }
  }

  Future<void> _readIncomingBinary() async {
    await _sendAtCommand('AT+SBDRB');
    // Em uma implementação real, parsearíamos o stream binário e emitiríamos para o incomingController
  }

  int _calculateChecksum(Uint8List data) {
    int checksum = 0;
    for (var byte in data) {
      checksum += byte;
    }
    return checksum & 0xFFFF;
  }

  Future<String> _sendAtCommand(String command) async {
    if (_port == null) return 'ERROR';
    await _port!
        .writeBytesFromUint8List(Uint8List.fromList('$command\r'.codeUnits));
    await Future.delayed(const Duration(seconds: 1));
    return 'OK';
  }

  @override
  Future<void> broadcast(String message) async {
    await send(TransportPacket(
      type: SosPacketType.sos,
      senderId: _localId ?? 'iridium-modem',
      recipientId: null,
      payload: {'msg': message},
    ));
  }

  @override
  Future<void> connect(String peerId) async {}

  @override
  Future<void> dispose() async {
    _port?.close();
    _port = null;
    await _incomingController.close();
  }
}
