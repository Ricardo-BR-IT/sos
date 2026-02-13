library sos_calls;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sos_kernel/sos_kernel.dart';

enum CallEventType { incoming, accepted, rejected, ended, mediaUpdated }

class CallEvent {
  final CallEventType type;
  final String peerId;
  final String callId;
  final CallMediaMode? mediaMode;

  const CallEvent({
    required this.type,
    required this.peerId,
    required this.callId,
    this.mediaMode,
  });
}

enum CallState { idle, calling, ringing, connected }

enum CallMediaMode {
  signalingOnly,
  lowBitrate,
  webrtc,
}

class CallMediaPlan {
  final List<CallMediaMode> supportedModes;
  final CallMediaMode preferred;

  const CallMediaPlan({
    required this.supportedModes,
    required this.preferred,
  });

  factory CallMediaPlan.fallback() {
    return const CallMediaPlan(
      supportedModes: [CallMediaMode.signalingOnly],
      preferred: CallMediaMode.signalingOnly,
    );
  }
}

class CallSignaling {
  final MeshService mesh;
  CallState _state = CallState.idle;
  String? _activePeer;
  String? _callId;
  CallMediaPlan _mediaPlan = CallMediaPlan.fallback();
  CallMediaMode _activeMediaMode = CallMediaMode.signalingOnly;
  StreamSubscription<SosEnvelope>? _sub;
  final StreamController<CallEvent> _events = StreamController.broadcast();

  CallSignaling({required this.mesh});

  CallState get state => _state;
  Stream<CallEvent> get events => _events.stream;
  CallMediaMode get activeMediaMode => _activeMediaMode;
  CallMediaPlan get mediaPlan => _mediaPlan;

  void setMediaPlan(CallMediaPlan plan) {
    _mediaPlan = plan;
  }

  Future<void> initialize() async {
    _sub = mesh.messages.listen(_handleEnvelope);
  }

  Future<void> startCall(String targetId) async {
    if (_state != CallState.idle) return;
    _state = CallState.calling;
    _activePeer = targetId;
    _callId = '${mesh.core.publicKey}:${DateTime.now().millisecondsSinceEpoch}';
    await mesh.sendDirect(
      targetId: targetId,
      type: 'call_invite',
      payload: {'callId': _callId},
    );
  }

  Future<void> acceptCall() async {
    if (_state != CallState.ringing || _activePeer == null || _callId == null) return;
    await mesh.sendDirect(
      targetId: _activePeer!,
      type: 'call_accept',
      payload: {'callId': _callId},
    );
    _state = CallState.connected;
    await _sendMediaOffer();
  }

  Future<void> rejectCall() async {
    if (_state != CallState.ringing || _activePeer == null || _callId == null) return;
    await mesh.sendDirect(
      targetId: _activePeer!,
      type: 'call_reject',
      payload: {'callId': _callId},
    );
    _state = CallState.idle;
    _activePeer = null;
    _callId = null;
  }

  Future<void> endCall() async {
    if (_activePeer == null || _callId == null) return;
    await mesh.sendDirect(
      targetId: _activePeer!,
      type: 'call_end',
      payload: {'callId': _callId},
    );
    _state = CallState.idle;
    _activePeer = null;
    _callId = null;
    _activeMediaMode = CallMediaMode.signalingOnly;
  }

  void dispose() {
    _sub?.cancel();
    _events.close();
  }

  void _handleEnvelope(SosEnvelope envelope) {
    if (!envelope.type.startsWith('call_')) return;
    final callId = envelope.payload['callId']?.toString();
    if (callId == null) return;

    switch (envelope.type) {
      case 'call_invite':
        if (_state == CallState.idle) {
          _state = CallState.ringing;
          _activePeer = envelope.sender;
          _callId = callId;
          _events.add(CallEvent(
            type: CallEventType.incoming,
            peerId: envelope.sender,
            callId: callId,
          ));
        }
        break;
      case 'call_accept':
        if (_state == CallState.calling && _callId == callId) {
          _state = CallState.connected;
          _events.add(CallEvent(
            type: CallEventType.accepted,
            peerId: envelope.sender,
            callId: callId,
          ));
          _sendMediaOffer();
        }
        break;
      case 'call_reject':
        if (_callId == callId) {
          _state = CallState.idle;
          _events.add(CallEvent(
            type: CallEventType.rejected,
            peerId: envelope.sender,
            callId: callId,
          ));
        }
        break;
      case 'call_end':
        if (_callId == callId) {
          _state = CallState.idle;
          _events.add(CallEvent(
            type: CallEventType.ended,
            peerId: envelope.sender,
            callId: callId,
          ));
          _activeMediaMode = CallMediaMode.signalingOnly;
        }
        break;
      case 'call_media_offer':
        if (_callId == callId) {
          _handleMediaOffer(envelope);
        }
        break;
      case 'call_media_answer':
        if (_callId == callId) {
          _handleMediaAnswer(envelope);
        }
        break;
    }
  }

