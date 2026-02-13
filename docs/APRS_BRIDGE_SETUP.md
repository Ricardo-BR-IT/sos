# APRS Bridge Setup Guide

## 📡 Overview

The APRS (Automatic Packet Reporting System) Bridge connects the SOS mesh network to the global amateur radio network, providing worldwide emergency communication capabilities even when internet infrastructure is unavailable.

## 🎯 Features

- **Global Coverage**: Connect to worldwide amateur radio network via APRS-IS
- **Dual Mode**: Internet (APRS-IS) and Radio (TNC) connectivity
- **Emergency Alerts**: Broadcast emergency messages globally
- **Position Tracking**: Share GPS coordinates via APRS
- **Telemetry Support**: Send sensor data via APRS telemetry
- **Message Routing**: Bidirectional message exchange
- **Automatic Beacons**: Periodic position/status updates

## 📋 Prerequisites

### Hardware Requirements
- **Computer**: Windows/Linux/macOS with network access
- **Radio Equipment** (optional): VHF/UHF transceiver + TNC
- **Antenna**: VHF/UHF antenna for radio operation
- **GPS** (optional): GPS receiver for position reporting

### Software Requirements
- **Amateur Radio License**: Required for radio transmission
- **APRS-IS Access**: Internet connection for APRS-IS
- **TNC Software**: Dire Wolf, AGWPE, or hardware TNC (radio mode)

### Legal Requirements
- **Amateur Radio License**: Mandatory for radio operation
- **Frequency Authorization**: Follow local regulations
- **Emergency Protocols**: Understand emergency communication procedures

## 🛠️ Installation

### 1. Internet Mode (APRS-IS)

```dart
import 'package:sos_transports/sos_transports.dart';

final aprsTransport = AprsBridgeTransport(
  callsign: 'YOUR-CALLSIGN',    // Your amateur radio callsign
  passcode: 'YOUR-PASSCODE',    // APRS-IS passcode (generate online)
  serverHost: 'rotate.aprs2.net', // APRS-IS server
  serverPort: 10152,             // APRS-IS port
  useInternet: true,
  useRadio: false,
);

await aprsTransport.initialize();
```

### 2. Radio Mode (TNC)

```dart
final aprsTransport = AprsBridgeTransport(
  callsign: 'YOUR-CALLSIGN',
  passcode: '-1',               // Not used for radio-only mode
  tncPath: '/dev/ttyUSB0',       // TNC serial port
  useInternet: false,
  useRadio: true,
);

await aprsTransport.initialize();
```

### 3. Dual Mode (Internet + Radio)

```dart
final aprsTransport = AprsBridgeTransport(
  callsign: 'YOUR-CALLSIGN',
  passcode: 'YOUR-PASSCODE',
  serverHost: 'rotate.aprs2.net',
  serverPort: 10152,
  tncPath: '/dev/ttyUSB0',
  useInternet: true,
  useRadio: true,
);

await aprsTransport.initialize();
```

## 🔧 Configuration

### APRS-IS Passcode

