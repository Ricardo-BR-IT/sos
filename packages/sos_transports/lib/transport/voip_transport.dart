// ignore_for_file: unused_field, unused_local_variable, unused_element, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// VoIP Transport Layer using SIP/RTP.
/// Voice communication for emergency calls over mesh network.
class VoipTransport extends TransportLayer {
  final String _sipServer;
  final int _sipPort;
  final String _sipUser;
  final String _sipPassword;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  Socket? _sipSocket;
  RawDatagramSocket? _rtpSocket;
  bool _isRegistered = false;
  String? _currentCallId;

  static const kDescriptor = TransportDescriptor(
    id: 'voip',
    name: 'VoIP (SIP/RTP)',
    technologyIds: ['sip', 'rtp', 'voip'],
    mediums: ['internet', 'lan'],
    requiresGateway: true,
    notes: 'Voice over IP for emergency communications. Requires SIP server.',
  );

  VoipTransport({
    required String sipServer,
    int sipPort = 5060,
    required String sipUser,
    required String sipPassword,
  })  : _sipServer = sipServer,
        _sipPort = sipPort,
        _sipUser = sipUser,
        _sipPassword = sipPassword;

  @override
  TransportDescriptor get descriptor => kDescriptor;

  @override
  TransportHealth get health => _health;

  @override
  String? get localId => _localId;

  bool get isRegistered => _isRegistered;
  bool get isInCall => _currentCallId != null;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  Stream<TransportPacket> get onPacketReceived => _incomingController.stream;

  @override
  Future<void> initialize() async {
    try {
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      // Connect to SIP server
      _sipSocket = await Socket.connect(_sipServer, _sipPort);
      _sipSocket?.listen(_handleSipMessage);

      // Bind RTP socket for media
      _rtpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _rtpSocket?.listen(_handleRtpPacket);

      // Register with SIP server
      await _register();

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

  Future<void> _register() async {
    final callId = _generateCallId();
    final register = '''
REGISTER sip:$_sipServer SIP/2.0\r
Via: SIP/2.0/UDP ${InternetAddress.anyIPv4.address}:5060;branch=z9hG4bK$callId\r
Max-Forwards: 70\r
To: <sip:$_sipUser@$_sipServer>\r
From: <sip:$_sipUser@$_sipServer>;tag=$callId\r
Call-ID: $callId@$_sipServer\r
CSeq: 1 REGISTER\r
Contact: <sip:$_sipUser@${InternetAddress.anyIPv4.address}:5060>\r
Expires: 3600\r
Content-Length: 0\r
\r
''';
    _sipSocket?.write(register);
    _isRegistered = true;
  }

  void _handleSipMessage(List<int> data) {
    final message = utf8.decode(data);

    if (message.startsWith('INVITE')) {
      _handleIncomingCall(message);
    } else if (message.startsWith('BYE')) {
      _handleCallEnd(message);
    } else if (message.contains('200 OK')) {
      // Call or registration successful
    }
  }

  void _handleIncomingCall(String message) {
    // Parse SIP INVITE and notify
    final packet = TransportPacket(
      senderId: 'SIP',
      type: SosPacketType.sos,
      payload: {'type': 'incoming_call', 'message': message},
      rxTransportId: descriptor.id,
    );
    _incomingController.add(packet);
  }

  void _handleCallEnd(String message) {
    _currentCallId = null;
  }

  void _handleRtpPacket(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _rtpSocket?.receive();
    if (datagram == null) return;

    // Parse RTP packet and forward audio
    // In real implementation, decode audio codec and play
  }

  /// Initiate an emergency call
  Future<void> call(String destination) async {
    if (_currentCallId != null) {
      throw Exception('Already in a call');
    }

    _currentCallId = _generateCallId();
    final invite = '''
INVITE sip:$destination@$_sipServer SIP/2.0\r
Via: SIP/2.0/UDP ${InternetAddress.anyIPv4.address}:5060;branch=z9hG4bK$_currentCallId\r
Max-Forwards: 70\r
To: <sip:$destination@$_sipServer>\r
From: <sip:$_sipUser@$_sipServer>;tag=$_currentCallId\r
Call-ID: $_currentCallId@$_sipServer\r
CSeq: 1 INVITE\r
Contact: <sip:$_sipUser@${InternetAddress.anyIPv4.address}:5060>\r
Content-Type: application/sdp\r
Content-Length: 0\r
\r
''';
    _sipSocket?.write(invite);
  }

  /// End current call
  Future<void> hangup() async {
    if (_currentCallId == null) return;

    final bye = '''
BYE sip:$_sipServer SIP/2.0\r
Via: SIP/2.0/UDP ${InternetAddress.anyIPv4.address}:5060;branch=z9hG4bK$_currentCallId\r
Call-ID: $_currentCallId@$_sipServer\r
CSeq: 2 BYE\r
Content-Length: 0\r
\r
''';
    _sipSocket?.write(bye);
    _currentCallId = null;
  }

  /// Send audio data during call
  Future<void> sendAudio(Uint8List audioData) async {
    if (_currentCallId == null) return;
    // Package as RTP and send via _rtpSocket
  }

  String _generateCallId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }

  @override
  Future<void> broadcast(String message) async {
    throw UnsupportedError('VoIP is for voice calls, not messaging');
  }

  @override
  Future<void> send(TransportPacket packet) async {
    if (packet.type == SosPacketType.sos) {
      // Emergency call to configured responders
      await call('emergency');
    }
  }

  @override
  Future<void> connect(String peerId) async {
    await call(peerId);
  }

  @override
  Future<void> dispose() async {
    await hangup();
    await _sipSocket?.close();
    _rtpSocket?.close();
    await _incomingController.close();
  }
}

