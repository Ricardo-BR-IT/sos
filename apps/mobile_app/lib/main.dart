import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/manual_localizations.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_ui/widgets/big_red_button.dart';

import 'package:sos_transports/sos_transports.dart';
import 'screens/chat_screen.dart';
import 'screens/identity_screen.dart';

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
  String _statusKey = "initializingSecurity";
  String _errorMsg = "";
  final List<SosEnvelope> _messages = [];
  final List<MeshPeer> _peers = [];
  final Set<String> _verifiedPeers = {}; // Trusted peers

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

  void _openChat(MeshPeer peer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          mesh: _meshService!,
          targetId: peer.id,
          targetName: peer.name,
        ),
      ),
    );
  }

  Future<void> _openIdentity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdentityScreen(
          core: widget.core,
          mesh: _meshService!,
        ),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _verifiedPeers.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Peer Verified: ${_shortId(result)}'),
            backgroundColor: Colors.green),
      );
    }
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
        Locale('pt'),
      ],
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final meshService = _meshService;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              if (_isMeshReady)
                IconButton(
                  icon: const Icon(Icons.qr_code_2),
                  onPressed: _openIdentity,
                  tooltip: 'Identity & Verify',
                ),
            ],
          ),
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
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Column(
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
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    const Text('PEERS DETECTADOS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    const Spacer(),
                                    Text('${_peers.length}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _peers.length,
                                itemBuilder: (context, index) {
                                  final peer = _peers[index];
                                  final isVerified =
                                      _verifiedPeers.contains(peer.id);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isVerified
                                          ? Colors.green
                                          : Colors.grey[800],
                                      child: Icon(
                                          isVerified
                                              ? Icons.security
                                              : Icons.person,
                                          color: Colors.white),
                                    ),
                                    title: Text(peer.name,
                                        style: TextStyle(
                                            color: isVerified
                                                ? Colors.greenAccent
                                                : null)),
                                    subtitle: Text(
                                      '${peer.platform} • ${_shortId(peer.id)}',
                                    ),
                                    trailing:
                                        const Icon(Icons.chat_bubble_outline),
                                    onTap: () => _openChat(peer),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('LOG DA MESH',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(msg.type),
                                    subtitle: Text(
                                      _shortId(msg.sender),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    trailing: Text(msg.payload
                                        .toString()
                                        .substring(
                                            0,
                                            msg.payload.toString().length > 20
                                                ? 20
                                                : msg.payload
                                                    .toString()
                                                    .length)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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
