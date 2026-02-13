import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sos_transports/sos_transports.dart';

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
      ethernet: enabled('ethernet') ||
          enabled('lan') ||
          _hasEthernetInterface(),
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

  static Future<HardwareProfile> detect({String? configPath}) async {
    final sources = <String>[];
    final flags = <String>{};
    final transports = <String>{};
    final interfaces = <String>[];
    final meta = <String, dynamic>{};

    interfaces.addAll(await _detectInterfaces());
    if (interfaces.isNotEmpty) {
      sources.add('auto');
    }

    final envFlags = Platform.environment['SOS_HARDWARE_FLAGS'];
    if (envFlags != null && envFlags.trim().isNotEmpty) {
      flags.addAll(_splitFlags(envFlags));
      sources.add('env_flags');
    }

    final envProfile = Platform.environment['SOS_HARDWARE_PROFILE'];
    final resolvedPath = await _resolveProfilePath(
      configPath,
      envProfile,
    );
    if (resolvedPath != null) {
      final data = await _readJson(resolvedPath);
      if (data != null) {
        _applyJson(data, flags, transports, meta);
        sources.add('file');
      }
    }

    if (_hasEthernetName(interfaces)) {
      flags.add('ethernet');
    }

    return HardwareProfile(
      flags: flags.toList()..sort(),
      transports: transports.toList()..sort(),
      interfaces: interfaces,
      sources: sources.toList(),
      meta: meta,
    );
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

  bool _hasEthernetInterface() => _hasEthernetName(interfaces);

  static Future<List<String>> _detectInterfaces() async {
    try {
      final ifaces = await NetworkInterface.list();
      return ifaces.map((e) => e.name).toList();
    } catch (_) {
      return [];
    }
  }

  static bool _hasEthernetName(List<String> names) {
    return names.any((name) {
      final lower = name.toLowerCase();
      return lower.contains('eth') ||
          lower.contains('en') ||
          lower.contains('ethernet') ||
          lower.contains('lan');
    });
  }

  static List<String> _splitFlags(String value) {
    return value
        .split(RegExp(r'[,\s;]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static Future<String?> _resolveProfilePath(
    String? configPath,
    String? envPath,
  ) async {
    final candidates = <String>[];
    if (configPath != null && configPath.trim().isNotEmpty) {
      candidates.add(configPath.trim());
    }
    if (envPath != null && envPath.trim().isNotEmpty) {
      candidates.add(envPath.trim());
    }
    candidates.addAll([
      'hardware_profile.json',
      'sos_hardware_profile.json',
    ]);
    try {
      final docs = await getApplicationDocumentsDirectory();
      candidates.add(p.join(docs.path, 'sos_hardware_profile.json'));
      candidates.add(p.join(docs.path, 'hardware_profile.json'));
    } catch (_) {}

    for (final path in candidates) {
      final file = File(path);
      if (await file.exists()) {
        return file.path;
      }
    }
    return null;
  }

  static Future<dynamic> _readJson(String path) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  static void _applyJson(
    dynamic data,
    Set<String> flags,
    Set<String> transports,
    Map<String, dynamic> meta,
  ) {
    if (data is List) {
      flags.addAll(data.map((e) => e.toString()));
      return;
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['flags'] != null) {
        if (map['flags'] is String) {
          flags.addAll(_splitFlags(map['flags'].toString()));
        } else if (map['flags'] is List) {
          flags.addAll(
              (map['flags'] as List).map((e) => e.toString()));
        }
      }
      if (map['transports'] != null) {
        if (map['transports'] is String) {
          transports.addAll(_splitFlags(map['transports'].toString()));
        } else if (map['transports'] is List) {
          transports.addAll(
              (map['transports'] as List).map((e) => e.toString()));
        }
      }
      if (map['meta'] is Map<String, dynamic>) {
        meta.addAll(Map<String, dynamic>.from(map['meta']));
      }
    }
  }

  static List<String> _normalizeList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return _splitFlags(value);
    }
    return [];
  }
}
