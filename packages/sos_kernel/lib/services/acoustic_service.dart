import 'dart:async';

/// Acoustic Services Layer.
/// Voice communication, ultrasound, haptic feedback.
class AcousticService {
  Future<void> initialize() async {}

  Future<void> dispose() async {}
}

class HapticPulse {
  final bool isVibration;
  final Duration duration;

  HapticPulse.vibrate(this.duration) : isVibration = true;
  HapticPulse.pause(this.duration) : isVibration = false;
}
