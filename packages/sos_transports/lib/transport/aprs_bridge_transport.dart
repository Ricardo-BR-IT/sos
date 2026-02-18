import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_layer.dart';
import 'transport_packet.dart';

enum AprsDataType {
  position,
  message,
  telemetry,
  emergency,
  status,
  unknown,
}

class AprsMessage {
  final String id;
  final String destination;
  final String text;

  AprsMessage({
    required this.id,
    required this.destination,
    required this.text,
  });
}

class AprsTelemetry {
  final int sequence;
  final List<int> values;
  final List<String> labels;

  AprsTelemetry({
    required this.sequence,
    required this.values,
    List<String>? labels,
  }) : labels = labels ?? const [];
}

class AprsStation {
  final String callsign;
  final String position;
  final String status;
  final DateTime timestamp;
  final List<String> path;

  AprsStation({
    required this.callsign,
    required this.position,
    required this.status,
    required this.timestamp,
    required this.path,
  });
}

class AprsPacket {
  final String source;
  final String destination;
  final List<String> path;
  final String rawData;
  final AprsDataType type;
  final String? position;
  final AprsMessage? message;
  final AprsTelemetry? telemetry;

  AprsPacket({
    required this.source,
    required this.destination,
    required this.path,
    required this.rawData,
    required this.type,
    this.position,
    this.message,
    this.telemetry,
  });

  static AprsPacket? parse(String input) {
    final raw = input.trim();
    if (raw.isEmpty || !raw.contains('>') || !raw.contains(':')) {
      return null;
    }

    final headerSplit = raw.split(':');
    if (headerSplit.length < 2) {
      return null;
    }

    final header = headerSplit.first;
    final data = headerSplit.sublist(1).join(':').trim();
    final sourceParts = header.split('>');
    if (sourceParts.length < 2) {
      return null;
    }

    final source = sourceParts[0].trim();
    if (source.isEmpty) {
      return null;
    }

    final routeParts = sourceParts[1].split(',');
    if (routeParts.isEmpty || routeParts.first.trim().isEmpty) {
      return null;
    }
    final destination = routeParts.first.trim();
    final path = routeParts.skip(1).map((e) => e.trim()).toList();

    if (data.isEmpty) {
      return null;
    }

    if (data.startsWith('!') || data.startsWith('=')) {
      final position = data.substring(1).trim();
      if (position.isEmpty) return null;
      return AprsPacket(
        source: source,
        destination: destination,
        path: path,
        rawData: data,
        type: AprsDataType.position,
        position: position,
      );
    }

    if (data.startsWith('T#')) {
      final parts = data.substring(2).split(',');
      if (parts.length >= 2) {
        final sequence = int.tryParse(parts.first.trim()) ?? 0;
        final values = parts
            .skip(1)
            .where((v) => v.trim().isNotEmpty)
            .map((v) => int.tryParse(v.trim()) ?? 0)
            .take(5)
            .toList();
        return AprsPacket(
          source: source,
          destination: destination,
          path: path,
          rawData: data,
          type: AprsDataType.telemetry,
          telemetry: AprsTelemetry(sequence: sequence, values: values),
        );
      }
    }

    final msgMatch = RegExp(r'^([A-Z0-9\-]{1,9})\s*:(.+)$').firstMatch(data);
    if (msgMatch != null) {
      final msgDestination = msgMatch.group(1)!.trim();
      final msgText = msgMatch.group(2)!.trim();
      return AprsPacket(
        source: source,
        destination: msgDestination,
        path: path,
        rawData: data,
        type: AprsDataType.message,
        message: AprsMessage(
          id: '${source}_${DateTime.now().millisecondsSinceEpoch}',
          destination: msgDestination,
          text: msgText,
        ),
      );
    }

    if (data.toUpperCase().contains('EMERGENCY:')) {
      return AprsPacket(
        source: source,
        destination: destination,
        path: path,
        rawData: data,
        type: AprsDataType.emergency,
      );
    }

    return AprsPacket(
      source: source,
      destination: destination,
      path: path,
      rawData: data,
      type: AprsDataType.status,
    );
  }
}

class AprsMessagePacket {
  final String source;
  final String destination;
  final String text;
  final List<String> path;

  AprsMessagePacket({
    required this.source,
    required this.destination,
    required this.text,
    this.path = const ['TCPIP*'],
  });

  String toAprsString() {
    return '$source>APRS,${path.join(',')}:${destination.padRight(9)}:$text';
  }
}

