import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// IrDA / IR Transport Layer.
/// Infrared data and remote control communication.
class IrTransport extends TransportLayer {
  final IrMode _mode;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'ir',
    name: 'Infrared (IrDA / Remote)',
    technologyIds: ['irda', 'ir_remote', 'sir', 'fir'],
    mediums: ['optical', 'infrared'],
    requiresGateway: false,
    notes: 'Short range (1-5m) line of sight. IrDA up to 16 Mbps (FIR).',
  );

  IrTransport({IrMode mode = IrMode.irda}) : _mode = mode;

  @override
  TransportDescriptor get descriptor => kDescriptor;
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
      _health = _health.copyWith(availability: TransportAvailability.degraded);

      switch (_mode) {
        case IrMode.irda:
          // Configure IrDA stack (IrLAP, IrLMP, IrOBEX)
          break;
        case IrMode.remoteControl:
          // Configure IR blaster/receiver for RC codes
          break;
      }

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

  /// Send IR remote control code (NEC, RC5, Sony, etc.)
  Future<void> sendRemoteCode(int code, IrProtocol protocol) async {
    // Modulate IR LED with appropriate protocol
  }

  /// Receive and decode IR signal
  Future<int?> receiveCode() async {
    // Demodulate IR receiver signal
    return null;
  }

  @override
  Future<void> broadcast(String message) async {
    // IR is directional, no true broadcast
    // Send via IrDA if available
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> connect(String peerId) async {}
  @override
  Future<void> dispose() async {
    await _incomingController.close();
  }
}

enum IrMode { irda, remoteControl }

enum IrProtocol { nec, rc5, rc6, sony, samsung, panasonic }
