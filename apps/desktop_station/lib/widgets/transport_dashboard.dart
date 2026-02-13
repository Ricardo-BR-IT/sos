import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_transports/sos_transports.dart';
import 'package:sos_ui/widgets/big_red_button.dart';

class TransportDashboard extends StatefulWidget {
  final MeshService meshService;
  final String statusText;
  final Future<void> Function() onSosPressed;

  const TransportDashboard({
    super.key,
    required this.meshService,
    required this.statusText,
    required this.onSosPressed,
  });

  @override
  State<TransportDashboard> createState() => _TransportDashboardState();
}

class _TransportDashboardState extends State<TransportDashboard> {
  final List<MeshPeer> _peers = [];
  final List<SosEnvelope> _messages = [];
  late TechCoverageReport _coverageReport;
  final TextEditingController _filterController = TextEditingController();
  String _filter = '';
  bool _diagnosticsRunning = false;
  List<DiagnosticResult> _diagnosticResults = [];

  @override
  void initState() {
    super.initState();
    _coverageReport = TechCoverageService(
      platform: Platform.operatingSystem,
    ).build();
    widget.meshService.peerUpdates.listen((peer) {
      if (!mounted) return;
      setState(() {
        final idx = _peers.indexWhere((p) => p.id == peer.id);
        if (idx == -1) {
          _peers.add(peer);
        } else {
          _peers[idx] = peer;
        }
      });
    });
    widget.meshService.messages.listen((msg) {
      if (!mounted) return;
      setState(() {
        _messages.insert(0, msg);
        if (_messages.length > 100) _messages.removeLast();
      });
    });
    _filterController.addListener(() {
      if (!mounted) return;
      setState(() {
        _filter = _filterController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.statusText,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: BigRedButton(
                    onPressed: () async {
                      await widget.onSosPressed();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const TabBar(
                  tabs: [
                    Tab(text: 'Rede'),
                    Tab(text: 'Tecnologias'),
                    Tab(text: 'Diagnóstico'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildNetworkTab(isWide),
                      _buildTechTab(),
                      _buildDiagnosticsTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkTab(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peers detectados: ${_peers.length}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _buildPeerList()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMessageList()),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: _buildPeerList()),
                    const SizedBox(height: 16),
                    Expanded(child: _buildMessageList()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTechTab() {
    final filtered = _coverageReport.entries.where((entry) {
      if (_filter.isEmpty) return true;
      final text = '${entry.tech.name} ${entry.tech.id} '
              '${entry.tech.category.name} ${entry.tech.status.name}'
          .toLowerCase();
      return text.contains(_filter);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _filterController,
                decoration: const InputDecoration(
                  hintText: 'Filtrar tecnologia, id ou categoria...',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Nativas: ${_coverageReport.nativeCount} • '
              'Gateway: ${_coverageReport.gatewayCount} • '
              'Indisponíveis: ${_coverageReport.unavailableCount}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final entry = filtered[index];
                final transports =
                    entry.transports.map((t) => t.id).take(3).join(', ');
                return ListTile(
                  title: Text(entry.tech.name),
                  subtitle: Text(
                    '${entry.tech.id} • ${entry.tech.category.name} • ${entry.tech.status.name}',
                  ),
                  trailing: Text(
                    '${entry.binding.name}'
                    '${transports.isNotEmpty ? ' • $transports' : ''}',
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsTab() {
    final transportMetrics = _snapshotTransportMetrics();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _diagnosticsRunning ? null : _runDiagnostics,
              child:
                  Text(_diagnosticsRunning ? 'Executando...' : 'Rodar teste'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _exportTelemetry,
              child: const Text('Exportar Telemetria'),
            ),
            const SizedBox(width: 16),
            Text('Resultados: ${_diagnosticResults.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (transportMetrics.isNotEmpty)
          Text(
            'Transportes ativos: ${transportMetrics.keys.join(', ')}',
          ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: _diagnosticResults.length,
              itemBuilder: (context, index) {
                final result = _diagnosticResults[index];
                return ListTile(
                  title: Text('Transport: ${result.transportId}'),
                  subtitle: Text(
                    'Peer ${result.peerId.substring(0, 8)} • '
                    'RTT (Min/Avg/Max): ${result.minRtt.inMilliseconds}/${result.avgRtt.inMilliseconds}/${result.maxRtt.inMilliseconds} ms • '
                    'Jitter: ${result.jitter.inMilliseconds} ms • '
                    'Perda: ${result.lossPercentage.toStringAsFixed(1)}%',
                  ),
                  trailing: Icon(
                    result.lossPercentage > 20
                        ? Icons.warning
                        : Icons.check_circle,
                    color: result.lossPercentage > 20
                        ? Colors.orange
                        : Colors.green,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportTelemetry() async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final path =
          '${root.path}/sos_telemetry_export_${DateTime.now().millisecondsSinceEpoch}.jsonl';
      await TelemetryService.instance.exportLocalTelemetry(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telemetria exportada para: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  Map<String, TransportMetrics> _snapshotTransportMetrics() {
    final transport = widget.meshService.transport;
    if (transport is TransportBroadcaster) {
      final broadcaster = transport as TransportBroadcaster;
      return broadcaster.metricsSnapshot;
    }
    return {};
  }

  Future<void> _runDiagnostics() async {
    setState(() => _diagnosticsRunning = true);
    final diagnostics = MeshDiagnostics(mesh: widget.meshService);
    final results = await diagnostics.run();
    if (!mounted) return;
    setState(() {
      _diagnosticResults = results;
      _diagnosticsRunning = false;
    });
  }

  Widget _buildPeerList() {
    return Card(
      child: ListView.builder(
        itemCount: _peers.length,
        itemBuilder: (context, index) {
          final peer = _peers[index];
          return ListTile(
            title: Text(peer.name),
            subtitle: Text(
              '${peer.platform} • ${peer.id.substring(0, 10)}...'
              '${peer.lastTransportId != null ? ' • ${peer.lastTransportId}' : ''}',
            ),
            trailing: Text(peer.appVersion),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    return Card(
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return ListTile(
            title: Text(msg.type),
            subtitle: Text(
              '${msg.sender.substring(0, 10)}... • ${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).toIso8601String()}',
            ),
          );
        },
      ),
    );
  }
}
