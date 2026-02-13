import 'dart:async';

import 'package:sos_transports/sos_transports.dart';
import '../sos_kernel.dart';

class DiagnosticResult {
  final String transportId;
  final String peerId;
  final Duration minRtt;
  final Duration maxRtt;
  final Duration avgRtt;
  final Duration jitter;
  final double lossPercentage;
  final int samples;
  final int? hops;
  final String? rxTransportId;
  final DateTime timestamp;

  const DiagnosticResult({
    required this.transportId,
    required this.peerId,
    required this.minRtt,
    required this.maxRtt,
    required this.avgRtt,
    required this.jitter,
    required this.lossPercentage,
    required this.samples,
    required this.timestamp,
    this.hops,
    this.rxTransportId,
  });
}

class MeshDiagnostics {
  final MeshService mesh;

  MeshDiagnostics({required this.mesh});

  Future<List<DiagnosticResult>> run({
    Duration timeout = const Duration(seconds: 5),
    int pingCount = 5,
  }) async {
    final diagId =
        '${mesh.core.publicKey}:${DateTime.now().millisecondsSinceEpoch}';
    final resultsByTransportPeer = <String, Map<String, List<int>>>{};
    final pingsSent = <String, int>{};

    final subscription = mesh.messages.listen((envelope) {
      if (envelope.type != 'diag_pong') return;
      final pongId = envelope.payload['diagId']?.toString();
      if (pongId != diagId) return;
      final txTransportId = envelope.payload['txTransportId']?.toString();
      if (txTransportId == null) return;

      final sentAt = envelope.payload['sentAt'] is int
          ? envelope.payload['sentAt'] as int
          : null;
      if (sentAt == null) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final rtt = now - sentAt;

      final peers = resultsByTransportPeer.putIfAbsent(txTransportId, () => {});
      final rtts = peers.putIfAbsent(envelope.sender, () => []);
      rtts.add(rtt);

      // Log sample to telemetry
      TelemetryService.instance.logEvent('diag_sample', data: {
        'diagId': diagId,
        'transportId': txTransportId,
        'peerId': envelope.sender,
        'rtt': rtt,
        'seq': envelope.payload['seq'],
      });
    });

    final transportIds = _availableTransportIds();
    for (final transportId in transportIds) {
      pingsSent[transportId] = pingCount;
      for (int i = 0; i < pingCount; i++) {
        final envelope = await SosEnvelope.sign(
          core: mesh.core,
          type: 'diag_ping',
          payload: {
            'diagId': diagId,
            'sentAt': DateTime.now().millisecondsSinceEpoch,
            'seq': i,
          },
        );

        await mesh.broadcastVia(
          transportId: transportId,
          type: 'diag_ping',
          payload: envelope.toJson(),
          ttl: 1,
        );
        // Small delay between pings in a burst
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    await Future.delayed(timeout);
    await subscription.cancel();

    final finalResults = <DiagnosticResult>[];
    resultsByTransportPeer.forEach((transportId, peerResults) {
      peerResults.forEach((peerId, rtts) {
        if (rtts.isEmpty) return;

        final min = rtts.reduce((a, b) => a < b ? a : b);
        final max = rtts.reduce((a, b) => a > b ? a : b);
        final sum = rtts.reduce((a, b) => a + b);
        final avg = sum / rtts.length;

        // Jitter: average of absolute differences between consecutive RTTs
        double jitterMs = 0;
        if (rtts.length > 1) {
          double diffSum = 0;
          for (int i = 0; i < rtts.length - 1; i++) {
            diffSum += (rtts[i + 1] - rtts[i]).abs();
          }
          jitterMs = diffSum / (rtts.length - 1);
        }

        final sent = pingsSent[transportId] ?? pingCount;
        final loss = ((sent - rtts.length) / sent) * 100.0;

        finalResults.add(DiagnosticResult(
          transportId: transportId,
          peerId: peerId,
          minRtt: Duration(milliseconds: min),
          maxRtt: Duration(milliseconds: max),
          avgRtt: Duration(milliseconds: avg.round()),
          jitter: Duration(milliseconds: jitterMs.round()),
          lossPercentage: loss,
          samples: rtts.length,
          timestamp: DateTime.now(),
        ));
      });
    });

    // Log final result to telemetry
    for (final res in finalResults) {
      TelemetryService.instance.logEvent('diag_final', data: {
        'diagId': diagId,
        'transportId': res.transportId,
        'peerId': res.peerId,
        'avgRtt': res.avgRtt.inMilliseconds,
        'jitter': res.jitter.inMilliseconds,
        'loss': res.lossPercentage,
        'samples': res.samples,
      });
    }

    return finalResults;
  }

  /// Retorna snapshots de saude para UI
  Map<String, TransportHealth> get healthSnapshot {
    final t = mesh.transport;
    if (t is TransportBroadcaster) {
      return (t as TransportBroadcaster).healthSnapshot;
    }
    return {t.descriptor.id: t.health};
  }

  List<String> _availableTransportIds() {
    final t = mesh.transport;
    if (t is TransportBroadcaster) {
      return (t as TransportBroadcaster).descriptors.map((d) => d.id).toList();
    }
    return [t.descriptor.id];
  }
}
