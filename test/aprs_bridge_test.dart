import 'package:flutter_test/flutter_test.dart';
import 'package:sos_transports/sos_transports.dart';
import 'package:sos_transports/transport/aprs_bridge_transport.dart';

void main() {
  group('AprsBridgeTransport', () {
    late AprsBridgeTransport transport;

    setUp(() {
      transport = AprsBridgeTransport(
        callsign: 'TEST-1',
        passcode: '-1',
        useInternet: false,
        useRadio: false,
      );
    });

    tearDown(() async {
      await transport.dispose();
    });

    test('descriptor contract is stable', () {
      expect(transport.descriptor.id, equals('aprs_bridge'));
      expect(transport.descriptor.name, equals('HAM/APRS Bridge'));
      expect(transport.descriptor.technologyIds, contains('ham_aprs'));
      expect(transport.descriptor.mediums, contains('radio'));
      expect(transport.descriptor.mediums, contains('internet'));
      expect(transport.descriptor.requiresGateway, isTrue);
    });

    test('initialize mock mode and basic status', () async {
      await transport.initialize();
      expect(transport.isAvailable, isTrue);

      final status = transport.getAprsStatus();
      expect(status['callsign'], equals('TEST-1'));
      expect(status['useInternet'], isFalse);
      expect(status['useRadio'], isFalse);
      expect(status['stations'], isA<int>());
      expect(status['messages'], isA<int>());
      expect(status['stationsList'], isA<List>());
    });

    test('format latitude/longitude', () {
      expect(transport.formatLatitude(23.5092), equals('2330.55N'));
      expect(transport.formatLatitude(-23.5092), equals('2330.55S'));
      expect(transport.formatLongitude(46.6530), equals('04639.18E'));
      expect(transport.formatLongitude(-46.6530), equals('04639.18W'));
    });

    test('send helpers should not throw in mock mode', () async {
      await transport.initialize();
      await transport.broadcast('mesh online');
      await transport.send(TransportPacket(
        senderId: 'TEST-1',
        recipientId: 'SOS-2',
        type: SosPacketType.data,
        payload: {'message': 'direct'},
      ));
      await transport.sendPosition(-23.5092, -46.6530, comment: 'node');
      await transport.sendTelemetry(
        [100, 200, 300, 400, 500],
        ['V', 'A', 'W', 'T', 'H'],
      );
      await transport.sendEmergencyAlert('MEDICAL', 'Need evacuation');
      expect(transport.isAvailable, isTrue);
    });
  });

  group('AprsPacket parsing', () {
    test('position packet', () {
      const raw = 'PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_SOS Mesh Node Active';
      final parsed = AprsPacket.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.source, equals('PY1ABC'));
      expect(parsed.destination, equals('APRS'));
      expect(parsed.type, equals(AprsDataType.position));
      expect(parsed.position, contains('2330.55S/04639.18W'));
    });

    test('message packet', () {
      const raw = 'PY1ABC>APRS,TCPIP*:SOS-1     :Emergency response needed';
      final parsed = AprsPacket.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(AprsDataType.message));
      expect(parsed.destination, equals('SOS-1'));
      expect(parsed.message, isNotNull);
      expect(parsed.message!.destination, equals('SOS-1'));
      expect(parsed.message!.text, equals('Emergency response needed'));
    });

    test('telemetry packet', () {
      const raw = 'PY1ABC>APRS,TCPIP*:T#123,100,200,300,400,500,00000000';
      final parsed = AprsPacket.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(AprsDataType.telemetry));
      expect(parsed.telemetry, isNotNull);
      expect(parsed.telemetry!.sequence, equals(123));
      expect(parsed.telemetry!.values, equals([100, 200, 300, 400, 500]));
    });

    test('malformed packets return null', () {
      const malformed = ['', 'INVALID', 'SRC>DEST', 'SRC>DEST:', 'SRC>DEST:  '];
      for (final raw in malformed) {
        expect(AprsPacket.parse(raw), isNull);
      }
    });
  });

  group('APRS packet generators', () {
    test('message packet generator', () {
      final packet = AprsMessagePacket(
        source: 'TEST-1',
        destination: 'SOS-2',
        text: 'Test message',
      );
      final raw = packet.toAprsString();
      expect(raw, contains('TEST-1>APRS,TCPIP*'));
      expect(raw, contains('SOS-2'));
      expect(raw, contains('Test message'));
    });

    test('telemetry packet generator', () {
      final packet = AprsTelemetryPacket(
        source: 'TEST-1',
        values: [100, 200, 300, 400, 500],
      );
      final raw = packet.toAprsString();
      expect(raw, contains('TEST-1>APRS,TCPIP*'));
      expect(raw, contains('T#'));
      expect(raw, contains('100,200,300,400,500'));
    });

    test('emergency packet generator', () {
      final packet = AprsEmergencyPacket(
        source: 'TEST-1',
        emergencyType: 'MEDICAL',
        description: 'Medical assistance required',
      );
      final raw = packet.toAprsString();
      expect(raw, contains('TEST-1>APRS,TCPIP*'));
      expect(raw, contains('EMERGENCY: MEDICAL - Medical assistance required'));
    });
  });

  group('Data models', () {
    test('AprsStation model', () {
      final station = AprsStation(
        callsign: 'PY1ABC',
        position: '2330.55S/04639.18W',
        status: 'ACTIVE',
        timestamp: DateTime.now(),
        path: const ['APRS', 'TCPIP'],
      );
      expect(station.callsign, equals('PY1ABC'));
      expect(station.path, equals(['APRS', 'TCPIP']));
    });

    test('AprsMessage and AprsTelemetry models', () {
      final msg = AprsMessage(
        id: '1',
        destination: 'SOS-1',
        text: 'hello',
      );
      final tel = AprsTelemetry(
        sequence: 10,
        values: [1, 2, 3, 4, 5],
        labels: const ['a', 'b'],
      );
      expect(msg.text, equals('hello'));
      expect(tel.sequence, equals(10));
      expect(tel.values.length, equals(5));
    });
  });
}
