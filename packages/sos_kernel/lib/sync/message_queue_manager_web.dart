import 'dart:async';
import 'package:sos_transports/sos_transports.dart';

class MessageQueueManager {
  final List<TransportPacket> _queue = [];
  final StreamController<TransportPacket> _retryController =
      StreamController.broadcast();
  Timer? _retryTimer;

  Stream<TransportPacket> get onRetry => _retryController.stream;

  Future<void> initialize() async {
    _startRetryLoop();
  }

  Future<void> enqueue(TransportPacket packet) async {
    if (_queue.any((p) => p.id == packet.id)) {
      return;
    }
    _queue.add(packet);
    // In-memory only for web for now, or could use LocalStorage
  }

  Future<void> dequeue(TransportPacket packet) async {
    _queue.removeWhere((p) => p.id == packet.id);
  }

  List<TransportPacket> get pendingMessages => List.unmodifiable(_queue);

  void _startRetryLoop() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_queue.isNotEmpty) {
        for (final packet in _queue) {
          _retryController.add(packet);
        }
      }
    });
  }

  void dispose() {
    _retryTimer?.cancel();
    _retryController.close();
  }
}
