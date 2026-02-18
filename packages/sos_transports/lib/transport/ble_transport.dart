/// ble_transport.dart
/// PRODUCTION IMPLEMENTATION with flutter_blue_plus (Mobile) and desktop BLE support.

import 'dart:async' as async;
import 'dart:async' hide StreamController;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluez/bluez.dart' as bluez;
import 'package:win_ble/win_ble.dart';
// Note: WinServer availability depends on win_ble version, usually part of win_ble package
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

// Default GATT service/characteristic (can be overridden via constructor).
const String _defaultServiceUuid = '0000FD6F-0000-1000-8000-00805F9B34FB';
const String _defaultCharacteristicUuid =
    '0000FD70-0000-1000-8000-00805F9B34FB';

class BleTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'ble',
    name: 'Bluetooth LE',
    technologyIds: ['bluetooth_le'],
    mediums: ['rf'],
  );

  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int maxChunkSize;

  String? _localId;
  async.StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isAdvertising = false;
  bool _running = false;

  final Map<DeviceIdentifier, BluetoothDevice> _knownDevices = {};
  final Map<DeviceIdentifier, _BlePeer> _peers = {};
  final Map<DeviceIdentifier, String> _buffers = {};
  final Set<DeviceIdentifier> _connecting = {};

  // Incoming packet stream
  final async.StreamController<TransportPacket> _incomingController =
      async.StreamController<TransportPacket>.broadcast();

  // Override to return our controller stream
  @override
  async.Stream<TransportPacket> get onPacketReceived =>
      _incomingController.stream;

  BleTransport({
    String? serviceUuid,
    String? characteristicUuid,
    this.maxChunkSize = 180,
  })  : serviceUuid = Guid(serviceUuid ?? _defaultServiceUuid),
        characteristicUuid =
            Guid(characteristicUuid ?? _defaultCharacteristicUuid);

  @override
  bool get isEnabled => _running;

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
  }

  @override
  Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile implementation using flutter_blue_plus
      await _initializeMobile();
    } else if (Platform.isWindows) {
      // Windows desktop implementation
      await _initializeWindows();
    } else if (Platform.isLinux) {
      // Linux desktop implementation
      await _initializeLinux();
    } else {
      markUnavailable('BLE not supported on this platform.');
    }
  }

  Future<void> _initializeMobile() async {
    if (!await FlutterBluePlus.isSupported) {
      markUnavailable('BLE not supported on this device.');
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      markUnavailable('Bluetooth desativado.');
      return;
    }

    // Start advertising our service
    await _startAdvertising();

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      _handleScanResults,
      onError: (error) => reportError(error),
    );

    await FlutterBluePlus.startScan(
      withServices: [serviceUuid],
      timeout: null,
      continuousUpdates: true,
    );
    _running = true;
    markAvailable();
  }

  Future<void> _startAdvertising() async {
    if (_isAdvertising) return;

    try {
      final advertisingData = AdvertiseData(
        localName: 'SOS-Mesh-${_localId ??= 'Node'}',
        serviceUuid: serviceUuid.toString(),
      );
      await FlutterBlePeripheral().start(advertiseData: advertisingData);
      _isAdvertising = true;
    } catch (e) {
      reportError('BLE advertising failed: $e');
    }
  }

  Future<void> _stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      await FlutterBlePeripheral().stop();
      _isAdvertising = false;
    } catch (e) {
      reportError('BLE stop advertising failed: $e');
    }
  }

  Future<void> _initializeWindows() async {
    try {
      // Try to get server path dynamically if WinServer is available
      final serverPath = 'C:\\Program Files\\SOS\\ble_server.exe';
      await WinBle.initialize(serverPath: serverPath);

      WinBle.scanStream.listen((device) {
        _handleWindowsScanResult(device);
      });

      WinBle.startScanning();
      _running = true;
      markAvailable();
    } catch (e) {
      markUnavailable('Windows BLE init failed: $e');
    }
  }

  Future<void> _initializeLinux() async {
    try {
      final client = bluez.BlueZClient();
      await client.connect();

      if (client.adapters.isEmpty) {
        markUnavailable('Nenhum adaptador Bluetooth encontrado no Linux.');
        return;
      }

      final adapter = client.adapters.first;

      client.deviceAdded.listen((device) {
        _handleLinuxDevice(device);
      });

      await adapter.startDiscovery();
      _running = true;
      markAvailable();
    } catch (e) {
      markUnavailable('Linux BLE init failed: $e');
    }
  }

  void _handleWindowsScanResult(BleDevice device) {
    final remoteId = DeviceIdentifier(device.address);
    if (_peers.containsKey(remoteId)) return;
    if (_connecting.contains(remoteId)) return;

    if (device.name.contains('SOS')) {
      _connecting.add(remoteId);
      _connectWindowsDevice(device).whenComplete(() {
        _connecting.remove(remoteId);
      });
    }
  }

  void _handleLinuxDevice(bluez.BlueZDevice device) {
    final remoteId = DeviceIdentifier(device.address);
    if (_peers.containsKey(remoteId)) return;

    if (device.name.contains('SOS')) {
      _connectLinuxDevice(device);
    }
  }

  Future<void> _connectWindowsDevice(BleDevice device) async {
    try {
      await WinBle.connect(device.address);

      final services = await WinBle.discoverServices(device.address);
      if (!services.contains(serviceUuid.toString().toLowerCase())) {
        await WinBle.disconnect(device.address);
        return;
      }

      final characteristics = await WinBle.discoverCharacteristics(
        address: device.address,
        serviceId: serviceUuid.toString(),
      );

      String? targetChar;
      for (final char in characteristics) {
        if (char.uuid == characteristicUuid.toString().toLowerCase()) {
          targetChar = char.uuid;
          break;
        }
      }

      if (targetChar == null) {
        await WinBle.disconnect(device.address);
        return;
      }

      WinBle.characteristicValueStream.listen((event) {
        if (event.address == device.address &&
            event.characteristicId == targetChar) {
          _handleIncoming(DeviceIdentifier(device.address), event.value);
        }
      });

      await WinBle.subscribeToCharacteristic(
        address: device.address,
        serviceId: serviceUuid.toString(),
        characteristicId: targetChar,
      );

      _peers[DeviceIdentifier(device.address)] = _BlePeer(
        device: device,
        tx: targetChar,
        rx: targetChar,
        platform: 'windows',
      );
    } catch (e) {
      reportError('Windows BLE connect failed: $e');
    }
  }

  Future<void> _connectLinuxDevice(bluez.BlueZDevice device) async {
    try {
      await device.connect();
      await Future.delayed(Duration(seconds: 2));

      // In bluez 0.8.0, characteristics are accessed via services
      // We need to find the GATT objects
      final dynamic dDevice = device;
      final List services = dDevice.gattServices ?? [];

      bluez.BlueZGattService? targetService;
      for (final service in services) {
        if (service is bluez.BlueZGattService &&
            service.uuid.toString().toLowerCase() ==
                serviceUuid.toString().toLowerCase()) {
          targetService = service;
          break;
        }
      }

      if (targetService == null) {
        await device.disconnect();
        return;
      }

      bluez.BlueZGattCharacteristic? txChar;
      bluez.BlueZGattCharacteristic? rxChar;

      for (final char in targetService.characteristics) {
        if (char.uuid.toString().toLowerCase() ==
            characteristicUuid.toString().toLowerCase()) {
          // Check flags for usage
          final flags = char.flags;
          if (flags.contains(bluez.BlueZGattCharacteristicFlag.write) ||
              flags.contains(
                  bluez.BlueZGattCharacteristicFlag.writeWithoutResponse)) {
            txChar = char;
          }
          if (flags.contains(bluez.BlueZGattCharacteristicFlag.notify) ||
              flags.contains(bluez.BlueZGattCharacteristicFlag.indicate)) {
            rxChar = char;
          }
        }
      }

      if (txChar == null || rxChar == null) {
        await device.disconnect();
        return;
      }

      await (rxChar as dynamic).startNotify();
      final subscription = (rxChar as dynamic).value.listen((List<int> data) {
        _handleIncoming(DeviceIdentifier(device.address), data);
      });

      _peers[DeviceIdentifier(device.address)] = _BlePeer(
        device: device,
        tx: txChar,
        rx: rxChar,
        platform: 'linux',
        rxSubscription: subscription,
      );
    } catch (e) {
      reportError('Linux BLE connect failed: $e');
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final device = result.device;
      _knownDevices[device.remoteId] = device;
      if (_peers.containsKey(device.remoteId)) continue;
      if (_connecting.contains(device.remoteId)) continue;
      if (!_matchesService(result)) continue;
      _connecting.add(device.remoteId);
      _connectDevice(device).whenComplete(() {
        _connecting.remove(device.remoteId);
      });
    }
  }

  bool _matchesService(ScanResult result) {
    final advertised = result.advertisementData.serviceUuids;
    if (advertised.contains(serviceUuid)) return true;
    return false;
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await device.connect(
          timeout: const Duration(seconds: 20), license: License.values.first);
    } catch (e) {
      reportError('BLE connect failed: $e');
      return;
    }

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      reportError('BLE discover services failed: $e');
      await _safeDisconnect(device);
      return;
    }

    final service = services.firstWhere(
      (s) => s.serviceUuid == serviceUuid,
      orElse: () => throw Exception('Service not found'),
    );

    final resolved = _selectCharacteristics(service.characteristics);
    if (resolved.tx == null && resolved.rx == null) {
      await _safeDisconnect(device);
      return;
    }

    StreamSubscription<List<int>>? rxSubscription;
    if (resolved.rx != null &&
        (resolved.rx!.properties.notify || resolved.rx!.properties.indicate)) {
      try {
        await resolved.rx!.setNotifyValue(true);
        rxSubscription = resolved.rx!.onValueReceived.listen(
          (data) => _handleIncoming(device.remoteId, data),
          onError: (error) => reportError(error),
        );
        device.cancelWhenDisconnected(rxSubscription,
            next: true, delayed: true);
      } catch (e) {
        reportError('BLE notify failed: $e');
      }
    }

    final connectionSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _removePeer(device.remoteId);
      }
    });

    device.cancelWhenDisconnected(connectionSub, next: true, delayed: true);

    _peers[device.remoteId] = _BlePeer(
      device: device,
      tx: resolved.tx,
      rx: resolved.rx,
      platform: 'mobile',
      rxSubscription: rxSubscription,
      connectionSubscription: connectionSub,
    );
  }

  _BleCharacteristicPair _selectCharacteristics(
      List<BluetoothCharacteristic> characteristics) {
    BluetoothCharacteristic? tx;
    BluetoothCharacteristic? rx;

    for (final characteristic in characteristics) {
      if (characteristic.characteristicUuid == characteristicUuid) {
        if (tx == null &&
            (characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse)) {
          tx = characteristic;
        }
        if (rx == null &&
            (characteristic.properties.notify ||
                characteristic.properties.indicate)) {
          rx = characteristic;
        }
      }
    }

    for (final characteristic in characteristics) {
      if (tx == null &&
          (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse)) {
        tx = characteristic;
      }
      if (rx == null &&
          (characteristic.properties.notify ||
              characteristic.properties.indicate)) {
        rx = characteristic;
      }
    }

    return _BleCharacteristicPair(tx: tx, rx: rx);
  }

  void _handleIncoming(DeviceIdentifier peerId, List<int> data) {
    if (data.isEmpty) return;
    final chunk = utf8.decode(data, allowMalformed: true);
    final pending = (_buffers[peerId] ?? '') + chunk;
    final parts = pending.split('\n');
    for (var i = 0; i < parts.length - 1; i++) {
      final line = parts[i].trim();
      if (line.isEmpty) continue;
      try {
        final packet = TransportPacket.fromJson(line);
        emitPacket(packet);
      } catch (_) {
        emitPacket(TransportPacket(
          senderId: peerId.toString(),
          type: SosPacketType.data,
          payload: {'raw': line},
        ));
      }
    }
    _buffers[peerId] = parts.last;
  }

  @override
  Future<void> send(TransportPacket packet) async {
    await broadcast(packet.toJson());
  }

  @override
  Future<void> broadcast(String message) async {
    if (_peers.isEmpty) return;
    final payload = utf8.encode('$message\n');
    final chunks = <List<int>>[];
    for (var offset = 0; offset < payload.length; offset += maxChunkSize) {
      final end = (offset + maxChunkSize).clamp(0, payload.length);
      chunks.add(payload.sublist(offset, end));
    }

    for (final peer in _peers.values) {
      try {
        if (peer.platform == 'mobile') {
          final characteristic = peer.tx as BluetoothCharacteristic?;
          if (characteristic == null) continue;
          final withoutResponse =
              characteristic.properties.writeWithoutResponse;
          for (final chunk in chunks) {
            await characteristic.write(chunk, withoutResponse: withoutResponse);
          }
        } else if (peer.platform == 'windows') {
          final address = (peer.device as BleDevice).address;
          final charId = peer.tx as String;
          for (final chunk in chunks) {
            await WinBle.write(
              address: address,
              service: serviceUuid.toString(),
              characteristic: charId,
              data: Uint8List.fromList(chunk),
              writeWithResponse: false,
            );
          }
        } else if (peer.platform == 'linux') {
          final characteristic = peer.tx as bluez.BlueZGattCharacteristic?;
          if (characteristic == null) continue;
          for (final chunk in chunks) {
            await characteristic.writeValue(chunk);
          }
        }
      } catch (e) {
        reportError('BLE write failed (${peer.platform}): $e');
      }
    }
  }

  @override
  Future<void> connect(String peerId) async {
    final remoteId = DeviceIdentifier(peerId);
    if (_peers.containsKey(remoteId) || _connecting.contains(remoteId)) return;
    final device = _knownDevices[remoteId];
    if (device == null) return;
    _connecting.add(remoteId);
    await _connectDevice(device);
    _connecting.remove(remoteId);
  }

  Future<void> _safeDisconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (_) {}
  }

  void _removePeer(DeviceIdentifier id) {
    final peer = _peers.remove(id);
    peer?.rxSubscription?.cancel();
    peer?.connectionSubscription?.cancel();
    _buffers.remove(id);
  }

  @override
  Future<void> dispose() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _stopAdvertising();
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      for (final peer in _peers.values) {
        peer.rxSubscription?.cancel();
        peer.connectionSubscription?.cancel();
        await _safeDisconnect(peer.device);
      }
    } else if (Platform.isWindows) {
      WinBle.stopScanning();
    } else if (Platform.isLinux) {
      try {
        final client = bluez.BlueZClient();
        await client.connect();
        if (client.adapters.isNotEmpty) {
          await client.adapters.first.stopDiscovery();
        }
        await client.close();
      } catch (_) {}
    }

    _peers.clear();
    _running = false;
    await super.dispose();
  }

  @override
  TransportDescriptor get descriptor => kDescriptor;
}

class _BlePeer {
  final dynamic device;
  final dynamic tx;
  final dynamic rx;
  final String platform;
  final StreamSubscription? rxSubscription;
  final StreamSubscription? connectionSubscription;

  _BlePeer({
    required this.device,
    required this.tx,
    required this.rx,
    required this.platform,
    this.rxSubscription,
    this.connectionSubscription,
  });
}

class _BleCharacteristicPair {
  final BluetoothCharacteristic? tx;
  final BluetoothCharacteristic? rx;

  _BleCharacteristicPair({required this.tx, required this.rx});
}
