import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/manual_localizations.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_transports/sos_transports.dart';
import 'widgets/transport_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final core = SosCore();
  runApp(DesktopApp(core: core));
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

class DesktopApp extends StatefulWidget {
  final SosCore core;
  const DesktopApp({Key? key, required this.core}) : super(key: key);

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  final TelemetryService _telemetry = TelemetryService.instance;
  MeshService? _meshService;
  HardwareProfile? _hardwareProfile;
  bool _ready = false;
  String _status = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _initTelemetry();
    _initMesh();
  }

  Future<void> _initTelemetry() async {
    await _telemetry.initialize(
      app: 'desktop_station',
      edition: EditionConfig.label,
      endpoint: _resolveTelemetryEndpoint(),
      retentionDays: 7,
    );
    await _telemetry.logEvent('app_start', data: {
      'edition': EditionConfig.label,
      'platform': 'desktop',
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
      await meshService.initialize(displayName: 'Desktop Station');
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
    return MaterialApp(
      title: 'Resgate SOS Desktop',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('hi'),
        Locale('es'),
        Locale('ar'),
        Locale('fr'),
        Locale('bn'),
        Locale('pt'),
        Locale('ru'),
        Locale('id'),
        Locale('ur'),
        Locale('de'),
        Locale('ja'),
        Locale('mr'),
        Locale('vi'),
        Locale('te'),
        Locale('ha'),
        Locale('tr'),
        Locale('sw'),
        Locale('ta'),
        Locale('it'),
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('pt');
        for (final candidate in supported) {
          if (candidate.languageCode == locale.languageCode) {
            return candidate;
          }
        }
        return const Locale('pt');
      },
      theme: ThemeData.dark(),
      home: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final meshService = _meshService;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.appTitle)),
          body: meshService == null
              ? const Center(child: CircularProgressIndicator())
              : TransportDashboard(
                  meshService: meshService,
                  statusText: _ready
                      ? '${l10n.activeNode} ${_shortId(widget.core.publicKey)}... • ${EditionConfig.label} • ${TechRegistry.all.length} techs'
                      : _status,
                  onSosPressed: () async {
                    _telemetry.logEvent('sos_broadcast', data: {
                      'source': 'desktop',
                    });
                    await meshService.broadcastSos(message: 'SOS Desktop');
                  },
                ),
        );
      }),
    );
  }
}
