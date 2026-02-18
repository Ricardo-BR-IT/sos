import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:sos_transports/sos_transports.dart';

import 'package:desktop_station/widgets/transport_dashboard.dart';

class _FakeTransport extends BaseTransport {
  String? _localId;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) => _localId = id;

  @override
  TransportDescriptor get descriptor => const TransportDescriptor(
        id: 'fake',
        name: 'Fake',
        technologyIds: [],
        mediums: [],
      );

  @override
  Future<void> initialize() async {}

  @override
  Future<void> send(TransportPacket packet) async {}

  @override
  Future<void> broadcast(String message) async {}

  Future<void> toggle() async {}

  @override
  bool get isEnabled => true;

  @override
  Future<void> connect(String peerId) async {}
}

void main() {
  testWidgets('TransportDashboard renders', (WidgetTester tester) async {
    final mesh = MeshService(core: SosCore(), transport: _FakeTransport());
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TransportDashboard(
          meshService: mesh,
          statusText: 'Ready',
          onSosPressed: () async {},
        ),
      ),
    ));

    expect(find.byType(TransportDashboard), findsOneWidget);
  });
}
