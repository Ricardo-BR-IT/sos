/// crypto_manager.dart
/// PRODUCTION IMPLEMENTATION
/// Uses libsodium for Ed25519 (Signing) and secure storage for persistence.
/// Enhanced with key rotation, backup/restore, and security audit.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:crypto/crypto.dart';

/// Security audit log entry
class SecurityAuditEntry {
  final DateTime timestamp;
  final String action;
  final String? details;
  final bool success;

  SecurityAuditEntry({
    required this.timestamp,
    required this.action,
    this.details,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toUtc().toIso8601String(),
        'action': action,
        'details': details,
        'success': success,
      };
}

/// Backup data structure for identity
class IdentityBackup {
  final String seedBase64;
  final String publicKeyBase64;
  final int createdAt;
  final String checksum;

  IdentityBackup({
    required this.seedBase64,
    required this.publicKeyBase64,
    required this.createdAt,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'seed': seedBase64,
        'publicKey': publicKeyBase64,
        'createdAt': createdAt,
        'checksum': checksum,
      };

  static IdentityBackup fromJson(Map<String, dynamic> json) {
    return IdentityBackup(
      seedBase64: json['seed'] as String,
      publicKeyBase64: json['publicKey'] as String,
      createdAt: json['createdAt'] as int,
      checksum: json['checksum'] as String,
    );
  }

  /// Verify backup integrity
  bool verifyIntegrity() {
    final computed = _computeChecksum(seedBase64, publicKeyBase64, createdAt);
    return computed == checksum;
  }

  static String _computeChecksum(String seed, String pk, int timestamp) {
    final data = '$seed|$pk|$timestamp';
    return sha256.convert(utf8.encode(data)).toString();
  }

  static IdentityBackup create(String seed, String publicKey) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final checksum = _computeChecksum(seed, publicKey, now);
    return IdentityBackup(
      seedBase64: seed,
      publicKeyBase64: publicKey,
      createdAt: now,
      checksum: checksum,
    );
  }
}

class CryptoManager {
  static const _storage = FlutterSecureStorage();
  static const _seedKey = 'user_seed';
  static const _seedChecksumKey = 'user_seed_checksum';
  static const _backupKey = 'identity_backup';
  static const _auditLogKey = 'security_audit_log';
  static const _keyRotationDateKey = 'key_rotation_date';
  static const _maxAuditEntries = 100;

  // Key rotation period: 90 days
  static const _keyRotationPeriodDays = 90;

  // Encryption passphrase for backups
  static const _backupPassphrase = 'sos_identity_backup_encryption_key';

  Sodium? _sodium;
  KeyPair? _signKeyPair;
  final List<SecurityAuditEntry> _auditLog = [];

  bool get isInitialized => _sodium != null && _signKeyPair != null;

  String get publicKeyBase64 =>
      _signKeyPair == null ? '' : base64Encode(_signKeyPair!.publicKey);

  /// Get security audit log (copy)
  List<SecurityAuditEntry> get auditLog => List.unmodifiable(_auditLog);

  /// Initialize Sodium and load/generate keys with security checks
  Future<void> initialize() async {
    _sodium = await SodiumInit.init();

    // Load audit log
    await _loadAuditLog();

    // Try to load existing keys
    final storedSeed = await _storage.read(key: _seedKey);
    final storedChecksum = await _storage.read(key: _seedChecksumKey);

    if (storedSeed != null) {
      // Validate seed format and integrity
      if (!_isValidSeedFormat(storedSeed) ||
          !_verifySeedIntegrity(storedSeed, storedChecksum)) {
        _logAudit(
            'initialize', 'Invalid seed format or integrity detected', false);
        throw Exception("Invalid seed format or integrity in storage");
      }

      final seedBytes = Uint8List.fromList(base64Decode(storedSeed));
      final seedKey = SecureKey.fromList(_sodium!, seedBytes);
      _signKeyPair = _sodium!.crypto.sign.seedKeyPair(seedKey);
      seedKey.dispose();

      _logAudit('initialize', 'Keys loaded from storage', true);

      // Check if key rotation is needed
      await _checkKeyRotation();
    } else {
      await _generateAndSaveNewKeys();
      _logAudit('initialize', 'New keys generated', true);
    }
  }

  /// Validate seed format (basic check)
  bool _isValidSeedFormat(String seed) {
    try {
      final decoded = base64Decode(seed);
      // Ed25519 seeds are 32 bytes
      return decoded.length == 32;
    } catch (_) {
      return false;
    }
  }

  /// Verify seed integrity using stored checksum
  bool _verifySeedIntegrity(String seed, String? checksum) {
    if (checksum == null) return false;
    final computed = sha256.convert(utf8.encode(seed)).toString();
    return computed == checksum;
  }