class AprsTelemetryPacket {
  final String source;
  final List<int> values;
  final int sequence;
  final List<String> path;

  AprsTelemetryPacket({
    required this.source,
    required this.values,
    this.sequence = 0,
    this.path = const ['TCPIP*'],
  });

  String toAprsString() {
    final seq = sequence.clamp(0, 999).toString().padLeft(3, '0');
    final data = values.take(5).map((v) => v.clamp(0, 999)).join(',');
    return '$source>APRS,${path.join(',')}:T#$seq,$data';
  }
}

class AprsEmergencyPacket {
  final String source;
  final String emergencyType;
  final String description;
  final List<String> path;

  AprsEmergencyPacket({
    required this.source,
    required this.emergencyType,
    required this.description,
    this.path = const ['TCPIP*'],
  });

  String toAprsString() {
    return '$source>APRS,${path.join(',')}:'
        'EMERGENCY: $emergencyType - $description';
  }
}

/// APRS Bridge Transport.
/// Supports APRS-IS (internet), TNC/KISS (radio), or hybrid mode.
class AprsBridgeTransport extends TransportLayer {
  final String _callsign;
  final String _passcode;
  final String _serverHost;
  final int _serverPort;
  final String _tncPath;
  final bool _useInternet;
  final bool _useRadio;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();
  final Map<String, AprsStation> _stations = {};

