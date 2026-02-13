import 'dart:math';

export 'telemetry_domain.dart';

class TelemetryService {
  TelemetryService._internal() : _sessionId = _generateSessionId();

  static final TelemetryService instance = TelemetryService._internal();

  final String _sessionId;
  bool _ready = false;

  bool get isReady => _ready;
  String get sessionId => _sessionId;

  Future<void> initialize({
    required String app,
    required String edition,
    String? nodeId,
    Uri? endpoint,
    int retentionDays = 7,
  }) async {
    _ready = true;
    print(
        'TelemetryService (Web) Initialized: $app $edition $nodeId $endpoint');
  }

  void setNodeId(String? nodeId) {
    if (nodeId == null || nodeId.isEmpty) return;
  }

  void setEndpoint(Uri? endpoint) {}

  Future<void> logEvent(
    String event, {
    String level = 'info',
    Map<String, dynamic>? data,
  }) async {
    if (!_ready) return;
    // Web implementation: just print to console for now
    print('[Telemetry] $level: $event $data');
  }

  Future<void> exportLocalTelemetry(String targetPath) async {
    // Not supported on web yet
    print('Export telemetry not supported on web');
  }

  static String _generateSessionId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(1 << 32);
    return 'sos-$now-$rand';
  }
}