  Future<void> _sendMediaOffer() async {
    if (_activePeer == null || _callId == null) return;
    await mesh.sendDirect(
      targetId: _activePeer!,
      type: 'call_media_offer',
      payload: {
        'callId': _callId,
        'modes': _mediaPlan.supportedModes.map((m) => m.name).toList(),
        'preferred': _mediaPlan.preferred.name,
      },
    );
  }

  void _handleMediaOffer(SosEnvelope envelope) {
    final offered = (envelope.payload['modes'] as List?)
            ?.map((m) => m.toString())
            .toList() ??
        [];
    final offeredModes = offered
        .map(_parseMediaMode)
        .where((m) => m != null)
        .cast<CallMediaMode>()
        .toList();

    final chosen = _selectMediaMode(offeredModes);
    _activeMediaMode = chosen;
    _events.add(CallEvent(
      type: CallEventType.mediaUpdated,
      peerId: envelope.sender,
      callId: envelope.payload['callId']?.toString() ?? '',
      mediaMode: chosen,
    ));

    mesh.sendDirect(
      targetId: envelope.sender,
      type: 'call_media_answer',
      payload: {
        'callId': envelope.payload['callId'],
        'mode': chosen.name,
      },
    );
  }

  void _handleMediaAnswer(SosEnvelope envelope) {
    final mode = _parseMediaMode(envelope.payload['mode']?.toString());
    if (mode == null) return;
    _activeMediaMode = mode;
    _events.add(CallEvent(
      type: CallEventType.mediaUpdated,
      peerId: envelope.sender,
      callId: envelope.payload['callId']?.toString() ?? '',
      mediaMode: mode,
    ));
  }

  CallMediaMode _selectMediaMode(List<CallMediaMode> offered) {
    for (final preferred in [
      CallMediaMode.webrtc,
      CallMediaMode.lowBitrate,
      CallMediaMode.signalingOnly,
    ]) {
      if (offered.contains(preferred) &&
          _mediaPlan.supportedModes.contains(preferred)) {
        return preferred;
      }
    }
    return CallMediaMode.signalingOnly;
  }

  CallMediaMode? _parseMediaMode(String? value) {
    if (value == null) return null;
    for (final mode in CallMediaMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}

class CallScreen extends StatefulWidget {
  final CallSignaling signaling;
  final String targetId;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.signaling,
    required this.targetId,
    required this.isCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    widget.signaling.initialize();
    if (widget.isCaller) {
      widget.signaling.startCall(widget.targetId);
      _status = 'Calling ${widget.targetId.substring(0, 8)}...';
    } else {
      _status = 'Incoming call from ${widget.targetId.substring(0, 8)}...';
    }
    widget.signaling.events.listen((event) {
      if (!mounted) return;
      setState(() {
        switch (event.type) {
          case CallEventType.accepted:
            _status = 'Connected';
            break;
          case CallEventType.rejected:
            _status = 'Call rejected';
            break;
          case CallEventType.ended:
            _status = 'Call ended';
            break;
          case CallEventType.incoming:
            _status = 'Incoming call';
            break;
          case CallEventType.mediaUpdated:
            _status = 'Media: ${event.mediaMode?.name ?? 'unknown'}';
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Call')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Media ativa: ${widget.signaling.activeMediaMode.name}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (widget.signaling.state == CallState.ringing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await widget.signaling.acceptCall();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await widget.signaling.rejectCall();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            if (widget.signaling.state == CallState.connected ||
                widget.signaling.state == CallState.calling)
              ElevatedButton(
                onPressed: () async {
                  await widget.signaling.endCall();
                  if (mounted) setState(() {});
                },
                child: const Text('End Call'),
              ),
          ],
        ),
      ),
    );
  }
}
