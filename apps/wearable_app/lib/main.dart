import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_ui/widgets/big_red_button.dart';
import 'package:sos_transports/sos_transports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WearableApp());
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

class WearableApp extends StatelessWidget {
  const WearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resgate SOS Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.red,
      ),
      home: const WatchScreen(),
    );
  }
}

class HealthDisplay extends StatelessWidget {
  final HealthVitals vitals;
  const HealthDisplay({super.key, required this.vitals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 12),
            const SizedBox(width: 4),
            Text("${vitals.heartRate} BPM",
                style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 8),
            const Icon(Icons.water_drop, color: Colors.blue, size: 12),
            const SizedBox(width: 4),
            Text("${vitals.spo2}%", style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen>
    with TickerProviderStateMixin {
  final TelemetryService _telemetry = TelemetryService.instance;
  final _core = SosCore();
  final _health = HealthService.instance;
  MeshService? _meshService;
  bool _ready = false;
  HealthVitals? _latestVitals;

  late AnimationController _longPressController;
  bool _isPressing = false;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _initTelemetry();
    _init();
    _longPressController = AnimationController(
// ... (trimmed for conciseness in thought, but I'll provide full replacement below)
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerSos();
          _longPressController.reset();
        }
      });
  }

  @override
  void dispose() {
    _longPressController.dispose();
    _mockTimer?.cancel();
    _health.stopMonitoring();
    super.dispose();
  }

  Future<void> _initTelemetry() async {
    await _telemetry.initialize(
      app: 'wearable_app',
      edition: EditionConfig.label,
      endpoint: _resolveTelemetryEndpoint(),
      retentionDays: 7,
    );
    await _telemetry.logEvent('app_start', data: {
      'edition': EditionConfig.label,
      'platform': 'wear',
    });
  }

  Future<void> _init() async {
    try {
      final profile = await HardwareProfile.detect();
      final meshService = MeshService(
        core: _core,
        transport: HybridTransport(activation: profile.activation),
      );
      _meshService = meshService;
      await meshService.initialize(displayName: 'Wear OS');

      // Init health monitoring
      _health.initialize(meshService);
      _health.startMonitoring();
      _health.vitalsStream.listen((v) {
        if (mounted) setState(() => _latestVitals = v);
      });
      _startMockVitals();

      if (mounted) setState(() => _ready = true);
      _telemetry.setNodeId(_core.publicKey);
    } catch (e) {
      _telemetry.logEvent('mesh_error', data: {'error': e.toString()});
    }
  }

  void _startMockVitals() {
    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final v = HealthVitals(
        heartRate: 70 + (timer.tick % 5),
        spo2: 98 - (timer.tick % 2),
        timestamp: DateTime.now(),
      );
      _health.updateVitals(v);
    });
  }

  void _simulateHypoxia() {
    _health.updateVitals(HealthVitals(
      heartRate: 110,
      spo2: 85,
      timestamp: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Simulando Hipóxia (SpO2 85%)")),
    );
  }

  void _triggerSos() {
    HapticFeedback.vibrate();
    _telemetry.logEvent('sos_broadcast', data: {'source': 'wear_long_press'});
    _meshService?.broadcastSos(message: 'SOS Watch LongPress');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS ENVIADO', textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPressStart() {
    setState(() => _isPressing = true);
    _longPressController.forward();
    _progressiveHaptics();
  }

  void _onPressEnd() {
    setState(() => _isPressing = false);
    _longPressController.reset();
  }

  Future<void> _progressiveHaptics() async {
    while (_isPressing && _longPressController.isAnimating) {
      await HapticFeedback.selectionClick();
      await Future.delayed(Duration(
          milliseconds: (500 - (_longPressController.value * 400)).toInt()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        final isRound = shape == WearShape.round;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: isRound ? const EdgeInsets.all(12) : EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_latestVitals != null) ...[
                    HealthDisplay(vitals: _latestVitals!),
                    const SizedBox(height: 8),
                  ],
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _longPressController.value,
                          strokeWidth: 6,
                          color: Colors.red,
                          backgroundColor: Colors.grey.withAlpha(51),
                        ),
                      ),
                      GestureDetector(
                        onLongPressStart: (_) => _onPressStart(),
                        onLongPressEnd: (_) => _onPressEnd(),
                        onLongPressCancel: () => _onPressEnd(),
                        onDoubleTap:
                            _simulateHypoxia, // Hidden feature for testing
                        child: _ready
                            ? BigRedButton(onPressed: () {
                                // Short press just vibrates as a hint
                                HapticFeedback.lightImpact();
                              })
                            : const CircularProgressIndicator(
                                color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPressing
                        ? "SEGURE..."
                        : (_ready ? "SEGURE PARA SOS" : "CARREGANDO"),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (!isRound) const SizedBox(height: 4),
                  Text(
                    EditionConfig.label.toUpperCase(),
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
