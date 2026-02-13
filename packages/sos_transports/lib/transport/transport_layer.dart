/// Abstract definition for transport mechanisms in the mesh network.

import 'dart:convert';
import 'transport_descriptor.dart';
import 'transport_health.dart';
import 'transport_packet.dart';

abstract class TransportLayer {
  /// Stable identifier and technology bindings.
  TransportDescriptor get descriptor;

  /// Health status for runtime diagnostics.
  TransportHealth get health;

  /// Initialize the transport (e.g., start scanning, advertising, etc.).
  Future<void> initialize();

  /// Set local node id (used for discovery metadata).
  void setLocalId(String id);

  /// Current local node id.
  String? get localId;

  /// Broadcast a raw message (legacy).
  Future<void> broadcast(String message);

  /// Send a structured packet with metadata and signature.
  Future<void> send(TransportPacket packet);

  /// Listen for incoming packets (with metadata).
  Stream<TransportPacket> get onPacketReceived;

  /// Convenience: raw message stream.
  Stream<String> get onMessageReceived =>
      onPacketReceived.map((packet) => jsonEncode(packet.payload));

  /// Connect to a specific peer (optional, depending on transport).
  Future<void> connect(String peerId);

  /// Optional cleanup.
  Future<void> dispose() async {}
}
