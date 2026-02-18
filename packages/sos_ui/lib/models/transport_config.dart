/// transport_config.dart

class TransportConfig {
  final String priority;
  final Duration timeout;
  final int retryAttempts;
  final int bufferSize;
  final Map<String, dynamic> customParameters;

  const TransportConfig({
    required this.priority,
    required this.timeout,
    required this.retryAttempts,
    required this.bufferSize,
    this.customParameters = const {},
  });

  factory TransportConfig.defaultConfig(String transportId) {
    return const TransportConfig(
      priority: 'Normal',
      timeout: Duration(seconds: 30),
      retryAttempts: 3,
      bufferSize: 1024,
      customParameters: {},
    );
  }

  TransportConfig copyWith({
    String? priority,
    Duration? timeout,
    int? retryAttempts,
    int? bufferSize,
    Map<String, dynamic>? customParameters,
  }) {
    return TransportConfig(
      priority: priority ?? this.priority,
      timeout: timeout ?? this.timeout,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      bufferSize: bufferSize ?? this.bufferSize,
      customParameters: customParameters ?? this.customParameters,
    );
  }
}
