import 'dart:async';
import 'package:sos_kernel/sos_kernel.dart';

/// Represents the vital signs of a user.
class HealthVitals {
  final int heartRate;
  final int spo2;
  final double temperature;
  final bool isMoving;
  final DateTime timestamp;

  HealthVitals({
    required this.heartRate,
    required this.spo2,
    this.temperature = 36.5,
    this.isMoving = true,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'hr': heartRate,
        'spo2': spo2,
        'temp': temperature,
        'moving': isMoving,
        'ts': timestamp.millisecondsSinceEpoch,
      };
}

/// Service to monitor biometric data and trigger automated SOS.
class HealthService {
  static final HealthService _instance = HealthService._internal();
  static HealthService get instance => _instance;

  HealthService._internal();

  final _vitalsController = StreamController<HealthVitals>.broadcast();
  Stream<HealthVitals> get vitalsStream => _vitalsController.stream;

  final TelemetryService _telemetry = TelemetryService.instance;
  MeshService? _meshService;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  /// Thresholds for automated SOS
  static const int kMinSpo2 = 90;
  static const int kMinHeartRate = 40;
  static const int kMaxHeartRate = 180;
  static const Duration kHypoxiaDuration = Duration(seconds: 30);

  DateTime? _hypoxiaStartTime;

  void initialize(MeshService meshService) {
    _meshService = meshService;
  }

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _telemetry.logEvent('health_monitor_start', data: {'auto_sos': true});
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _telemetry.logEvent('health_monitor_stop', data: {});
  }

  /// Processes new vital signs and checks for anomalies.
  void updateVitals(HealthVitals vitals) {
    if (!_isMonitoring) return;

    _vitalsController.add(vitals);
    _checkAnomalies(vitals);
  }

  void _checkAnomalies(HealthVitals vitals) {
    // 1. Hypoxia Detection (SpO2 < 90%)
    if (vitals.spo2 < kMinSpo2) {
      _hypoxiaStartTime ??= DateTime.now();
      final duration = DateTime.now().difference(_hypoxiaStartTime!);
      if (duration >= kHypoxiaDuration) {
        _triggerAutomatedSos(
            'ALERTA DE HIPÓXIA: SpO2 em ${vitals.spo2}% por ${duration.inSeconds}s');
        _hypoxiaStartTime = null; // Reset to avoid spamming
      }
    } else {
      _hypoxiaStartTime = null;
    }

    // 2. Critical Heart Rate
    if (vitals.heartRate < kMinHeartRate || vitals.heartRate > kMaxHeartRate) {
      _triggerAutomatedSos(
          'ALERTA CARDÍACO: Batimentos em ${vitals.heartRate} bpm');
    }

    // 3. Fall Detection (Basic: sudden impact + no movement - simplified for now)
    // Real fall detection would use accelerometer data directly.
    if (!vitals.isMoving && vitals.heartRate > 120) {
      _triggerAutomatedSos(
          'ALERTA DE QUEDA: Impacto detectado e usuário imóvel');
    }
  }

  void _triggerAutomatedSos(String message) {
    _telemetry
        .logEvent('health_auto_sos', level: 'critical', data: {'msg': message});
    _meshService?.broadcastSos(message: '[AUTO-HEALTH] $message');
  }

  void dispose() {
    _vitalsController.close();
  }
}
