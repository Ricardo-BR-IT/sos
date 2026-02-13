import 'package:flutter_test/flutter_test.dart';
import 'package:sos_kernel/identity/crypto_manager.dart';

void main() {
  group('CryptoManager Security Tests', () {
    late CryptoManager cryptoManager;

    setUp(() {
      cryptoManager = CryptoManager();
    });

    test('should initialize with expected state', () {
      expect(cryptoManager.isInitialized, false);
      expect(cryptoManager.publicKeyBase64, '');
      expect(cryptoManager.auditLog, isA<List<SecurityAuditEntry>>());
    });

    test('should create identity backup with integrity', () {
      final backup = IdentityBackup.create('seed123', 'pubkey456');
      expect(backup.seedBase64, 'seed123');
      expect(backup.publicKeyBase64, 'pubkey456');
      expect(backup.createdAt, isA<int>());
      expect(backup.checksum, isA<String>());
      expect(backup.verifyIntegrity(), true);
    });

    test('should detect tampered backup', () {
      final backup = IdentityBackup.create('seed123', 'pubkey456');
      // Tamper with the data
      final tamperedBackup = IdentityBackup(
        seedBase64: 'tampered-seed',
        publicKeyBase64: backup.publicKeyBase64,
        createdAt: backup.createdAt,
        checksum: backup.checksum,
      );
      expect(tamperedBackup.verifyIntegrity(), false);
    });

    test('should create backup from JSON correctly', () {
      final backup = IdentityBackup.create('seed123', 'pubkey456');
      final json = backup.toJson();
      final restored = IdentityBackup.fromJson(json);

      expect(restored.seedBase64, backup.seedBase64);
      expect(restored.publicKeyBase64, backup.publicKeyBase64);
      expect(restored.createdAt, backup.createdAt);
      expect(restored.checksum, backup.checksum);
      expect(restored.verifyIntegrity(), true);
    });

    test('should have security audit entry structure', () {
      final entry = SecurityAuditEntry(
        timestamp: DateTime.now(),
        action: 'test_action',
        details: 'test details',
        success: true,
      );

      expect(entry.action, 'test_action');
      expect(entry.details, 'test details');
      expect(entry.success, true);
      expect(entry.timestamp, isA<DateTime>());

      final json = entry.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['action'], 'test_action');
    });

    // Note: Full integration tests with Sodium and FlutterSecureStorage
    // would require complex mocking and are beyond basic unit tests
  });
}
