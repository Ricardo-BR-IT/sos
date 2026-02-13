/// message_queue_manager.dart
/// Manages offline message queue (store-and-forward) for reliable delivery.

import 'dart:async';
import '../transport/transport_packet.dart';

/// Manages persisted messages that couldn't be delivered immediately.
/// Automatically retries when peers become available.
class MessageQueueManager {
  final Function(TransportPacket)? onRetry;

  static const int maxRetryAttempts = 5;
  static const Duration retryDelay = Duration(seconds: 30);

  Timer? _retryTimer;
  final List<_QueuedMessage> _pendingMessages = [];

  MessageQueueManager({this.onRetry});

  /// Adds a message to the queue if it couldn't be delivered.
  Future<void> queueMessage({
    required String senderId,
    String? recipientId,
    required SosPacketType type,
    required Map<String, dynamic> payload,
    required int ttl,
  }) async {
    _pendingMessages.add(_QueuedMessage(
      senderId: senderId,
      recipientId: recipientId,
      type: type,
      payload: payload,
      ttl: ttl,
    ));
    print('[MessageQueue] Message queued for ${recipientId ?? 'broadcast'}');
  }

  /// Processes all pending messages for a specific recipient.
  Future<void> processPendingMessagesFor(String recipientId) async {
    final messages = _pendingMessages
        .where((m) => m.recipientId == recipientId || recipientId == '*')
        .toList();

    for (final message in messages) {
      await _retryMessage(message);
    }
  }

  /// Retries a single message and removes it if successful.
  Future<void> _retryMessage(_QueuedMessage message) async {
    try {
      final packet = TransportPacket(
        senderId: message.senderId,
        recipientId: message.recipientId,
        type: message.type,
        payload: message.payload,
        ttl: message.ttl,
      );

      if (onRetry != null) {
        onRetry!(packet);
      }

      _pendingMessages.remove(message);
      print('[MessageQueue] Message delivered from queue');
    } catch (e) {
      message.retryCount++;
      if (message.retryCount >= maxRetryAttempts) {
        _pendingMessages.remove(message);
        print('[MessageQueue] Max retries exceeded, dropping message');
      } else {
        print(
            '[MessageQueue] Retry ${message.retryCount}/$maxRetryAttempts: $e');
      }
    }
  }

  /// Starts periodic retry timer for undelivered messages.
  void startRetryTimer() {
    if (_retryTimer != null) return;
    _retryTimer = Timer.periodic(retryDelay, (_) async {
      await _retryPendingMessages();
    });
  }

  /// Stops the retry timer.
  void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Attempts to retry all pending messages.
  Future<void> _retryPendingMessages() async {
    try {
      for (final message in List.from(_pendingMessages)) {
        await _retryMessage(message);
      }
    } catch (e) {
      print('[MessageQueue] Error during retry: $e');
    }
  }

  /// Gets count of pending messages.
  int get pendingMessageCount => _pendingMessages.length;

  /// Clears all pending messages.
  void clearAllPendingMessages() {
    _pendingMessages.clear();
  }

  /// Cleanup resources.
  void dispose() {
    stopRetryTimer();
    _pendingMessages.clear();
  }
}

class _QueuedMessage {
  final String senderId;
  final String? recipientId;
  final SosPacketType type;
  final Map<String, dynamic> payload;
  final int ttl;
  int retryCount;

  _QueuedMessage({
    required this.senderId,
    this.recipientId,
    required this.type,
    required this.payload,
    required this.ttl,
  });
}
