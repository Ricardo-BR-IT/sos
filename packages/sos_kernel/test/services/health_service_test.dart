import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_kernel/services/health_service.dart';

// Mock classes
class MockMeshService extends Mock implements MeshService {
  @override
  Future<void> broadcastSos({required String message}) => super.noSuchMethod(
        Invocation.method(#broadcastSos, [], {#message: message}),
        returnValue: Future.value(),
      );
}

class MockTelemetryService extends Mock implements TelemetryService {
  @override
  Future<void> logEvent(String event,
          {String level = 'info', Map<String, dynamic>? data}) =>
      super.noSuchMethod(
        Invocation.method(#logEvent, [event], {#level: level, #data: data}),
        returnValue: Future.value(),
      );
}

void main() {
  late HealthService healthService;
  late MockMeshService mockMesh;

  setUp(() {
    healthService = HealthService.instance;
    mockMesh = MockMeshService();
    healthService.initialize(mockMesh);
    healthService.startMonitoring();
  });

  tearDown(() {
    healthService.stopMonitoring();
  });

  group('HealthService Automated SOS Tests', () {
    test('Hypoxia (SpO2 < 90%) triggers SOS after sustained duration',
        () async {
      final now = DateTime.now();

      // Step 1: Send low SpO2
      healthService.updateVitals(HealthVitals(
        heartRate: 70,
        spo2: 85, // Hypoxia
        timestamp: now,
      ));

      // Should NOT trigger immediately
      verifyNever(mockMesh.broadcastSos(message: anyNamed('message') ?? ''));

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

      verify(mockMesh.broadcastSos(message: argThat(contains('HIPÓXIA')) ?? ''))
          .called(1);
    });

    test('Critical Heart Rate triggers SOS immediately', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 200, // Tachycardia
        spo2: 98,
        timestamp: DateTime.now(),
      ));

      verify(mockMesh.broadcastSos(
              message: argThat(contains('CARDÍACO')) ?? ''))
          .called(1);
    });

    test('Fall detection triggers SOS', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 130, // High stress
        spo2: 98,
        isMoving: false, // Impact + No movement
        timestamp: DateTime.now(),
      ));

      verify(mockMesh.broadcastSos(message: argThat(contains('QUEDA')) ?? ''))
          .called(1);
    });
  });
  group('Regression Tests', () {
    test('Normal vitals do NOT trigger SOS', () {
      healthService.updateVitals(HealthVitals(
        heartRate: 70,
        spo2: 98,
        timestamp: DateTime.now(),
      ));

      verifyNever(mockMesh.broadcastSos(message: anyNamed('message') ?? ''));
    });
  });
}
