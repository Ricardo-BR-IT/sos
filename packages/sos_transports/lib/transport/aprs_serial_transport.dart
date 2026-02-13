import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'transport_layer.dart';
import 'transport_packet.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';

/// Transporte para integração com a rede de Radioamador via APRS (KISS Protocol).
class AprsSerialTransport extends TransportLayer {
  final String portName;
  final int baudRate;
  final String callsign; // Ex: PY2SOS-1

  SerialPort? _port;
  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  // Constantes do Protocolo KISS
  static const int FEND = 0xC0;
  static const int FESC = 0xDB;
  static const int TFEND = 0xDC;
  static const int TFESC = 0xDD;

  static const kDescriptor = TransportDescriptor(
    id: 'aprs_serial',
    name: 'APRS Serial (KISS)',
    technologyIds: ['ham_aprs_kiss'],
    mediums: ['radio'],
    requiresGateway: false,
    notes: 'Amateur radio APRS via Serial TNC (KISS Protocol).',
  );

  AprsSerialTransport({
    required this.portName,
    required this.callsign,
    this.baudRate = 9600,
  });

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _port = SerialPort(portName);
      _port!.BaudRate = baudRate;
      _port!.open();

      // Inicia loop de leitura assíncrona (Polling)
      _startReadingLoop();

      print(
        '📡 APRS Serial Transport inicializado em $portName com callsign $callsign',
      );
    } catch (e) {
      print('❌ Erro ao inicializar APRS Serial Transport: $e');
      rethrow;
    }
  }

  Future<void> _startReadingLoop() async {
    while (_port != null && _port!.isOpened) {
      try {
        // Leitura de 1 byte por vez para processar o protocolo KISS
        final data = await _port!
            .readBytes(1, timeout: const Duration(milliseconds: 100));
        if (data.isNotEmpty) {
          _handleRawSerialData(data);
        }
      } catch (e) {
        // Pausa breve em caso de erro de leitura
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  void _handleRawSerialData(Uint8List data) {
    if (data.isEmpty) return;
    // Processamento KISS simplificado (acumulação de frames)
    // Para simplificar esta versão, assumimos que o frame KISS chega inteiro no loop
    // ou que o parser handleRawSerialData lida com fragmentos.

    if (data.first == FEND && data.last == FEND) {
      final payload = _decodeKISS(data.sublist(1, data.length - 1));
      final message = utf8.decode(payload, allowMalformed: true);

      // Verifica se é um pacote da mesh SOS
      if (message.contains('SOS:')) {
        final base64Part = message.split('SOS:').last;
        final rawData = base64.decode(base64Part);
        final packet = TransportPacket(
          type: SosPacketType.data,
          senderId: callsign,
          payload: {'msg': utf8.decode(rawData, allowMalformed: true)},
        );
        _incomingController.add(packet);
      }
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (_port == null || !_port!.isOpened) return;

    // Formata o pacote no padrão APRS: SOURCE>DEST,PATH:PAYLOAD
    final aprsHeader = '$callsign>APRS,WIDE1-1,WIDE2-1::OBJECT :SOS:';
    final payloadJson = packet.toJson();
    final encodedPayload = base64.encode(utf8.encode(payloadJson));
    final fullMessage = '$aprsHeader$encodedPayload';

    final kissFrame = _encodeKISS(utf8.encode(fullMessage));
    await _port!.writeBytesFromUint8List(
      Uint8List.fromList([FEND, 0x00, ...kissFrame, FEND]),
    );
  }

  List<int> _encodeKISS(List<int> data) {
    final List<int> escaped = [];
    for (var b in data) {
      if (b == FEND) {
        escaped.add(FESC);
        escaped.add(TFEND);
      } else if (b == FESC) {
        escaped.add(FESC);
        escaped.add(TFESC);
      } else {
        escaped.add(b);
      }
    }
    return escaped;
  }

  List<int> _decodeKISS(List<int> data) {
    final List<int> unescaped = [];
    // Pula o primeiro byte (Command Byte, geralmente 0x00 para Data)
    if (data.isEmpty) return [];
    for (int i = 1; i < data.length; i++) {
      if (data[i] == FESC && i + 1 < data.length) {
        if (data[i + 1] == TFEND) {
          unescaped.add(FEND);
          i++;
        } else if (data[i + 1] == TFESC) {
          unescaped.add(FESC);
          i++;
        }
      } else {
        unescaped.add(data[i]);
      }
    }
    return unescaped;
  }

  @override
  void setLocalId(String id) {}

  @override
  String? get localId => callsign;

  @override
  TransportHealth get health => TransportHealth(
        availability: _port != null && _port!.isOpened
            ? TransportAvailability.available
            : TransportAvailability.unavailable,
      );

  @override
  Future<void> broadcast(String message) async {
    await send(TransportPacket(
      type: SosPacketType.sos,
      senderId: callsign,
      recipientId: null,
      payload: {'msg': message},
    ));
  }

  @override
  Future<void> connect(String peerId) async {}

  @override
  Future<void> dispose() async {
    await _incomingController.close();
    _port?.close();
    _port = null;
  }
}
