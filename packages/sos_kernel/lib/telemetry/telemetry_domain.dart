class TelemetryEvent {
  final String event;
  final String level;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  TelemetryEvent({
    required this.event,
    required this.level,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson({
    required String app,
    required String edition,
    required String sessionId,
    String? nodeId,
    String? platform,
  }) {
    return {
      'schema': 1,
      'ts': timestamp.toUtc().toIso8601String(),
      'event': event,
      'level': level,
      'app': app,
      'edition': edition,
      'sessionId': sessionId,
      'nodeId': nodeId,
      'platform': platform ?? 'unknown',
      'data': data,
    };
  }
}
