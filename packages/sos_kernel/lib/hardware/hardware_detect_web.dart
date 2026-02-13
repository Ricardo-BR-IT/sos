import 'hardware_profile.dart';

Future<HardwareProfile> detectHardware(String? configPath) async {
  // Web implementation: Mock or minimal
  return const HardwareProfile(
    flags: ['web'],
    transports: ['websocket', 'webrtc'],
    interfaces: ['browser'],
    sources: ['web_runtime'],
    meta: {'platform': 'web'},
  );
}
