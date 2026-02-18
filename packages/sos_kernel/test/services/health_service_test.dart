import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sos_kernel/sos_kernel.dart';

class TestMeshService extends Mock implements MeshService {
  final List<String> sosMessages = [];

  @override
  Future<void> broadcastSos({required String message}) async {
    sosMessages.add(message);
  }
}

void main() {
  late HealthService healthService;
  late TestMeshService mockMesh;

  setUp(() {
    healthService = HealthService.instance;
    mockMesh = TestMeshService();
    healthService.initialize(mockMesh);
    healthService.startMonitoring();
  });

  tearDown(() {
    healthService.stopMonitoring();
  });

  group('HealthService Automated SOS Tests', () {
    test(
        'Hypoxia (SpO2 < 90%) triggers SOS after sustained duration',
        timeout: const Timeout(Duration(seconds: 45)),
        () async {
      final now = DateTime.now();

      // Step 1: Send low SpO2
      healthService.updateVitals(HealthVitals(
        heartRate: 70,
        spo2: 85, // Hypoxia
        timestamp: now,
      ));

      // Should NOT trigger immediately
      expect(mockMesh.sosMessages, isEmpty);

      // Step 2: Sustainable hypoxia (simulating time passage)
      // Note: In a real test we might use fake_async, but here we manually trigger at a later timestamp if the logic allows,
      // or we just wait if the logic uses DateTime.now() directly.
      // Looking at the implementation, it uses DateTime.now().

      // We will wait 31 seconds.
      await Future.delayed(const Duration(seconds: 31));

      healthService.updateVitals(HealthVitals(
        heartRate: 70,
        spo2: 85,
        timestamp: DateTime.now(),
      ));

      expect(mockMesh.sosMessages.length, equals(1));
      expect(mockMesh.sosMessages.first, contains('HIPÓXIA'));
    });

    test('Critical Heart Rate triggers SOS immediately', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 200, // Tachycardia
        spo2: 98,
        timestamp: DateTime.now(),
      ));

      expect(mockMesh.sosMessages.length, equals(1));
      expect(mockMesh.sosMessages.first, contains('CARDÍACO'));
    });

    test('Fall detection triggers SOS', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 130, // High stress
        spo2: 98,
        isMoving: false, // Impact + No movement
        timestamp: DateTime.now(),
      ));

      expect(mockMesh.sosMessages.length, equals(1));
      expect(mockMesh.sosMessages.first, contains('QUEDA'));
    });
  });
  group('Regression Tests', () {
    test('Normal vitals do NOT trigger SOS', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 70,
        spo2: 98,
        timestamp: DateTime.now(),
      ));

      expect(mockMesh.sosMessages, isEmpty);
    });
  });
}
