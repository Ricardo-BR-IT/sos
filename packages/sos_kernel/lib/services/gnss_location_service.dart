import 'dart:async';

/// GPS/GNSS Location Service.
/// Provides location data to SOS packets via multiple satellite constellations.
class GnssLocationService {
  final StreamController<GnssPosition> _positionController =
      StreamController<GnssPosition>.broadcast();

  Timer? _updateTimer;
  GnssPosition? _lastPosition;
  bool _isTracking = false;

  /// Current position stream
  Stream<GnssPosition> get positionStream => _positionController.stream;

  /// Last known position
  GnssPosition? get lastPosition => _lastPosition;

  /// Whether location tracking is active
  bool get isTracking => _isTracking;

  /// Start continuous location tracking
  Future<void> startTracking(
      {Duration interval = const Duration(seconds: 10)}) async {
    if (_isTracking) return;
    _isTracking = true;

    // Request initial position
    await _requestPosition();

    // Set up periodic updates
    _updateTimer = Timer.periodic(interval, (_) => _requestPosition());
  }

  /// Stop location tracking
  void stopTracking() {
    _isTracking = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<void> _requestPosition() async {
    try {
      // In real implementation, use platform-specific location APIs:
      // - Android: FusedLocationProvider
      // - iOS: CLLocationManager
      // - Desktop: gpsd or platform APIs

      // For now, simulate position updates
      final position = await _getPlatformPosition();
      if (position != null) {
        _lastPosition = position;
        _positionController.add(position);
      }
    } catch (e) {
      // Handle location errors silently
    }
  }

  Future<GnssPosition?> _getPlatformPosition() async {
    // Placeholder - in real implementation, would call native APIs
    // geolocator package for Flutter
    return null;
  }

  /// Get single position fix
  Future<GnssPosition?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 30),
    GnssAccuracy accuracy = GnssAccuracy.high,
  }) async {
    // Request high-accuracy position fix
    return _getPlatformPosition();
  }

  /// Calculate distance between two positions in meters
  static double distanceBetween(GnssPosition a, GnssPosition b) {
    // Haversine formula
    const double earthRadius = 6371000; // meters

    final lat1 = a.latitude * (3.14159265359 / 180);
    final lat2 = b.latitude * (3.14159265359 / 180);
    final deltaLat = (b.latitude - a.latitude) * (3.14159265359 / 180);
    final deltaLon = (b.longitude - a.longitude) * (3.14159265359 / 180);

    final sinDeltaLat = _sin(deltaLat / 2);
    final sinDeltaLon = _sin(deltaLon / 2);

    final aVal = sinDeltaLat * sinDeltaLat +
        _cos(lat1) * _cos(lat2) * sinDeltaLon * sinDeltaLon;
    final c = 2 * _atan2(_sqrt(aVal), _sqrt(1 - aVal));

    return earthRadius * c;
  }

  static double _sin(double x) =>
      x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  static double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0; // undefined
  }

  static double _atan(double x) =>
      x - (x * x * x) / 3 + (x * x * x * x * x) / 5;

  Future<void> dispose() async {
    stopTracking();
    await _positionController.close();
  }
}

/// Position data from GNSS
class GnssPosition {
  final double latitude;
  final double longitude;
  final double? altitude; // meters above sea level
  final double? accuracy; // horizontal accuracy in meters
  final double? speed; // m/s
  final double? heading; // degrees from north
  final DateTime timestamp;
  final GnssSource source;

  const GnssPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
    this.source = GnssSource.unknown,
  });

  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lon': longitude,
        if (altitude != null) 'alt': altitude,
        if (accuracy != null) 'acc': accuracy,
        if (speed != null) 'spd': speed,
        if (heading != null) 'hdg': heading,
        'ts': timestamp.millisecondsSinceEpoch,
        'src': source.name,
      };

  factory GnssPosition.fromMap(Map<String, dynamic> map) => GnssPosition(
        latitude: (map['lat'] as num).toDouble(),
        longitude: (map['lon'] as num).toDouble(),
        altitude: (map['alt'] as num?)?.toDouble(),
        accuracy: (map['acc'] as num?)?.toDouble(),
        speed: (map['spd'] as num?)?.toDouble(),
        heading: (map['hdg'] as num?)?.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['ts'] as int),
        source: GnssSource.values.firstWhere(
          (s) => s.name == map['src'],
          orElse: () => GnssSource.unknown,
        ),
      );
}

/// GNSS constellation source
enum GnssSource {
  gps, // USA
  glonass, // Russia
  galileo, // Europe
  beidou, // China
  navic, // India
  qzss, // Japan
  sbas, // Augmentation
  mixed, // Multiple
  unknown,
}

/// Accuracy level for position requests
enum GnssAccuracy {
  low, // ~1km, minimal power
  medium, // ~100m, balanced
  high, // ~10m, more power
  best, // ~1m, maximum power
}
