import 'dart:async';

import 'transport_layer.dart';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

/// Weightless LPWAN Transport Layer.
/// Sub-GHz open standard IoT network.
class WeightlessTransport extends TransportLayer {
  final WeightlessVariant _variant;

  final StreamController<TransportPacket> _incomingController =
      StreamController<TransportPacket>.broadcast();

  String? _localId;
  TransportHealth _health = const TransportHealth(
    availability: TransportAvailability.unavailable,
  );

  static const kDescriptor = TransportDescriptor(
    id: 'weightless',
    name: 'Weightless LPWAN',
    technologyIds: ['weightless-w', 'weightless-n', 'weightless-p'],
    mediums: ['radio', 'sub-ghz', 'tv-whitespace'],
    requiresGateway: true,
    notes:
        'Open LPWAN standard. Weightless-W uses TV white space (50km range).',
  );

  WeightlessTransport({
    WeightlessVariant variant = WeightlessVariant.p,
  }) : _variant = variant;

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

      switch (_variant) {
        case WeightlessVariant.w:
          // Weightless-W: TV white space (470-790 MHz)
          // 50km range, 16 kbps - 10 Mbps
          // Cognitive radio with spectrum sensing
          break;
        case WeightlessVariant.n:
          // Weightless-N: Narrow-band on sub-GHz ISM
          // Similar to Sigfox, uplink-only
          // Ultra-low power
          break;
        case WeightlessVariant.p:
          // Weightless-P: Sub-GHz (138/433/470/780/868/915/923 MHz)
          // Bidirectional, 200 bps - 100 kbps
          // FDMA/TDMA with AES-128 security
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

  @override
  Future<void> broadcast(String message) async {}
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

enum WeightlessVariant { w, n, p }
