import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../identity/crypto_manager.dart';
import '../protocol/sos_envelope.dart';

/// Frame integrity verification result
class FrameVerificationResult {
  final bool isValid;
  final bool isReplay;
  final String? error;

  const FrameVerificationResult._({
    required this.isValid,
    this.isReplay = false,
    this.error,
  });

  factory FrameVerificationResult.valid() =>
      const FrameVerificationResult._(isValid: true);

  factory FrameVerificationResult.invalid(String error) =>
      FrameVerificationResult._(isValid: false, error: error);

  factory FrameVerificationResult.replay() =>
      const FrameVerificationResult._(isValid: false, isReplay: true);
}

class SosFrame {
  final String id;
  final int ttl;
  final int hops;
  final SosEnvelope envelope;
  final String? signature;
  final DateTime timestamp;
  final String? parentFrameId;

  const SosFrame({
    required this.id,
    required this.ttl,
    required this.hops,
    required this.envelope,
    this.signature,
    required this.timestamp,
    this.parentFrameId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ttl': ttl,
        'hops': hops,
        'envelope': envelope.toJson(),
        'signature': signature,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'parentFrameId': parentFrameId,
      };

  String toJsonString() => jsonEncode(toJson());

  SosFrame copyWith({
    int? ttl,
    int? hops,
    String? parentFrameId,
  }) {
    return SosFrame(
      id: id,
      ttl: ttl ?? this.ttl,
      hops: hops ?? this.hops,
      envelope: envelope,
      signature: signature,
      timestamp: timestamp,
      parentFrameId: parentFrameId ?? this.parentFrameId,
    );
  }

  static SosFrame fromJson(Map<String, dynamic> json) {
    return SosFrame(
      id: json['id'] as String,
      ttl: json['ttl'] as int? ?? 8,
      hops: json['hops'] as int? ?? 0,
      envelope: SosEnvelope.fromJson(
        Map<String, dynamic>.from(json['envelope'] as Map),
      ),
      signature: json['signature'] as String?,
      timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
      parentFrameId: json['parentFrameId'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static SosFrame fromJsonString(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return SosFrame.fromJson(data);
  }

  static SosFrame wrap({
    required SosEnvelope envelope,
    int ttl = 8,
    String? parentFrameId,
  }) {
    final timestamp = DateTime.now();
    final id = computeId(envelope, timestamp);
    return SosFrame(
      id: id,
      ttl: ttl,
      hops: 0,
      envelope: envelope,
      timestamp: timestamp,
      parentFrameId: parentFrameId,
    );
  }

  static String computeId(SosEnvelope envelope, DateTime timestamp) {
    final bytes = utf8.encode(
      '${envelope.canonicalBody()}|${envelope.signature}|${timestamp.toUtc().toIso8601String()}',
    );
    return sha256.convert(bytes).toString();
  }

  /// Sign this frame with the provided crypto manager
  Future<SosFrame> sign(CryptoManager crypto) async {
    if (signature != null) return this;

    final payload =
        '$id|${envelope.canonicalBody()}|${timestamp.toUtc().toIso8601String()}';
    final sig = await crypto.signData(payload);

    return SosFrame(
      id: id,
      ttl: ttl,
      hops: hops,
      envelope: envelope,
      signature: sig,
      timestamp: timestamp,
      parentFrameId: parentFrameId,
    );
  }

  /// Verify frame integrity and signature
  FrameVerificationResult verifyIntegrity(
    CryptoManager crypto, {
    Duration maxAge = const Duration(minutes: 5),
    Set<String>? seenFrameIds,
  }) {
    // Check timestamp for replay attacks
    final age = DateTime.now().difference(timestamp);
    if (age > maxAge) {
      return FrameVerificationResult.invalid(
          'Frame expired: ${age.inSeconds}s old');
    }
    if (age < const Duration(seconds: -30)) {
      return FrameVerificationResult.invalid('Frame timestamp in future');
    }

    // Check for replay
    if (seenFrameIds != null && seenFrameIds.contains(id)) {
      return FrameVerificationResult.replay();
    }

    // Verify frame ID matches computed ID
    final expectedId = computeId(envelope, timestamp);
    if (id != expectedId) {
      return FrameVerificationResult.invalid('Frame ID mismatch');
    }

    // Verify signature if present
    if (signature != null) {
      final payload =
          '$id|${envelope.canonicalBody()}|${timestamp.toUtc().toIso8601String()}';
      final isValid = crypto.verifySignature(
        payload,
        signature!,
        envelope.sender,
      );
      if (!isValid) {
        return FrameVerificationResult.invalid('Invalid frame signature');
      }
    }

    return FrameVerificationResult.valid();
  }

  /// Create a forwarded copy of this frame with decremented TTL
  SosFrame createForward() {
    if (ttl <= 0) {
      throw StateError('Cannot forward frame with TTL <= 0');
    }
    return copyWith(
      ttl: ttl - 1,
      hops: hops + 1,
      parentFrameId: id,
    );
  }

  @override
  String toString() {
    return 'SosFrame(id: ${id.substring(0, 8)}..., ttl: $ttl, hops: $hops, '
        'sender: ${envelope.sender.substring(0, 16)}..., '
        'signed: ${signature != null})';
  }
}