1. Visit [APRS Passcode Generator](https://apps.magicbug.co.uk/passcode/)
2. Enter your callsign
3. Copy the generated passcode
4. Use in configuration

### TNC Configuration

#### Dire Wolf Setup
```bash
# Install Dire Wolf
sudo apt-get install direwolf

# Configure direwolf.conf
ADEVICE plughw:CARD=Device,DEV=0
ACHANNELS 1
CHANNEL 0
MYCALL YOUR-CALLSIGN
MODEM 1200
KISSPORT /dev/ttyUSB0
IGSERVER rotate.aprs2.net
IGLOGIN YOUR-CALLSIGN YOUR-PASSCODE
```

#### Hardware TNC Setup
```bash
# Configure serial port
sudo stty -F /dev/ttyUSB0 9600 cs8 -cstopb -parenb

# Test TNC connection
echo -e "YOUR-CALLSIGN\r\n" > /dev/ttyUSB0
```

## 📡 Usage Examples

### Send Position Report
```dart
// Send current position
await aprsTransport.sendPosition(
  -23.5092,  // Latitude
  -46.6530,  // Longitude
  comment: 'SOS Mesh Node Active',
);
```

### Send Emergency Alert
```dart
// Broadcast emergency
await aprsTransport.sendEmergencyAlert(
  'MEDICAL',           // Emergency type
  'Medical assistance required at location',  // Description
);
```

### Send Telemetry Data
```dart
// Send sensor readings
await aprsTransport.sendTelemetry(
  [120, 50, 25, 30, 75],  // Values: voltage, current, power, temp, humidity
  ['V', 'A', 'W', 'C', '%'], // Labels
);
```

### Send Direct Message
```dart
// Send message to specific station
final packet = TransportPacket(
  senderId: 'YOUR-CALLSIGN',
  recipientId: 'TARGET-CALL',
  type: SosPacketType.message,
  payload: {'message': 'Emergency assistance needed'},
);

await aprsTransport.send(packet);
```

### Broadcast Message
```dart
// Broadcast to all stations
await aprsTransport.broadcast('SOS Network Active - Emergency Response Ready');
```

## 📊 Monitoring

### Get APRS Status
```dart
final status = aprsTransport.getAprsStatus();
print('Connected stations: ${status['stations']}');
print('Messages received: ${status['messages']}');
print('Known stations: ${status['stationsList']}');
```

### Monitor Incoming Packets
```dart
aprsTransport.packetStream.listen((packet) {
  switch (packet.type) {
    case SosPacketType.message:
      print('Message from ${packet.senderId}: ${packet.payload}');
      break;
    case SosPacketType.telemetry:
      print('Telemetry from ${packet.senderId}: ${packet.payload}');
      break;
    case SosPacketType.sos:
      print('SOS from ${packet.senderId}: ${packet.payload}');
      break;
  }
});
```

## 🌍 Global Coverage

### APRS-IS Servers
- **Primary**: `rotate.aprs2.net:10152`
- **Secondary**: `noam.aprs2.net:10152`
- **Europe**: `euro.aprs2.net:10152`
- **Asia**: `asia.aprs2.net:10152`
- **Australia**: `aunz.aprs2.net:10152`

### Satellite Coverage
- **ISS**: International Space Station (145.825 MHz)
- **NOAA**: Weather satellites (137-138 MHz)
- **Iridium**: Satellite phone network (emergency)

## 🚨 Emergency Procedures

### Emergency Message Format
```
YOUR-CALL>APRS,TCPIP*:!DDMM.hhN/DDDMM.hhW_EMERGENCY: TYPE - DESCRIPTION
```

### Emergency Types
- `MEDICAL`: Medical emergency
- `FIRE`: Fire emergency
- `RESCUE`: Rescue operation
- `EVAC`: Evacuation required
- `SHELTER`: Shelter needed
- `POWER`: Power outage
- `WATER`: Water emergency
- `COMMUNICATION`: Communication failure

### Example Emergency Messages
```
PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_EMERGENCY: MEDICAL - Cardiac arrest
PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_EMERGENCY: FIRE - Building fire
PY1ABC>APRS,TCPIP*:!2330.55S/04639.18W_EMERGENCY: RESCUE - Person trapped
```

## 🔍 Troubleshooting

### Common Issues

#### Connection Failed
```bash
# Check network connectivity
ping rotate.aprs2.net

# Check firewall
telnet rotate.aprs2.net 10152
```

#### TNC Not Responding
```bash
# Check serial port
ls -la /dev/ttyUSB*

# Test TNC
echo -e "YOUR-CALLSIGN\r\n" > /dev/ttyUSB0
cat /dev/ttyUSB0
```

#### No Packets Received
```bash
# Check APRS-IS connection
echo "user YOUR-CALLSIGN pass YOUR-PASSCODE vers test 1.0" | nc rotate.aprs2.net 10152
```

### Debug Mode
```dart
// Enable debug logging
aprsTransport.reportStatus('Debug mode enabled');

// Monitor raw APRS packets
aprsTransport.packetStream.listen((packet) {
  print('Raw packet: ${packet.metadata}');
});
```

## 📱 Mobile Integration

### Android Setup
```dart
// Android permissions
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Setup
```dart
// iOS permissions
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location needed for APRS position reporting</string>
```

## 🛡️ Security Considerations

### Authentication
- **APRS-IS**: Uses callsign-based authentication
- **Radio**: Physical security of equipment
- **Messages**: No encryption (amateur radio requirement)

### Privacy
- **Position**: Publicly broadcast
- **Messages**: Publicly readable
- **Identity**: Callsign-based identification

### Best Practices
- Use emergency codes appropriately
- Verify message authenticity
- Follow amateur radio regulations
- Maintain operational security

## 📚 References

### Documentation
- [APRS Specification](http://www.aprs.org/doc/APRS101.PDF)
- [APRS-IS User Guide](https://www.aprs-is.net/Connecting.aspx)
- [Dire Wolf Manual](https://github.com/wb2osz/direwolf/blob/master/README.md)

### Tools
- [APRS.fi](https://aprs.fi/) - Live APRS map
- [APRS Direct](https://aprsdirect.com/) - Direct APRS access
- [FindU](http://www.findu.com/) - Historical APRS data

### Communities
- [TAPR](https://www.tapr.org/) - Tucson Amateur Packet Radio
- [ARRL](https://www.arrl.org/) - American Radio Relay League
- [AMSAT](https://www.amsat.org/) - Amateur Radio Satellite

## 🔄 Maintenance

### Regular Tasks
- **Daily**: Check connection status
- **Weekly**: Update position beacons
- **Monthly**: Review message logs
- **Quarterly**: Update software/firmware

### Performance Monitoring
```dart
// Monitor connection health
Timer.periodic(Duration(minutes: 5), (timer) {
  final status = aprsTransport.getAprsStatus();
  if (status['connected'] == false) {
    print('APRS connection lost - attempting reconnection');
  }
});
```

## 🚀 Advanced Features

### Custom Packet Types
```dart
// Send custom APRS packet
final customPacket = AprsPacket(
  source: 'YOUR-CALL',
  destination: 'APRS',
  path: ['TCPIP'],
  type: AprsDataType.user_defined,
  position: '2330.55S/04639.18W_Custom data',
);
```

### Multi-Path Routing
```dart
// Configure path for wide coverage
final widePacket = 'YOUR-CALL>APRS,WIDE1-1,WIDE2-2:!2330.55S/04639.18W_Test';
```

### Satellite Integration
```dart
// Send via satellite (ISS example)
await aprsTransport.sendPosition(
  -23.5092,
  -46.6530,
  comment: 'Via ISS',
);
```

---

## 📞 Support

For technical support and questions:
- **GitHub Issues**: Report bugs and feature requests
- **Amateur Radio Clubs**: Local expertise and assistance
- **APRS Forums**: Online community support
- **Emergency Services**: For actual emergency situations

---

**Remember**: This system is for emergency communication only. Always follow amateur radio regulations and emergency procedures.