  Socket? _socket;
  StreamSubscription<String>? _socketSubscription;
  bool _internetReady = false;
  bool _radioReady = false;
  int _messageCount = 0;

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'aprs_bridge',
    name: 'HAM/APRS Bridge',
    technologyIds: ['ham_aprs', 'aprs_is', 'tnc', 'kiss'],
    mediums: ['radio', 'internet'],
    requiresGateway: true,
    notes:
        'Bridges APRS radio + APRS-IS for mesh escalation and emergency routing.',
  );

  AprsBridgeTransport({
    String callsign = 'NOCALL-0',
    String passcode = '-1',
    String serverHost = 'rotate.aprs2.net',
    int serverPort = 14580,
    String tncPath = '',
    bool useInternet = true,
    bool useRadio = false,
  })  : _callsign = callsign,
        _passcode = passcode,
        _serverHost = serverHost,
        _serverPort = serverPort,
        _tncPath = tncPath,
        _useInternet = useInternet,
        _useRadio = useRadio;

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

  Stream<TransportPacket> get packetStream => onPacketReceived;

  bool get isAvailable =>
      _health.availability == TransportAvailability.available ||
      _health.availability == TransportAvailability.degraded;

  @override
  Future<void> initialize() async {
    _health = _health.copyWith(availability: TransportAvailability.degraded);
    final errors = <String>[];

    if (_useInternet) {
      try {
        await _initializeInternetConnection();
      } catch (e) {
        errors.add('internet: $e');
      }
    }

    if (_useRadio) {
      try {
        await _initializeRadioConnection();
      } catch (e) {
        errors.add('radio: $e');
      }
    }

    // Mock mode for tests/offline simulation.
    if (!_useInternet && !_useRadio) {
      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
        lastError: null,
      );
      return;
    }

    if (_internetReady || _radioReady) {
      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
        lastError: errors.isEmpty ? null : errors.join('; '),
      );
      return;
    }

    _health = _health.copyWith(
      availability: TransportAvailability.unavailable,
      lastError: errors.join('; '),
      errorCount: _health.errorCount + 1,
    );
  }

  Future<void> _initializeInternetConnection() async {
    _socket = await Socket.connect(
      _serverHost,
      _serverPort,
      timeout: const Duration(seconds: 4),
    );
    _socket!.write('user $_callsign pass $_passcode vers SOS-APRS 1.0\r\n');
    _internetReady = true;

    _socketSubscription = _socket!
        .map((bytes) => utf8.decode(bytes))
        .transform(const LineSplitter())
        .listen(
      _handleIncomingAprsLine,
      onError: (Object e) {
        _internetReady = false;
        _health = _health.copyWith(
          availability: TransportAvailability.degraded,
          lastError: e.toString(),
          errorCount: _health.errorCount + 1,
        );
      },
      onDone: () {
        _internetReady = false;
      },
      cancelOnError: false,
    );
  }

  Future<void> _initializeRadioConnection() async {
    if (_tncPath.trim().isEmpty) {
      throw ArgumentError('tncPath is required when useRadio=true');
    }
    // Stub for TNC/KISS initialization.
    _radioReady = true;
  }

  void _handleIncomingAprsLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) return;
    _messageCount++;

    final parsed = AprsPacket.parse(line);
    if (parsed == null) return;

    if (parsed.position != null) {
      _stations[parsed.source] = AprsStation(
        callsign: parsed.source,
        position: parsed.position!,
        status: parsed.type.name.toUpperCase(),
        timestamp: DateTime.now(),
        path: parsed.path,
      );
    }

    final packetType =
        parsed.type == AprsDataType.emergency ? SosPacketType.sos : SosPacketType.data;
    _incomingController.add(TransportPacket(
      senderId: parsed.source,
      recipientId: null,
      type: packetType,
      payload: {
        'raw': line,
        'aprsType': parsed.type.name,
        'destination': parsed.destination,
        'position': parsed.position,
        'message': parsed.message?.text,
      },
      metadata: {
        'transport': descriptor.id,
        'path': parsed.path,
      },
    ));
  }

  @override
  Future<void> broadcast(String message) async {
    final src = _localId ?? _callsign;
    final raw = '$src>APRS,TCPIP*:>${message.trim()}';
    await _sendRaw(raw);
  }

  @override
  Future<void> send(TransportPacket packet) async {
    final destination = packet.recipientId ?? 'APRS';
    final text = packet.payload['message']?.toString() ??
        packet.payload['content']?.toString() ??
        jsonEncode(packet.payload);
    final aprsMessage = AprsMessagePacket(
      source: _localId ?? _callsign,
      destination: destination,
      text: text,
    );
    await _sendRaw(aprsMessage.toAprsString());
  }

  @override
  Future<void> connect(String peerId) async {
    // Connection is managed by APRS infrastructure.
  }

  Future<void> sendPosition(double lat, double lon, {String? comment}) async {
    final payload = '!${formatLatitude(lat)}/${formatLongitude(lon)}'
        '_${comment ?? 'SOS Mesh Node'}';
    final raw = '${_localId ?? _callsign}>APRS,TCPIP*:$payload';
    await _sendRaw(raw);
  }

  Future<void> sendTelemetry(List<int> values, List<String> labels) async {
    final packet = AprsTelemetryPacket(
      source: _localId ?? _callsign,
      values: values,
    );
    await _sendRaw(packet.toAprsString());
  }

  Future<void> sendEmergencyAlert(String type, String description) async {
    final packet = AprsEmergencyPacket(
      source: _localId ?? _callsign,
      emergencyType: type,
      description: description,
    );
    await _sendRaw(packet.toAprsString());
  }

  Future<void> _sendRaw(String raw) async {
    _messageCount++;
    if (_internetReady && _socket != null) {
      _socket!.write('$raw\r\n');
    }
    if (_radioReady) {
      // Stub for KISS/TNC TX.
    }
    _health = _health.copyWith(
      availability: TransportAvailability.available,
      lastOkAt: DateTime.now(),
      lastError: null,
    );
  }

  Map<String, dynamic> getAprsStatus() {
    return {
      'callsign': _callsign,
      'useInternet': _useInternet,
      'useRadio': _useRadio,
      'internetReady': _internetReady,
      'radioReady': _radioReady,
      'stations': _stations.length,
      'messages': _messageCount,
      'stationsList': _stations.values
          .map((s) => {
                'callsign': s.callsign,
                'position': s.position,
                'status': s.status,
                'timestamp': s.timestamp.toIso8601String(),
              })
          .toList(),
    };
  }

  @visibleForTesting
  String formatLatitude(double lat) {
    final absLat = lat.abs();
    final deg = absLat.floor();
    final min = (absLat - deg) * 60;
    final dir = lat >= 0 ? 'N' : 'S';
    return '${deg.toString().padLeft(2, '0')}${min.toStringAsFixed(2)}$dir';
  }

  @visibleForTesting
  String formatLongitude(double lon) {
    final absLon = lon.abs();
    final deg = absLon.floor();
    final min = (absLon - deg) * 60;
    final dir = lon >= 0 ? 'E' : 'W';
    return '${deg.toString().padLeft(3, '0')}${min.toStringAsFixed(2)}$dir';
  }

  @override
  Future<void> dispose() async {
    await _socketSubscription?.cancel();
    _socket?.destroy();
    await _incomingController.close();
  }
}