  /// Check if key rotation is needed
  Future<void> _checkKeyRotation() async {
    final rotationDateStr = await _storage.read(key: _keyRotationDateKey);
    if (rotationDateStr == null) {
      // First time, set rotation date
      await _storage.write(
        key: _keyRotationDateKey,
        value: DateTime.now().toUtc().toIso8601String(),
      );
      return;
    }

    final rotationDate = DateTime.parse(rotationDateStr);
    final now = DateTime.now().toUtc();
    final daysSinceRotation = now.difference(rotationDate).inDays;

    if (daysSinceRotation >= _keyRotationPeriodDays) {
      _logAudit('key_rotation_check',
          'Key rotation triggered: $daysSinceRotation days old', true);
      await rotateKeys();
    }
  }

  /// Generate fresh keys and save the Seed securely
  Future<void> _generateAndSaveNewKeys() async {
    if (_sodium == null) throw Exception("Sodium not initialized");

    final seedKey = SecureKey.random(_sodium!, _sodium!.crypto.sign.seedBytes);
    _signKeyPair = _sodium!.crypto.sign.seedKeyPair(seedKey);

    // Save Seed (Deterministically recreates keys)
    final seedBytes = seedKey.extractBytes();
    final seedB64 = base64Encode(seedBytes);
    await _storage.write(
      key: _seedKey,
      value: seedB64,
    );

    // Save seed checksum for integrity
    final checksum = sha256.convert(utf8.encode(seedB64)).toString();
    await _storage.write(
      key: _seedChecksumKey,
      value: checksum,
    );

    // Update rotation date
    await _storage.write(
      key: _keyRotationDateKey,
      value: DateTime.now().toUtc().toIso8601String(),
    );

    seedKey.dispose();
  }

  /// Rotate keys (generate new identity)
  /// WARNING: This creates a new identity! Old messages cannot be verified.
  Future<void> rotateKeys() async {
    if (!isInitialized) throw Exception("Crypto not initialized");

    _logAudit('key_rotation', 'Starting key rotation', true);

    // Backup old identity first
    await backupIdentity();

    // Clear current keys
    _signKeyPair = null;

    // Generate new keys
    await _generateAndSaveNewKeys();

    _logAudit('key_rotation', 'Keys rotated successfully', true);
  }

  /// Backup current identity to secure storage (encrypted)
  Future<void> backupIdentity() async {
    if (!isInitialized || _sodium == null)
      throw Exception("Crypto not initialized");

    final seed = await _storage.read(key: _seedKey);
    if (seed == null) throw Exception("No seed found to backup");

    final backup = IdentityBackup.create(seed, publicKeyBase64);
    final backupJson = jsonEncode(backup.toJson());

    // Encrypt backup
    final encryptedBackup = await _encryptBackup(backupJson);
    await _storage.write(key: _backupKey, value: encryptedBackup);

    _logAudit('backup', 'Identity backed up (encrypted)', true);
  }

  /// Restore identity from backup
  Future<bool> restoreIdentity() async {
    _logAudit('restore', 'Attempting identity restore', true);

    final encryptedBackup = await _storage.read(key: _backupKey);
    if (encryptedBackup == null) {
      _logAudit('restore', 'No backup found', false);
      return false;
    }

    try {
      final backupJson = await _decryptBackup(encryptedBackup);
      final backup = IdentityBackup.fromJson(jsonDecode(backupJson));

      if (!backup.verifyIntegrity()) {
        _logAudit('restore', 'Backup integrity check failed', false);
        return false;
      }

      // Verify sodium is initialized
      if (_sodium == null) {
        _sodium = await SodiumInit.init();
      }

      // Restore keys
      final seedBytes = Uint8List.fromList(base64Decode(backup.seedBase64));
      final seedKey = SecureKey.fromList(_sodium!, seedBytes);
      _signKeyPair = _sodium!.crypto.sign.seedKeyPair(seedKey);
      seedKey.dispose();

      // Save to primary storage with checksum
      await _storage.write(key: _seedKey, value: backup.seedBase64);
      final checksum =
          sha256.convert(utf8.encode(backup.seedBase64)).toString();
      await _storage.write(key: _seedChecksumKey, value: checksum);

      _logAudit('restore', 'Identity restored successfully', true);
      return true;
    } catch (e) {
      _logAudit('restore', 'Restore failed: $e', false);
      return false;
    }
  }

  /// Export backup for external storage (encrypted string)
  Future<String?> exportBackup() async {
    if (!isInitialized) throw Exception("Crypto not initialized");

    final seed = await _storage.read(key: _seedKey);
    if (seed == null) return null;

    final backup = IdentityBackup.create(seed, publicKeyBase64);
    final backupJson = jsonEncode(backup.toJson());
    final encrypted = await _encryptBackup(backupJson);
    return base64Encode(utf8.encode(encrypted));
  }

