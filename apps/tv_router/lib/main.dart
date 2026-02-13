import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_ui/widgets/big_red_button.dart';
import 'package:sos_transports/sos_transports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final core = SosCore();
  runApp(TvRouterApp(core: core));
}

Uri? _resolveTelemetryEndpoint() {
  const value =
      String.fromEnvironment('SOS_TELEMETRY_ENDPOINT', defaultValue: '');
  if (value.trim().isEmpty) return null;
  try {
    return Uri.parse(value.trim());
  } catch (_) {
    return null;
  }
}

class TvRouterApp extends StatefulWidget {
  final SosCore core;
  const TvRouterApp({Key? key, required this.core}) : super(key: key);

  @override
  State<TvRouterApp> createState() => _TvRouterAppState();
}

class _TvRouterAppState extends State<TvRouterApp> {
  final TelemetryService _telemetry = TelemetryService.instance;
  MeshService? _meshService;
  HardwareProfile? _hardwareProfile;
  bool _ready = false;
  String _status = 'Inicializando...';
  Offset _uiOffset = Offset.zero;
  Timer? _burnInTimer;

  @override
  void initState() {
    super.initState();
    _initTelemetry();
    _initMesh();
    _startBurnInProtection();
  }

  @override
  void dispose() {
    _burnInTimer?.cancel();
    super.dispose();
  }

  void _startBurnInProtection() {
    // Shift UI slightly every 10 minutes to prevent burn-in
    _burnInTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (mounted) {
        setState(() {
          _uiOffset = Offset(
            (DateTime.now().minute % 3 - 1).toDouble(),
            (DateTime.now().second % 3 - 1).toDouble(),
          );
        });
      }
    });
  }

  Future<void> _initTelemetry() async {
    await _telemetry.initialize(
      app: 'tv_router',
      edition: EditionConfig.label,
      endpoint: _resolveTelemetryEndpoint(),
      retentionDays: 7,
    );
    await _telemetry.logEvent('app_start', data: {
      'edition': EditionConfig.label,
      'platform': 'tv',
    });
  }

  Future<void> _initMesh() async {
    try {
      final profile = await HardwareProfile.detect();
      _hardwareProfile = profile;
      final meshService = MeshService(
        core: widget.core,
        transport: HybridTransport(activation: profile.activation),
      );
      _meshService = meshService;
      await _telemetry.logEvent('hardware_profile', data: {
        'flags': profile.flags,
        'transports': profile.transports,
        'interfaces': profile.interfaces,
        'sources': profile.sources,
      });
      await meshService.initialize(displayName: 'TV Router');
      if (!mounted) return;
      setState(() {
        _ready = true;
        _status = 'Mesh online';
      });
      _telemetry.setNodeId(widget.core.publicKey);
      _telemetry.logEvent('mesh_ready', data: _transportSnapshot());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Erro: $e';
      });
      _telemetry.logEvent('mesh_error', data: {'error': e.toString()});
    }
  }

  Map<String, dynamic> _transportSnapshot() {
    final meshService = _meshService;
    if (meshService == null) return {};
    final transport = meshService.transport;
    if (transport is TransportBroadcaster) {
      final broadcaster = transport as TransportBroadcaster;
      final health = broadcaster.healthSnapshot.map((key, value) => MapEntry(
            key,
            {
              'availability': value.availability.name,
              'errorCount': value.errorCount,
              'lastError': value.lastError,
            },
          ));
      final metrics = broadcaster.metricsSnapshot.map((key, value) => MapEntry(
            key,
            {
              'sent': value.sent,
              'received': value.received,
              'errors': value.errors,
            },
          ));
      return {
        'health': health,
        'metrics': metrics,
      };
    }
    return {};
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    final meshService = _meshService;
    return MaterialApp(
      title: 'Resgate SOS TV Router',
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 24),
          bodySmall: TextStyle(fontSize: 18),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Resgate SOS TV Router',
              style: TextStyle(fontSize: 32)),
          centerTitle: true,
        ),
        body: Transform.translate(
          offset: _uiOffset,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _ready
                      ? 'Nó Ativo: ${_shortId(widget.core.publicKey)}...'
                      : _status,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Edição: ${EditionConfig.label.toUpperCase()} • ${TechRegistry.all.length} Tecnologias',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 60),
                BigRedButton(
                  autofocus: true,
                  onPressed: () async {
                    _telemetry.logEvent('sos_broadcast', data: {
                      'source': 'tv',
                    });
                    if (meshService == null) return;
                    await meshService.broadcastSos(message: 'SOS TV Router');
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pressione OK para Emergência',
                  style: TextStyle(color: Colors.redAccent, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
