class TransportMetrics {
  int sent = 0;
  int received = 0;
  int errors = 0;
  DateTime? lastSendAt;
  DateTime? lastReceiveAt;
  Duration? lastRtt;
  double? lastThroughputKbps;

  TransportMetrics();
}
