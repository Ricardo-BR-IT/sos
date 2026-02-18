/// transport_status.dart

enum TransportConnectionState {
  online,
  offline,
  connecting,
  error,
}

class TransportStatus {
  final TransportConnectionState state;
  final int connectedNodes;
  final int messagesPerMinute;
  final int errorCount;
  final String? message;

  const TransportStatus({
    required this.state,
    this.connectedNodes = 0,
    this.messagesPerMinute = 0,
    this.errorCount = 0,
    this.message,
  });

  static const offline =
      TransportStatus(state: TransportConnectionState.offline);
  static const online = TransportStatus(state: TransportConnectionState.online);
  static const connecting =
      TransportStatus(state: TransportConnectionState.connecting);
  static const error = TransportStatus(state: TransportConnectionState.error);

  TransportStatus copyWith({
    TransportConnectionState? state,
    int? connectedNodes,
    int? messagesPerMinute,
    int? errorCount,
    String? message,
  }) {
    return TransportStatus(
      state: state ?? this.state,
      connectedNodes: connectedNodes ?? this.connectedNodes,
      messagesPerMinute: messagesPerMinute ?? this.messagesPerMinute,
      errorCount: errorCount ?? this.errorCount,
      message: message ?? this.message,
    );
  }
}
