/// transport_dashboard.dart
/// Transport configuration and status dashboard UI components

import 'package:flutter/material.dart';

import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/transport_status.dart';
import '../models/transport_config.dart';

class TransportDashboard extends StatefulWidget {
  const TransportDashboard({Key? key}) : super(key: key);

  @override
  State<TransportDashboard> createState() => _TransportDashboardState();
}

class _TransportDashboardState extends State<TransportDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _transportEnabled = {};
  final Map<String, TransportStatus> _transportStatus = {};
  final Map<String, TransportConfig> _transportConfig = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeTransports();
    _startStatusUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeTransports() {
    final transports = [
      'bluetooth_le',
      'bluetooth_classic',
      'bluetooth_mesh',
      'wifi_lan',
      'ethernet',
      'lorawan',
      'dtn',
      'secure',
      'webrtc',
      'zigbee',
    ];

    for (final transport in transports) {
      _transportEnabled[transport] = false;
      _transportStatus[transport] = TransportStatus.offline;
      _transportConfig[transport] = TransportConfig.defaultConfig(transport);
    }
  }

  void _startStatusUpdates() {
    // Simulate real-time status updates
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _transportEnabled['wifi_lan'] = true;
        _transportStatus['wifi_lan'] = TransportStatus.online;
      });
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _transportEnabled['bluetooth_le'] = true;
        _transportStatus['bluetooth_le'] = TransportStatus.online;
      });
    });

    Future.delayed(Duration(seconds: 8), () {
      setState(() {
        _transportEnabled['ethernet'] = true;
        _transportStatus['ethernet'] = TransportStatus.online;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Painel de Transportes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _refreshAllTransports,
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: _openGlobalSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOverviewCards(),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Status', icon: Icon(LucideIcons.activity)),
              Tab(text: 'Configuração', icon: Icon(LucideIcons.settings)),
              Tab(text: 'Diagnostics', icon: Icon(LucideIcons.stethoscope)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatusTab(),
                _buildConfigTab(),
                _buildDiagnosticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOverviewCard(
            'Transportes Ativos',
            '${_transportEnabled.values.where((enabled) => enabled).length}',
            LucideIcons.activity,
            Colors.green,
          ),
          _buildOverviewCard(
            'Nós Conectados',
            '${_getTotalConnectedNodes()}',
            LucideIcons.users,
            Colors.blue,
          ),
          _buildOverviewCard(
            'Mensagens/min',
            '${_getTotalMessagesPerMinute()}',
            LucideIcons.messageSquare,
            Colors.purple,
          ),
          _buildOverviewCard(
            'Taxa de Erro',
            '${_getErrorRate().toStringAsFixed(1)}%',
            Icons.warning_amber,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transportEnabled.length,
      itemBuilder: (context, index) {
        final transportId = _transportEnabled.keys.elementAt(index);
        final isEnabled = _transportEnabled[transportId]!;
        final status = _transportStatus[transportId]!;

        return _buildTransportStatusCard(transportId, isEnabled, status);
      },
    );
  }

  Widget _buildTransportStatusCard(
      String transportId, bool isEnabled, TransportStatus status) {
    final transportInfo = _getTransportInfo(transportId);
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  transportInfo['icon'],
                  color: isEnabled ? statusColor : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transportInfo['name'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        transportId,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _toggleTransport(transportId, value),
                  activeThumbColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(
                          'Plataformas', transportInfo['platforms']),
                      _buildStatusRow('Nós', '${_getNodeCount(transportId)}'),
                      _buildStatusRow(
                          'Mensagens', '${_getMessageCount(transportId)}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transportEnabled.length,
      itemBuilder: (context, index) {
        final transportId = _transportEnabled.keys.elementAt(index);
        final config = _transportConfig[transportId]!;
        final transportInfo = _getTransportInfo(transportId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(transportInfo['icon']),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transportInfo['name'],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildConfigField('Prioridade', config.priority),
                    _buildConfigField(
                        'Timeout', '${config.timeout.inSeconds}s'),
                    _buildConfigField('Retry', '${config.retryAttempts}'),
                    _buildConfigField('Buffer', '${config.bufferSize}KB'),
                    if (config.customParameters.isNotEmpty)
                      _buildCustomParameters(config.customParameters),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _resetConfig(transportId),
                          child: const Text('Resetar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _saveConfig(transportId),
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomParameters(Map<String, dynamic> parameters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parâmetros Personalizados',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...parameters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: entry.value.toString(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiagnosticsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transportEnabled.length,
      itemBuilder: (context, index) {
        final transportId = _transportEnabled.keys.elementAt(index);
        final diagnostics = _getDiagnostics(transportId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.stethoscope,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Diagnostics - ${_getTransportInfo(transportId)['name']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...diagnostics.entries.map((entry) {
                  return _buildDiagnosticItem(entry.key, entry.value);
                }),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _runDiagnostics(transportId),
                  icon: const Icon(LucideIcons.play),
                  label: const Text('Executar Testes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticItem(String test, Map<String, dynamic> result) {
    final status = result['status'] as String;
    final statusColor = status == 'pass'
        ? Colors.green
        : status == 'fail'
            ? Colors.red
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              test,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              status.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (result['message'] != null)
            Expanded(
              flex: 3,
              child: Text(
                result['message'],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTransportInfo(String transportId) {
    final info = {
      'bluetooth_le': {
        'name': 'Bluetooth LE',
        'icon': LucideIcons.bluetooth,
        'platforms': 'Mobile, Wear, Desktop',
      },
      'bluetooth_classic': {
        'name': 'Bluetooth Classic',
        'icon': LucideIcons.bluetooth,
        'platforms': 'Mobile, Desktop',
      },
      'bluetooth_mesh': {
        'name': 'Bluetooth Mesh',
        'icon': LucideIcons.share2,
        'platforms': 'Mobile, Wear',
      },
      'wifi_lan': {
        'name': 'WiFi LAN',
        'icon': LucideIcons.wifi,
        'platforms': 'Mobile, Desktop, TV, Wear',
      },
      'ethernet': {
        'name': 'Ethernet LAN',
        'icon': Icons.cable,
        'platforms': 'Desktop, Server',
      },
      'lorawan': {
        'name': 'LoRa/LoRaWAN',
        'icon': LucideIcons.radio,
        'platforms': 'Desktop, Server',
      },
      'dtn': {
        'name': 'DTN Bundle Protocol',
        'icon': LucideIcons.package,
        'platforms': 'Mobile, Desktop, Server, Java',
      },
      'secure': {
        'name': 'OSCORE/EDHOC',
        'icon': LucideIcons.shield,
        'platforms': 'Mobile, Desktop, Server, Java',
      },
      'webrtc': {
        'name': 'WebRTC',
        'icon': LucideIcons.video,
        'platforms': 'Mobile, Desktop, Web',
      },
      'zigbee': {
        'name': 'Zigbee',
        'icon': Icons.router, // Fallback to Material
        'platforms': 'IoT',
      },
    };

    return info[transportId] ??
        {
          'name': 'Unknown',
          'icon': Icons.help_outline, // Fallback to Material
          'platforms': 'Unknown',
        };
  }

  Color _getStatusColor(TransportStatus status) {
    switch (status.state) {
      case TransportConnectionState.online:
        return Colors.green;
      case TransportConnectionState.offline:
        return Colors.red;
      case TransportConnectionState.connecting:
        return Colors.orange;
      case TransportConnectionState.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(TransportStatus status) {
    switch (status.state) {
      case TransportConnectionState.online:
        return 'Online';
      case TransportConnectionState.offline:
        return 'Offline';
      case TransportConnectionState.connecting:
        return 'Conectando';
      case TransportConnectionState.error:
        return 'Erro';
      default:
        return 'Desconhecido';
    }
  }

  int _getTotalConnectedNodes() {
    return _transportStatus.values
        .where((status) => status.state == TransportConnectionState.online)
        .fold(0, (sum, status) => sum + status.connectedNodes);
  }

  int _getTotalMessagesPerMinute() {
    return _transportStatus.values
        .fold(0, (sum, status) => sum + status.messagesPerMinute);
  }

  double _getErrorRate() {
    final totalMessages = _getTotalMessagesPerMinute();
    final totalErrors = _transportStatus.values
        .fold(0, (sum, status) => sum + status.errorCount);

    return totalMessages > 0 ? (totalErrors / totalMessages) * 100 : 0.0;
  }

  int _getNodeCount(String transportId) {
    return _transportStatus[transportId]?.connectedNodes ?? 0;
  }

  int _getMessageCount(String transportId) {
    return _transportStatus[transportId]?.messagesPerMinute ?? 0;
  }

  Map<String, dynamic> _getDiagnostics(String transportId) {
    // Simulated diagnostic results
    return {
      'Conectividade': {
        'status': 'pass',
        'message': 'Conexão estabelecida com sucesso'
      },
      'Handshake': {'status': 'pass', 'message': 'Handshake completo'},
      'Throughput': {
        'status': 'pass',
        'message': 'Throughput dentro do esperado'
      },
      'Latência': {'status': 'pass', 'message': 'Latência < 100ms'},
      'Segurança': {'status': 'pass', 'message': 'Criptografia funcionando'},
    };
  }

  void _toggleTransport(String transportId, bool enabled) {
    setState(() {
      _transportEnabled[transportId] = enabled;
      if (enabled) {
        _transportStatus[transportId] = TransportStatus.connecting;
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _transportStatus[transportId] = TransportStatus.online;
          });
        });
      } else {
        _transportStatus[transportId] = TransportStatus.offline;
      }
    });
  }

  void _refreshAllTransports() {
    // Simulate refresh
    for (final transportId in _transportEnabled.keys) {
      if (_transportEnabled[transportId]!) {
        setState(() {
          _transportStatus[transportId] = TransportStatus.connecting;
        });

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _transportStatus[transportId] = TransportStatus.online;
          });
        });
      }
    }
  }

  void _openGlobalSettings() {
    // Open global settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações Globais'),
        content: const Text('Configurações globais do sistema de transportes'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _resetConfig(String transportId) {
    setState(() {
      _transportConfig[transportId] =
          TransportConfig.defaultConfig(transportId);
    });
  }

  void _saveConfig(String transportId) {
    // Save configuration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração salva com sucesso')),
    );
  }

  void _runDiagnostics(String transportId) {
    // Run diagnostics
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Executando diagnósticos para ${_getTransportInfo(transportId)['name']}')),
    );
  }
}
