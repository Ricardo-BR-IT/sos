/// MAVLink-like protocol for mesh-enabled robotics (Drones/UGVs).
class RoboticsProtocol {
  static const String topicTelemetry = 'drone_tlm';
  static const String topicCommand = 'drone_cmd';

  /// Packet Types
  static const int typeTelemetry = 0x01;
  static const int typeCommand = 0x02;
  static const int typeMission = 0x03;

  /// Internal Commands
  static const int cmdTakeoff = 0x10;
  static const int cmdLand = 0x11;
  static const int cmdGoTo = 0x12;
  static const int cmdReturnHome = 0x13;

  static Map<String, dynamic> createTelemetry({
    required double lat,
    required double lon,
    required double alt,
    required int batteryPercent,
    required String status,
  }) {
    return {
      'type': typeTelemetry,
      'lat': lat,
      'lon': lon,
      'alt': alt,
      'bat': batteryPercent,
      'st': status,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> createCommand({
    required int commandId,
    Map<String, dynamic>? params,
  }) {
    return {
      'type': typeCommand,
      'cmd': commandId,
      'p': params ?? {},
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

class DroneTelemetry {
  final String droneId;
  final double latitude;
  final double longitude;
  final double altitude;
  final int battery;
  final String status;
  final DateTime timestamp;

  DroneTelemetry({
    required this.droneId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.battery,
    required this.status,
    required this.timestamp,
  });

  factory DroneTelemetry.fromJson(String senderId, Map<String, dynamic> json) {
    return DroneTelemetry(
      droneId: senderId,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      altitude: (json['alt'] as num).toDouble(),
      battery: json['bat'] as int,
      status: json['st'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
    );
  }
}
