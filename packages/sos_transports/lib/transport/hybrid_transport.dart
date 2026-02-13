/// hybrid_transport.dart
/// Implements a fallback strategy: try multiple transports and merge streams.

import 'dart:async';
import 'dart:convert';

import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_hub.dart';
import 'transport_layer.dart';
import 'transport_metrics.dart';
import 'transport_packet.dart';
import 'transport_registry.dart';

class HybridTransport implements TransportLayer, TransportBroadcaster {
  final List<TransportLayer> _layers;
  final StreamController<TransportPacket> _packetController =
      StreamController.broadcast();
  final Map<String, TransportMetrics> _metrics = {};
  final List<TransportDescriptor> _knownDescriptors;
  String? _localId;

  HybridTransport({
    TransportActivation activation = const TransportActivation(),
  })  : _layers = TransportRegistry.buildActiveLayers(
          activation: activation,
        ),
        _knownDescriptors = TransportRegistry.knownDescriptors();

  factory HybridTransport.maxCoverage() {
    return HybridTransport(
      activation: const TransportActivation(
        bluetoothClassic: true,
        bluetoothMesh: true,
        ethernet: true,
        acoustic: true,
        optical: true,
        lorawan: true,
        satD2d: true,
        mqtt: true,
      ),
    );
  }

  @override
  Future<void> initialize() async {
    for (var layer in _layers) {
      if (_localId != null) {
        layer.setLocalId(_localId!);
      }
      try {
        await layer.initialize();
        layer.onPacketReceived.listen((packet) {
          _metricsFor(layer.descriptor.id).received++;
          _metricsFor(layer.descriptor.id).lastReceiveAt = DateTime.now();
          _packetController.add(packet);
        });
      } catch (_) {
        // Keep going even if one transport fails.
        _metricsFor(layer.descriptor.id).errors++;
      }
    }
  }

  @override
  Future<void> broadcast(String message) async {
    for (var layer in _layers) {
      try {
        await layer.broadcast(message);
        _metricsFor(layer.descriptor.id).sent++;
        _metricsFor(layer.descriptor.id).lastSendAt = DateTime.now();
      } catch (_) {
        // ignore and try next layer
        _metricsFor(layer.descriptor.id).errors++;
      }
    }
  }

  @override
  Stream<TransportPacket> get onPacketReceived => _packetController.stream;

  @override
  Stream<String> get onMessageReceived =>
      onPacketReceived.map((packet) => jsonEncode(packet.payload));

  @override
  Future<void> connect(String peerId) async {
    for (var layer in _layers) {
      try {
        await layer.connect(peerId);
        return;
      } catch (_) {}
    }
    throw Exception('All transport layers failed to connect');
  }

  @override
  void setLocalId(String id) {
    _localId = id;
    for (var layer in _layers) {
      layer.setLocalId(id);
    }
  }

  @override
  String? get localId => _localId;

  @override
  Future<void> dispose() async {
    await _packetController.close();
    for (final layer in _layers) {
      await layer.dispose();
    }
  }

  @override
  TransportDescriptor get descriptor => const TransportDescriptor(
        id: 'hybrid',
        name: 'Hybrid Transport',
        technologyIds: [],
      );

  @override
  TransportHealth get health => const TransportHealth(
        availability: TransportAvailability.available,
      );

  @override
  Future<void> send(TransportPacket packet) async {
    for (var layer in _layers) {
      try {
        await layer.send(packet);
        _metricsFor(layer.descriptor.id).sent++;
        _metricsFor(layer.descriptor.id).lastSendAt = DateTime.now();
      } catch (_) {
        _metricsFor(layer.descriptor.id).errors++;
      }
    }
  }

  @override
  Future<void> sendToTransport(
      String transportId, TransportPacket packet) async {
    final layer = _layers.firstWhere(
      (l) => l.descriptor.id == transportId,
      orElse: () => throw Exception('Transport $transportId not found'),
    );
    await layer.send(packet);
    _metricsFor(transportId).sent++;
    _metricsFor(transportId).lastSendAt = DateTime.now();
  }

  @override
  Future<void> broadcastVia(String transportId, String message) async {
    final layer = _layers.firstWhere(
      (l) => l.descriptor.id == transportId,
      orElse: () => throw Exception('Transport $transportId not found'),
    );
    await layer.broadcast(message);
    _metricsFor(transportId).sent++;
    _metricsFor(transportId).lastSendAt = DateTime.now();
  }

  @override
  List<TransportDescriptor> get descriptors =>
      List.unmodifiable(_knownDescriptors);

  @override
  Map<String, TransportHealth> get healthSnapshot {
    final map = <String, TransportHealth>{};
    for (final layer in _layers) {
      map[layer.descriptor.id] = layer.health;
    }
    return map;
  }

  @override
  Map<String, TransportMetrics> get metricsSnapshot =>
      Map.unmodifiable(_metrics);

  TransportMetrics _metricsFor(String transportId) {
    return _metrics.putIfAbsent(transportId, () => TransportMetrics());
  }
}
