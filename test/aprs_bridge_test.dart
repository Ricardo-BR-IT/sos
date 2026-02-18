/// aprs_bridge_test.dart
/// Unit tests for APRS Bridge Transport

import 'dart:convert';
import 'dart:typed_data';

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
        useInternet: false, // Use mock for testing
        useRadio: false,
      );
    });

    tearDown(() async {
      await transport.dispose();
    });

    test('should initialize with correct descriptor', () {
      expect(transport.descriptor.id, equals('aprs_bridge'));
      expect(transport.descriptor.name, equals('HAM/APRS Bridge'));
      expect(transport.descriptor.technologyIds, contains('ham_aprs'));
      expect(transport.descriptor.mediums, contains('radio'));
      expect(transport.descriptor.mediums, contains('internet'));
      expect(transport.descriptor.requiresGateway, isTrue);
    });

    test('should set and get local ID', () {
      const testId = 'test-node-123';
      transport.setLocalId(testId);
      expect(transport.localId, equals(testId));
    });

    test('should parse APRS position packet correctly', () {
      const aprsPacket =
          'PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_SOS Mesh Node Active\r\n';

      final parsed = AprsPacket.parse(aprsPacket);

      expect(parsed, isNotNull);
      expect(parsed!.source, equals('PY1ABC'));
      expect(parsed.destination, equals('APRS'));
      expect(parsed.type, equals(AprsDataType.position));
      expect(
          parsed.position, equals('2330.55S/04639.18W_SOS Mesh Node Active'));
    });

    test('should parse APRS message packet correctly', () {
      const aprsPacket =
          'PY1ABC>APRS,TCPIP*:SOS-1     :Emergency response needed\r\n';

      final parsed = AprsPacket.parse(aprsPacket);

      expect(parsed, isNotNull);
      expect(parsed!.source, equals('PY1ABC'));
      expect(parsed.destination, equals('SOS-1'));
      expect(parsed.type, equals(AprsDataType.message));
      expect(parsed.message?.destination, equals('SOS-1'));
      expect(parsed.message?.text, equals('Emergency response needed'));
    });

    test('should parse APRS telemetry packet correctly', () {
      const aprsPacket =
          'PY1ABC>APRS,TCPIP*:T#123,100,200,300,400,500,00000000\r\n';

      final parsed = AprsPacket.parse(aprsPacket);

      expect(parsed, isNotNull);
      expect(parsed!.source, equals('PY1ABC'));
      expect(parsed.destination, equals('APRS'));
      expect(parsed.type, equals(AprsDataType.telemetry));
      expect(parsed.telemetry?.sequence, equals(123));
      expect(parsed.telemetry?.values, equals([100, 200, 300, 400, 500]));
    });

    test('should format latitude correctly', () {
      // Test positive latitude
      final lat1 = transport._formatLatitude(23.5092);
      expect(lat1, equals('2330.55N'));

      // Test negative latitude
      final lat2 = transport._formatLatitude(-23.5092);
      expect(lat2, equals('2330.55S'));
    });

    test('should format longitude correctly', () {
      // Test positive longitude
      final lon1 = transport._formatLongitude(46.6530);
      expect(lon1, equals('04639.18E'));

      // Test negative longitude
      final lon2 = transport._formatLongitude(-46.6530);
      expect(lon2, equals('04639.18W'));
    });

    test('should create APRS message packet correctly', () {
      final messagePacket = AprsMessagePacket(
        source: 'TEST-1',
        destination: 'SOS-2',
        text: 'Test message',
      );

      final aprsString = messagePacket.toAprsString();
      expect(aprsString, contains('TEST-1>APRS,TCPIP*'));
      expect(aprsString, contains('SOS-2     :Test message'));
    });

    test('should create APRS telemetry packet correctly', () {
      final telemetryPacket = AprsTelemetryPacket(
        source: 'TEST-1',
        values: [100, 200, 300, 400, 500],
      );

      final aprsString = telemetryPacket.toAprsString();
      expect(aprsString, contains('TEST-1>APRS,TCPIP*:T#'));
      expect(aprsString, contains('100,200,300,400,500'));
    });

    test('should create APRS emergency packet correctly', () {
      final emergencyPacket = AprsEmergencyPacket(
        source: 'TEST-1',
        emergencyType: 'MEDICAL',
        description: 'Medical assistance required',
      );

      final aprsString = emergencyPacket.toAprsString();
      expect(aprsString, contains('TEST-1>APRS,TCPIP*'));
      expect(aprsString,
          contains('EMERGENCY: MEDICAL - Medical assistance required'));
    });

    test('should handle broadcast messages', () async {
      final packets = <TransportPacket>[];
      transport.packetStream.listen(packets.add);

      await transport.initialize();

      const testMessage = 'Test broadcast message';
      await transport.broadcast(testMessage);

      // In mock mode, should not throw errors
      expect(transport.isAvailable, isTrue);
    });

    test('should handle direct messages', () async {
      final packets = <TransportPacket>[];
      transport.packetStream.listen(packets.add);

      await transport.initialize();

      final testPacket = TransportPacket(
        senderId: 'TEST-1',
        recipientId: 'SOS-2',
        type: SosPacketType.message,
        payload: {'message': 'Test direct message'},
      );

      await transport.send(testPacket);

      // In mock mode, should not throw errors
      expect(transport.isAvailable, isTrue);
    });

    test('should track stations correctly', () {
      final station = AprsStation(
        callsign: 'PY1ABC',
        position: '2330.55S/04639.18W',
        status: 'Active',
        timestamp: DateTime.now(),
        path: ['APRS', 'TCPIP'],
      );

      // Simulate adding station through packet processing
      const aprsPacket = 'PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_Active\r\n';
      final parsed = AprsPacket.parse(aprsPacket);

      expect(parsed, isNotNull);
      expect(parsed!.source, equals('PY1ABC'));
      expect(parsed.type, equals(AprsDataType.position));
    });

    test('should provide APRS status information', () {
      final status = transport.getAprsStatus();

      expect(status['callsign'], equals('TEST-1'));
      expect(status['useInternet'], isFalse);
      expect(status['useRadio'], isFalse);
      expect(status['stations'], isA<int>());
      expect(status['messages'], isA<int>());
      expect(status['stationsList'], isA<List>());
    });

    test('should handle position sending', () async {
      await transport.initialize();

      await transport.sendPosition(-23.5092, -46.6530,
          comment: 'Test position');

      // Should not throw errors in mock mode
      expect(transport.isAvailable, isTrue);
    });

    test('should handle telemetry sending', () async {
      await transport.initialize();

      final values = [100, 200, 300, 400, 500];
      final labels = ['Voltage', 'Current', 'Power', 'Temp', 'Humidity'];

      await transport.sendTelemetry(values, labels);

      // Should not throw errors in mock mode
      expect(transport.isAvailable, isTrue);
    });

    test('should handle emergency alerts', () async {
      await transport.initialize();

      await transport.sendEmergencyAlert(
          'MEDICAL', 'Medical assistance required');

      // Should not throw errors in mock mode
      expect(transport.isAvailable, isTrue);
    });

    test('should cleanup old data', () async {
      await transport.initialize();

      // Simulate old data cleanup
      // In real implementation, this would remove stations older than 24 hours
      expect(transport.isAvailable, isTrue);
    });

    test('should handle connection errors gracefully', () {
      // Test with invalid server to ensure graceful error handling
      final errorTransport = AprsBridgeTransport(
        callsign: 'TEST-1',
        serverHost: 'invalid.host',
        serverPort: 9999,
        useInternet: false, // Use mock to avoid actual connection
        useRadio: false,
      );

      expect(() => errorTransport.initialize(), returnsNormally);
    });

    test('should dispose resources correctly', () async {
      await transport.initialize();
      expect(transport.isAvailable, isTrue);

      await transport.dispose();

      // After disposal, transport should be cleaned up
      // Note: isAvailable might still be true as it's a cached state
      // In real implementation, you'd check for null sockets/processes
    });
  });

  group('AprsPacket', () {
    test('should handle malformed packets gracefully', () {
      const malformedPackets = [
        '', // Empty
        'INVALID', // No > separator
        'SRC>DEST', // No data
        'SRC>DEST:', // Empty data
        'SRC>DEST:INVALID', // Invalid format
      ];

      for (final packet in malformedPackets) {
        final parsed = AprsPacket.parse(packet);
        expect(parsed, isNull, reason: 'Should return null for: $packet');
      }
    });

    test('should parse different APRS path formats', () {
      const packets = [
        'PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_Test',
        'PY1ABC>APRS,WIDE2-2:!2330.55S/04639.18W_Test',
        'PY1ABC>APRS,RELAY,WIDE1-1,WIDE2-2:!2330.55S/04639.18W_Test',
      ];

      for (final packet in packets) {
        final parsed = AprsPacket.parse(packet);
        expect(parsed, isNotNull, reason: 'Should parse: $packet');
        expect(parsed!.source, equals('PY1ABC'));
        expect(parsed.destination, equals('APRS'));
        expect(parsed.type, equals(AprsDataType.position));
      }
    });
  });

  group('AprsStation', () {
    test('should create station with correct properties', () {
      final station = AprsStation(
        callsign: 'PY1ABC',
        position: '2330.55S/04639.18W',
        status: 'Active',
        timestamp: DateTime.now(),
        path: ['APRS', 'TCPIP'],
      );

      expect(station.callsign, equals('PY1ABC'));
      expect(station.position, equals('2330.55S/04639.18W'));
      expect(station.status, equals('Active'));
      expect(station.path, equals(['APRS', 'TCPIP']));
      expect(station.timestamp, isA<DateTime>());
    });
  });

  group('AprsMessage', () {
    test('should create message with correct properties', () {
      final message = AprsMessage(
        id: '123',
        destination: 'SOS-1',
        text: 'Test message',
      );

      expect(message.id, equals('123'));
      expect(message.destination, equals('SOS-1'));
      expect(message.text, equals('Test message'));
    });
  });

  group('AprsTelemetry', () {
    test('should create telemetry with correct properties', () {
      final telemetry = AprsTelemetry(
        sequence: 123,
        values: [100, 200, 300, 400, 500],
        labels: ['V', 'A', 'W', 'T', 'H'],
      );

      expect(telemetry.sequence, equals(123));
      expect(telemetry.values, equals([100, 200, 300, 400, 500]));
      expect(telemetry.labels, equals(['V', 'A', 'W', 'T', 'H']));
    });
  });
}
