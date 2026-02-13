import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// NFC Transport Layer.
/// Enables tap-to-share SOS alerts and peer discovery via NFC.
class NfcTransport extends TransportLayer {
  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  bool _isEnabled = false;

  static const _descriptor = TransportDescriptor(
    id: 'nfc',
    name: 'NFC Tap-to-Share',
    technologyIds: ['nfc', 'ndef'],
    mediums: ['nfc'],
    requiresGateway: false,
    notes:
        'Requires NFC hardware. Range ~10cm. Used for peer discovery and emergency contact sharing.',
  );

  @override
  TransportDescriptor get descriptor => _descriptor;

  @override
  TransportHealth get health => _health;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _isEnabled = true;
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Check NFC availability
      final isAvailable = await _checkNfcAvailable();
      if (!isAvailable) {
        throw Exception('NFC not available on this device');
      }

      // Start listening for NFC tags
      await _startNfcSession();

      _health = _health.copyWith(
        availability: TransportAvailability.available,
        lastOkAt: DateTime.now(),
      );
    } catch (e) {
      _health = _health.copyWith(
        availability: TransportAvailability.unavailable,
        lastError: e.toString(),
        errorCount: _health.errorCount + 1,
      );
    }
  }

  Future<bool> _checkNfcAvailable() async {
    // In real implementation, use nfc_manager package
    // return NfcManager.instance.isAvailable();
    return true; // Assume available for now
  }

  Future<void> _startNfcSession() async {
    // Start listening for NDEF tags
    // NfcManager.instance.startSession(onDiscovered: _handleTag);
  }

  void _handleTag(dynamic tag) {
    // Parse NDEF message from tag
    // Look for SOS-specific record type
    // Example NDEF record: "sos://alert?id=xxx&lat=xxx&lon=xxx"

    final packet = TransportPacket(
      senderId: 'NFC_TAG',
      recipientId: null,
      type: SosPacketType.discovery,
      payload: {'source': 'NFC', 'tag_id': 'unknown'},
      rxTransportId: descriptor.id,
    );
    _incomingController.add(packet);
  }

  @override
  Future<void> broadcast(String message) async {
    // NFC is point-to-point, cannot broadcast
    throw UnsupportedError('NFC does not support broadcast');
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (_health.availability != TransportAvailability.available) {
      throw Exception('NFC not available');
    }

    // Write NDEF message to tag or share via Android Beam / iOS Core NFC
    final ndefRecord = _createNdefRecord(packet);
    await _writeNdefMessage(ndefRecord);
  }

  String _createNdefRecord(TransportPacket packet) {
    // Create URI record for SOS
    // Format: sos://alert?id={id}&sender={senderId}&type={type}
    final params = <String, String>{
      'id': packet.id,
      'sender': packet.senderId,
      'type': packet.type.name,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'sos://alert?$query';
  }

  Future<void> _writeNdefMessage(String record) async {
    // In real implementation:
    // await NfcManager.instance.writeNdef(NdefMessage([NdefRecord.createUri(Uri.parse(record))]));
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Share emergency contact info via NFC tap
  Future<void> shareEmergencyInfo({
    required String name,
    required String phone,
    String? medicalInfo,
  }) async {
    final payload = {
      'type': 'emergency_contact',
      'name': name,
      'phone': phone,
      if (medicalInfo != null) 'medical': medicalInfo,
    };

    final packet = TransportPacket(
      senderId: _localId ?? 'unknown',
      type: SosPacketType.data,
      payload: payload,
    );

    await send(packet);
  }

  @override
  Future<void> connect(String peerId) async {
    // NFC doesn't maintain connections
  }

  @override
  Future<void> dispose() async {
    _isEnabled = false;
    // NfcManager.instance.stopSession();
    await _incomingController.close();
  }
}