  /// Import backup from external storage
  Future<bool> importBackup(String exportedBackup) async {
    _logAudit('import', 'Attempting backup import', true);

    try {
      final decoded = utf8.decode(base64Decode(exportedBackup));
      final backupJson = await _decryptBackup(decoded);
      final backup = IdentityBackup.fromJson(jsonDecode(backupJson));

      if (!backup.verifyIntegrity()) {
        _logAudit('import', 'Backup integrity check failed', false);
        return false;
      }

      // Store as current backup (encrypted)
      final encrypted = await _encryptBackup(backupJson);
      await _storage.write(key: _backupKey, value: encrypted);

      _logAudit('import', 'Backup imported successfully', true);
      return true;
    } catch (e) {
      _logAudit('import', 'Import failed: $e', false);
      return false;
    }
  }

  /// Sign data with the private key
  Future<String> signData(String message) async {
    if (!isInitialized) throw Exception("Crypto not initialized");

    final messageBytes = utf8.encode(message);
    final signature = _sodium!.crypto.sign.detached(
      message: messageBytes,
      secretKey: _signKeyPair!.secretKey,
    );

    return base64Encode(signature);
  }

  /// Verify signature for a message
  bool verifySignature(
      String message, String signatureBase64, String publicKeyBase64) {
    if (_sodium == null) throw Exception("Sodium not initialized");

    try {
      final messageBytes = utf8.encode(message);
      final signature = base64Decode(signatureBase64);
      final publicKey = base64Decode(publicKeyBase64);

      return _sodium!.crypto.sign.verifyDetached(
        signature: signature,
        message: messageBytes,
        publicKey: publicKey,
      );
    } catch (_) {
      return false;
    }
  }

  /// Internal - Log security events
  void _logAudit(String action, String details, bool success) {
    final entry = SecurityAuditEntry(
      timestamp: DateTime.now(),
      action: action,
      details: details,
      success: success,
    );

    _auditLog.insert(0, entry);
    if (_auditLog.length > _maxAuditEntries) {
      _auditLog.removeLast();
    }

    _saveAuditLog();
  }

  Future<void> _loadAuditLog() async {
    final logJson = await _storage.read(key: _auditLogKey);
    if (logJson == null) return;

    try {
      final List<dynamic> list = jsonDecode(logJson);
      _auditLog.clear();
      _auditLog.addAll(list.map((e) => SecurityAuditEntry(
            timestamp: DateTime.parse(e['timestamp']),
            action: e['action'],
            details: e['details'],
            success: e['success'],
          )));
    } catch (_) {}
  }

  Future<void> _saveAuditLog() async {
    final logJson = jsonEncode(_auditLog.map((e) => e.toJson()).toList());
    await _storage.write(key: _auditLogKey, value: logJson);
  }

  /// Encrypt backup data using derived key
  Future<String> _encryptBackup(String plainText) async {
    if (_sodium == null) throw Exception("Sodium not initialized");

    // Derive key from passphrase using SHA256
    final keyBytes = sha256.convert(utf8.encode(_backupPassphrase)).bytes;
    final key = SecureKey.fromList(_sodium!, Uint8List.fromList(keyBytes));

    // Generate nonce
    final nonce =
        _sodium!.randombytes.buf(_sodium!.crypto.secretBox.nonceBytes);

    // Encrypt
    final cipherText = _sodium!.crypto.secretBox.easy(
      message: utf8.encode(plainText),
      nonce: nonce,
      key: key,
    );

    key.dispose();

    // Combine nonce + ciphertext
    final combined = Uint8List(nonce.length + cipherText.length);
    combined.setRange(0, nonce.length, nonce);
    combined.setRange(nonce.length, combined.length, cipherText);

    return base64Encode(combined);
  }

  /// Decrypt backup data
  Future<String> _decryptBackup(String encryptedBase64) async {
    if (_sodium == null) throw Exception("Sodium not initialized");

    final encrypted = base64Decode(encryptedBase64);
    final nonceLen = _sodium!.crypto.secretBox.nonceBytes;

    if (encrypted.length < nonceLen) {
      throw Exception("Invalid encrypted data");
    }

    final nonce = encrypted.sublist(0, nonceLen);
    final cipherText = encrypted.sublist(nonceLen);

    // Derive key
    final keyBytes = sha256.convert(utf8.encode(_backupPassphrase)).bytes;
    final key = SecureKey.fromList(_sodium!, Uint8List.fromList(keyBytes));

    // Decrypt
    final plainText = _sodium!.crypto.secretBox.openEasy(
      cipherText: cipherText,
      nonce: nonce,
      key: key,
    );

    key.dispose();

    return utf8.decode(plainText);
  }
}
