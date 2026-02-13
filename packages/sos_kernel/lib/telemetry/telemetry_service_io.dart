import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'telemetry_domain.dart';

export 'telemetry_domain.dart';

class TelemetryService {
  TelemetryService._internal() : _sessionId = _generateSessionId();

  static final TelemetryService instance = TelemetryService._internal();

  final String _sessionId;
  bool _ready = false;
  String? _app;
  String? _edition;
  String? _nodeId;
  Uri? _endpoint;
  int _retentionDays = 7;
  Directory? _baseDir;
  final List<Map<String, dynamic>> _queue = [];
  bool _flushing = false;

  bool get isReady => _ready;
  String get sessionId => _sessionId;

  Future<void> initialize({
    required String app,
    required String edition,
    String? nodeId,
    Uri? endpoint,
    int retentionDays = 7,
  }) async {
    _app = app;
    _edition = edition;
    _nodeId = nodeId;
    _endpoint = endpoint;
    _retentionDays = retentionDays.clamp(1, 365);

    try {
      final root = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(root.path, 'sos_telemetry'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _baseDir = dir;
      await _purgeOldFiles();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  void setNodeId(String? nodeId) {
    if (nodeId == null || nodeId.isEmpty) return;
    _nodeId = nodeId;
  }

  void setEndpoint(Uri? endpoint) {
    _endpoint = endpoint;
  }

  Future<void> logEvent(
    String event, {
    String level = 'info',
    Map<String, dynamic>? data,
  }) async {
    if (!_ready || _app == null || _edition == null) return;
    final entry = TelemetryEvent(
      event: event,
      level: level,
      timestamp: DateTime.now(),
      data: data ?? const {},
    ).toJson(
      app: _app!,
      edition: _edition!,
      sessionId: _sessionId,
      nodeId: _nodeId,
      platform: Platform.operatingSystem,
    );

    await _append(entry);
    if (_endpoint != null) {
      _queue.add(entry);
      _flush();
    }
  }

  Future<void> exportLocalTelemetry(String targetPath) async {
    if (_baseDir == null) return;
    final targetFile = File(targetPath);
    final sink = targetFile.openWrite();

    final files = _baseDir!
        .listSync()
        .whereType<File>()
        .where((file) => file.path.contains('telemetry-'))
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      await sink.addStream(file.openRead());
    }

    await sink.close();
  }

  Future<void> _append(Map<String, dynamic> payload) async {
    if (_baseDir == null) return;
    final now = DateTime.now().toUtc();
    final filename = _fileNameFor(now);
    final file = File(p.join(_baseDir!.path, filename));
    await file.writeAsString('${jsonEncode(payload)}\n', mode: FileMode.append);
  }

  void _flush() {
    if (_flushing || _endpoint == null) return;
    _flushing = true;
    _sendQueue().whenComplete(() => _flushing = false);
  }

  Future<void> _sendQueue() async {
    if (_endpoint == null) return;
    while (_queue.isNotEmpty) {
      final batchSize = _queue.length > 50 ? 50 : _queue.length;
      final batch = _queue.sublist(0, batchSize);
      final ok = await _sendBatch(batch);
      if (!ok) {
        return;
      }
      _queue.removeRange(0, batchSize);
    }
  }

  Future<bool> _sendBatch(List<Map<String, dynamic>> batch) async {
    if (_endpoint == null) return false;
    try {
      final client = HttpClient();
      final request = await client.postUrl(_endpoint!);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(batch)));
      final response = await request.close();
      await response.drain();
      client.close();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<void> _purgeOldFiles() async {
    if (_baseDir == null) return;
    final threshold =
        DateTime.now().toUtc().subtract(Duration(days: _retentionDays));
    final files = _baseDir!
        .listSync()
        .whereType<File>()
        .where((file) => file.path.contains('telemetry-'));
    for (final file in files) {
      final name = p.basename(file.path);
      final date = _dateFromFile(name);
      if (date == null) continue;
      if (date.isBefore(
          DateTime.utc(threshold.year, threshold.month, threshold.day))) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  static String _fileNameFor(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return 'telemetry-$yyyy$mm$dd.jsonl';
  }

  static DateTime? _dateFromFile(String filename) {
    final match =
        RegExp(r'telemetry-(\d{4})(\d{2})(\d{2})\.jsonl').firstMatch(filename);
    if (match == null) return null;
    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  static String _generateSessionId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(1 << 32);
    return 'sos-$now-$rand';
  }
}
