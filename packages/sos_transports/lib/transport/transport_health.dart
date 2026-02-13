enum TransportAvailability {
  available,
  degraded,
  unavailable,
}

class TransportHealth {
  final TransportAvailability availability;
  final DateTime? lastOkAt;
  final String? lastError;
  final int errorCount;

  const TransportHealth({
    required this.availability,
    this.lastOkAt,
    this.lastError,
    this.errorCount = 0,
  });

  TransportHealth copyWith({
    TransportAvailability? availability,
    DateTime? lastOkAt,
    String? lastError,
    int? errorCount,
  }) {
    return TransportHealth(
      availability: availability ?? this.availability,
      lastOkAt: lastOkAt ?? this.lastOkAt,
      lastError: lastError ?? this.lastError,
      errorCount: errorCount ?? this.errorCount,
    );
  }
}
