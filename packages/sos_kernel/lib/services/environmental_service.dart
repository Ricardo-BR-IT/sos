import 'dart:async';
import 'package:sos_kernel/sos_kernel.dart';

/// Represents environmental sensor data.
class EnvironmentalData {
  final double radiation; // uSv/h
  final double gasPpm; // Combined or specific gas level
  final double seismicMagnitude;
  final DateTime timestamp;

  EnvironmentalData({
    required this.radiation,
    required this.gasPpm,
    required this.seismicMagnitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'rad': radiation,
        'gas': gasPpm,
        'seis': seismicMagnitude,
        'ts': timestamp.millisecondsSinceEpoch,
      };
}

/// Service to monitor environmental hazards and trigger automated SOS.
class EnvironmentalService {
  static final EnvironmentalService _instance =
      EnvironmentalService._internal();
  static EnvironmentalService get instance => _instance;

  EnvironmentalService._internal();

  final _dataController = StreamController<EnvironmentalData>.broadcast();
  Stream<EnvironmentalData> get dataStream => _dataController.stream;

  final TelemetryService _telemetry = TelemetryService.instance;
  MeshService? _meshService;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  /// Thresholds for automated SOS (Hazard levels)
  static const double kMaxRadiation = 0.5; // uSv/h (Safety limit for public)
  static const double kMaxGasPpm = 50.0; // CO safety threshold
  static const double kMinSeismicSos = 5.0; // Magnitude 5+ triggers SOS

  void initialize(MeshService meshService) {
    _meshService = meshService;
  }

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _telemetry.logEvent('env_monitor_start', data: {'safety_mode': true});
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _telemetry.logEvent('env_monitor_stop', data: {});
  }

  /// Processes new environmental data.
  void updateData(EnvironmentalData data) {
    if (!_isMonitoring) return;

    _dataController.add(data);
    _checkHazards(data);
  }

  void _checkHazards(EnvironmentalData data) {
    // 1. Radiation Check
    if (data.radiation > kMaxRadiation) {
      _triggerHazardSos(
          'ALERTA RADIOLÓGICO: Radiação detectada em ${data.radiation} uSv/h');
    }

    // 2. Gas Check
    if (data.gasPpm > kMaxGasPpm) {
      _triggerHazardSos(
          'ALERTA DE GÁS: Concentração perigosa em ${data.gasPpm} PPM');
    }

    // 3. Seismic Check
    if (data.seismicMagnitude > kMinSeismicSos) {
      _triggerHazardSos(
          'ALERTA SÍSMICO: Terremoto detectado - Magnitude ${data.seismicMagnitude}');
    }
  }

  void _triggerHazardSos(String message) {
    _telemetry
        .logEvent('env_hazard_sos', level: 'critical', data: {'msg': message});
    _meshService?.broadcastSos(message: '[AUTO-HAZARD] $message');
  }

  void dispose() {
    _dataController.close();
  }
}
