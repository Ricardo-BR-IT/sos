import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'hardware_profile.dart';

Future<HardwareProfile> detectHardware(String? configPath) async {
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

bool _hasEthernetInterface(List<String> interfaces) =>
    _hasEthernetName(interfaces);

Future<List<String>> _detectInterfaces() async {
  try {
    final ifaces = await NetworkInterface.list();
    return ifaces.map((e) => e.name).toList();
  } catch (_) {
    return [];
  }
}

bool _hasEthernetName(List<String> names) {
  return names.any((name) {
    final lower = name.toLowerCase();
    return lower.contains('eth') ||
        lower.contains('en') ||
        lower.contains('ethernet') ||
        lower.contains('lan');
  });
}

List<String> _splitFlags(String value) {
  return value
      .split(RegExp(r'[,\s;]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

Future<String?> _resolveProfilePath(
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

Future<dynamic> _readJson(String path) async {
  try {
    final file = File(path);
    final content = await file.readAsString();
    return jsonDecode(content);
  } catch (_) {
    return null;
  }
}

void _applyJson(
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
        flags.addAll((map['flags'] as List).map((e) => e.toString()));
      }
    }
    if (map['transports'] != null) {
      if (map['transports'] is String) {
        transports.addAll(_splitFlags(map['transports'].toString()));
      } else if (map['transports'] is List) {
        transports.addAll((map['transports'] as List).map((e) => e.toString()));
      }
    }
    if (map['meta'] is Map<String, dynamic>) {
      meta.addAll(Map<String, dynamic>.from(map['meta']));
    }
  }
}
