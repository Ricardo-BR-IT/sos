import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class MqttTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'mqtt',
    name: 'MQTT',
    technologyIds: ['protocol_mqtt'],
    mediums: ['protocol'],
  );

  final String host;
  final int port;
  final String topic;
  final String clientId;

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  String? _localId;

  MqttTransport({
    String? host,
    int? port,
    String? topic,
    String? clientId,
  })  : host = host ?? _defaultHost(),
        port = port ?? _defaultPort(),
        topic = topic ?? _defaultTopic(),
        clientId = clientId ?? _defaultClientId();

  static String _defaultHost() {
    return const String.fromEnvironment(
      'SOS_MQTT_HOST',
      defaultValue: 'localhost',
    );
  }

  static int _defaultPort() {
    const value = String.fromEnvironment(
      'SOS_MQTT_PORT',
      defaultValue: '1883',
    );
    return int.tryParse(value) ?? 1883;
  }

  static String _defaultTopic() {
    return const String.fromEnvironment(
      'SOS_MQTT_TOPIC',
      defaultValue: 'sos/mesh',
    );
  }

  static String _defaultClientId() {
    return const String.fromEnvironment(
      'SOS_MQTT_CLIENT_ID',
      defaultValue: 'sos_client',
    );
  }

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
  }

  @override
  Future<void> initialize() async {
    final resolvedId =
        _localId ?? '$clientId-${DateTime.now().millisecondsSinceEpoch}';
    final client = MqttServerClient(host, resolvedId);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onConnected = _handleConnected;
    client.onDisconnected = _handleDisconnected;
    client.onSubscribed = (_) {};
    client.onSubscribeFail = (_) {
      reportError('MQTT subscribe failed');
    };

    _client = client;

    try {
      await client.connect();
    } catch (e) {
      markUnavailable('MQTT connect failed: $e');
      try {
        client.disconnect();
      } catch (_) {}
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      markUnavailable('MQTT connection not established.');
      return;
    }

    client.subscribe(topic, MqttQos.atLeastOnce);
    _subscription = client.updates?.listen(_handleMessages);
    markAvailable();
  }

  void _handleConnected() {
    markAvailable();
  }

  void _handleDisconnected() {
    markUnavailable('MQTT disconnected.');
  }

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      final message = event.payload as MqttPublishMessage;
      final payloadBytes = message.payload.message;
      final payload = utf8.decode(payloadBytes);
      try {
        final packet = TransportPacket.fromJson(payload);
        emitPacket(packet);
      } catch (_) {
        emitPacket(TransportPacket(
          senderId: 'legacy_mqtt',
          type: SosPacketType.data,
          payload: {'raw': payload},
        ));
      }
    }
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> broadcast(String message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  Future<void> connect(String peerId) async {
    // MQTT uses brokered connections; no direct peer connection required.
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _client?.disconnect();
    _client = null;
    await super.dispose();
  }

  @override
  TransportDescriptor get descriptor => kDescriptor;
}
