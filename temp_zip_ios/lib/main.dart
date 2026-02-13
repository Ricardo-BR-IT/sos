import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/manual_localizations.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_ui/widgets/big_red_button.dart';
import 'package:sos_calls/sos_calls.dart';
import 'package:sos_transports/sos_transports.dart'; // Exporting HybridTransport?

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MobileApp(core: SosCore()));
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

class MobileApp extends StatefulWidget {
  final SosCore core;
  const MobileApp({Key? key, required this.core}) : super(key: key);

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  final TelemetryService _telemetry = TelemetryService.instance;
  MeshService? _meshService;
  HardwareProfile? _hardwareProfile;
  bool _isMeshReady = false;
  // Initialize with a key that we can translate later or handle in build
  String _statusKey = "initializingSecurity";
  String _errorMsg = "";
  final List<SosEnvelope> _messages = [];
  final List<MeshPeer> _peers = [];

  @override
  void initState() {
    super.initState();
    _initTelemetry();
    _initMesh();
  }

  Future<void> _initTelemetry() async {
    await _telemetry.initialize(
      app: 'mobile_app',
      edition: EditionConfig.label,
      endpoint: _resolveTelemetryEndpoint(),
      retentionDays: 7,
    );
    await _telemetry.logEvent(
      'app_start',
      data: {
        'edition': EditionConfig.label,
        'platform': 'mobile',
      },
    );
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
      await meshService.initialize(displayName: 'Mobile');
      if (mounted) {
        setState(() {
          _isMeshReady = true;
          _statusKey = "secureIdentityLoaded";
        });
      }
      _telemetry.setNodeId(widget.core.publicKey);
      _telemetry.logEvent('mesh_ready', data: _transportSnapshot());
      meshService.messages.listen((message) {
        if (!mounted) return;
        setState(() {
          _messages.insert(0, message);
          if (_messages.length > 50) _messages.removeLast();
        });
        _telemetry.logEvent('mesh_message', data: {
          'type': message.type,
          'sender': _shortId(message.sender),
        });
      });
      meshService.peerUpdates.listen((peer) {
        if (!mounted) return;
        setState(() {
          final idx = _peers.indexWhere((p) => p.id == peer.id);
          if (idx == -1) {
            _peers.add(peer);
          } else {
            _peers[idx] = peer;
          }
        });
        _telemetry.logEvent('peer_update', data: {
          'peer': _shortId(peer.id),
          'platform': peer.platform,
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusKey = "error";
          _errorMsg = e.toString();
        });
      }
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
    if (value.length <= 10) return value;
    return value.substring(0, 10);
  }

  String _getStatusText(AppLocalizations l10n) {
    if (_statusKey == "initializingSecurity") return l10n.initializingSecurity;
    if (_statusKey == "secureIdentityLoaded") return l10n.secureIdentityLoaded;
    if (_statusKey == "error") return "${l10n.error} $_errorMsg";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resgate SOS Mobile',
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
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isMeshReady
                      ? '${l10n.activeNode} ${widget.core.publicKey.substring(0, 12)}...'
                      : _getStatusText(l10n),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Edição: ${EditionConfig.label} • Tecnologias: ${TechRegistry.all.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _isMeshReady && meshService != null
                    ? Column(
                        children: [
                          BigRedButton(
                            onPressed: () async {
                              _telemetry.logEvent('sos_broadcast', data: {
                                'source': 'mobile',
                              });
                              await meshService.broadcastSos(
                                message: 'SOS Mobile',
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.video_call),
                            label: const Text("Start Secure Call"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            onPressed: () {
                              if (_peers.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Nenhum peer detectado na mesh.'),
                                  ),
                                );
                                return;
                              }
                              final targetId = _peers.first.id;
                              final signaling =
                                  CallSignaling(mesh: meshService);
                              _telemetry.logEvent('call_start', data: {
                                'target': _shortId(targetId),
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CallScreen(
                                    signaling: signaling,
                                    targetId: targetId,
                                    isCaller: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text('Peers: ${_peers.length}'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              itemCount: _peers.length,
                              itemBuilder: (context, index) {
                                final peer = _peers[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(peer.name),
                                  subtitle: Text(
                                    '${peer.platform} • ${peer.id.substring(0, 10)}...',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Mensagens: ${_messages.length}'),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(msg.type),
                                  subtitle: Text(
                                    msg.sender.substring(0, 10) + '...',
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
