import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sos_transports/sos_transports.dart';

/// Gerenciador de fila de mensagens para persistência offline (Store-and-Forward).
/// Garante que mensagens não sejam perdidas quando não há conectividade imediata.
class MessageQueueManager {
  static const String _queueFileName = 'sos_message_queue.json';

  final List<TransportPacket> _queue = [];
  final StreamController<TransportPacket> _retryController =
      StreamController.broadcast();
  Timer? _retryTimer;

  Stream<TransportPacket> get onRetry => _retryController.stream;

  Future<void> initialize() async {
    await _loadQueue();
    _startRetryLoop();
  }

  /// Adiciona um pacote à fila de espera.
  Future<void> enqueue(TransportPacket packet) async {
    // Evitar duplicatas se o ID for o mesmo
    if (_queue.any((p) => p.id == packet.id)) {
      return;
    }

    _queue.add(packet);
    await _saveQueue();
  }

  /// Remove um pacote da fila (chamado após envio bem-sucedido).
  Future<void> dequeue(TransportPacket packet) async {
    _queue.removeWhere((p) => p.id == packet.id);
    await _saveQueue();
  }

  /// Retorna as mensagens pendentes.
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

  Future<void> _saveQueue() async {
    try {
      final file = await _getQueueFile();
      final data = _queue.map((p) => p.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      // Ignorar erro de persistência em ambiente restrito
    }
  }

  Future<void> _loadQueue() async {
    try {
      final file = await _getQueueFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List data = jsonDecode(content);
        _queue.clear();
        for (final item in data) {
          _queue.add(TransportPacket.fromJson(
              item is String ? item : jsonEncode(item)));
        }
      }
    } catch (e) {
      // Começar fila vazia em caso de erro
    }
  }

  Future<File> _getQueueFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_queueFileName');
  }

  void dispose() {
    _retryTimer?.cancel();
    _retryController.close();
  }
}
