import 'dart:async';
import 'package:sos_kernel/sos_kernel.dart';

/// Aggregator service for real-time situational awareness on the SOS V4 Dashboard.
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  static DashboardService get instance => _instance;

  DashboardService._internal();

  final HealthService _health = HealthService.instance;
  final EnvironmentalService _env = EnvironmentalService.instance;

  /// Unified stream of critical events for the dashboard notification feed.
  final _eventController = StreamController<DashboardEvent>.broadcast();
  Stream<DashboardEvent> get events => _eventController.stream;

  void initialize(MeshService mesh) {
    // Listen to health alerts
    _health.vitalsStream.listen((vitals) {
      if (vitals.spo2 < 92 || vitals.heartRate > 150) {
        _eventController.add(DashboardEvent(
          level: 'warning',
          source: 'Saúde',
          message: 'Sinais vitais alterados detected',
          vitals: vitals,
        ));
      }
    });

    // Listen to environmental hazards
    _env.dataStream.listen((data) {
      if (data.radiation > 0.3 || data.gasPpm > 30) {
        _eventController.add(DashboardEvent(
          level: 'critical',
          source: 'Ambiente',
          message: 'Risco ambiental detectado',
          envData: data,
        ));
      }
    });

    // Listen to mesh SOS
    mesh.messages.listen((envelope) {
      if (envelope.type == 'sos_alert') {
        _eventController.add(DashboardEvent(
          level: 'critical',
          source: 'Mesh SOS',
          message: envelope.payload['txt'] ?? 'Alerta SOS recebido',
          senderId: envelope.sender,
        ));
      }
    });
  }

  void dispose() {
    _eventController.close();
  }
}

class DashboardEvent {
  final String level; // info, warning, critical
  final String source;
  final String message;
  final String? senderId;
  final HealthVitals? vitals;
  final EnvironmentalData? envData;
  final DateTime timestamp;

  DashboardEvent({
    required this.level,
    required this.source,
    required this.message,
    this.senderId,
    this.vitals,
    this.envData,
  }) : timestamp = DateTime.now();
}
