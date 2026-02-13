import 'package:sos_transports/sos_transports.dart';

import 'hardware_detect_interface.dart'
    if (dart.library.io) 'hardware_detect_io.dart'
    if (dart.library.html) 'hardware_detect_web.dart';

class HardwareProfile {
  final List<String> flags;
  final List<String> transports;
  final List<String> interfaces;
  final List<String> sources;
  final Map<String, dynamic> meta;

  const HardwareProfile({
    required this.flags,
    required this.transports,
    required this.interfaces,
    required this.sources,
    required this.meta,
  });

  TransportActivation get activation {
    final lowerFlags = flags.map((f) => f.toLowerCase()).toSet();
    final lowerTransports = transports.map((t) => t.toLowerCase()).toSet();

    bool enabled(String key) =>
        lowerFlags.contains(key) || lowerTransports.contains(key);

    return TransportActivation(
      bluetoothClassic: enabled('bluetoothclassic') ||
          enabled('bluetooth_classic') ||
          enabled('btclassic') ||
          enabled('classic'),
      bluetoothMesh: enabled('bluetoothmesh') ||
          enabled('bluetooth_mesh') ||
          enabled('btmesh') ||
          enabled('mesh'),
      ethernet:
          enabled('ethernet') || enabled('lan') || enabled('eth'), // simplified
      acoustic: enabled('acoustic'),
      optical: enabled('optical') || enabled('lifi'),
      lorawan: enabled('lorawan') || enabled('lora'),
      satD2d: enabled('satd2d') || enabled('sat_d2d') || enabled('satellite'),
      mqtt: enabled('mqtt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flags': flags,
      'transports': transports,
      'interfaces': interfaces,
      'sources': sources,
      'meta': meta,
    };
  }

  static Future<HardwareProfile> detect({String? configPath}) {
    return detectHardware(configPath);
  }

  static HardwareProfile fromJson(Map<String, dynamic> json) {
    return HardwareProfile(
      flags: _normalizeList(json['flags']),
      transports: _normalizeList(json['transports']),
      interfaces: _normalizeList(json['interfaces']),
      sources: _normalizeList(json['sources']),
      meta: json['meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['meta'])
          : <String, dynamic>{},
    );
  }

  static List<String> _normalizeList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      // Basic split
      return value
          .split(RegExp(r'[,\s;]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }
}
