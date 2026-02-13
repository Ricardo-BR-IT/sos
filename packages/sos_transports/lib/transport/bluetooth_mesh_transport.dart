/// bluetooth_mesh_transport.dart
/// Bluetooth Mesh transport implementation using BLE as underlying layer

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'base_transport.dart';
import 'transport_descriptor.dart';
import 'transport_packet.dart';

class BluetoothMeshTransport extends BaseTransport {
  static const TransportDescriptor kDescriptor = TransportDescriptor(
    id: 'bluetooth_mesh',
    name: 'Bluetooth Mesh',
    technologyIds: ['bluetooth_mesh'],
    mediums: ['rf'],
  );

  final Guid meshServiceUuid;
  final Guid meshProvisioningUuid;
  final Guid meshProxyUuid;
  final int maxChunkSize;

  String? _localId;
  bool _isProvisioned = false;
  String? _meshUuid;
  int _meshAddress = 0;
  Set<int> _knownNodes = {};

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final Map<DeviceIdentifier, BluetoothDevice> _knownDevices = {};
  final Map<DeviceIdentifier, _MeshPeer> _peers = {};
  final Map<DeviceIdentifier, String> _buffers = {};

  BluetoothMeshTransport({
    String? meshServiceUuid,
    String? meshProvisioningUuid,
    String? meshProxyUuid,
    this.maxChunkSize = 180,
  })  : meshServiceUuid =
            Guid(meshServiceUuid ?? '00001828-0000-1000-8000-00805F9B34FB'),
        meshProvisioningUuid = Guid(
            meshProvisioningUuid ?? '00001827-0000-1000-8000-00805F9B34FB'),
        meshProxyUuid =
            Guid(meshProxyUuid ?? '00001828-0000-1000-8000-00805F9B34FB');

  @override
  String? get localId => _localId;

  @override
  void setLocalId(String id) {
    _localId = id;
    _generateMeshIdentity();
  }

  void _generateMeshIdentity() {
    if (_localId == null) return;

    // Generate mesh UUID from local ID
    final bytes = utf8.encode(_localId!);
    final hash = bytes.fold<int>(0, (sum, byte) => sum + byte);
    _meshUuid = hash.toRadixString(16).padLeft(8, '0');
    _meshAddress = (hash & 0xFFFF) | 0x8000; // Unicast address range
  }

  @override
  Future<void> initialize() async {
    if (!await FlutterBluePlus.isSupported) {
      markUnavailable('BLE not supported on this device.');
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      markUnavailable('Bluetooth desativado.');
      return;
    }

    _generateMeshIdentity();
    await _startMeshAdvertising();
    await _startMeshScanning();

    markAvailable();
  }

  Future<void> _startMeshAdvertising() async {
    try {
      // BLE Mesh advertising is handled by the OS mesh stack
      // FlutterBluePlus does not support direct advertising control
      reportStatus('Mesh advertising mode: passive (scan-based discovery)');
    } catch (e) {
      reportError('Mesh advertising failed: $e');
    }
  }

  Future<void> _startMeshScanning() async {
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      _handleScanResults,
      onError: (error) => reportError(error),
    );

    await FlutterBluePlus.startScan(
      withServices: [meshServiceUuid, meshProvisioningUuid],
      timeout: null,
      continuousUpdates: true,
    );
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final device = result.device;
      _knownDevices[device.remoteId] = device;

      if (_peers.containsKey(device.remoteId)) continue;

      // Check if it's a mesh node
      if (device.name.contains('SOS-Mesh') ||
          result.advertisementData.serviceUuids.contains(meshServiceUuid)) {
        _connectMeshNode(device);
      }
    }
  }

  Future<void> _connectMeshNode(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 20));

      final services = await device.discoverServices();
      final meshService = services.firstWhere(
        (s) => s.serviceUuid == meshServiceUuid,
        orElse: () => throw Exception('Mesh service not found'),
      );

      if (meshService.characteristics.isEmpty) {
        await device.disconnect();
        return;
      }

      final resolved = _selectMeshCharacteristics(meshService.characteristics);
      if (resolved.tx == null && resolved.rx == null) {
        await device.disconnect();
        return;
      }

      StreamSubscription<List<int>>? rxSubscription;
      if (resolved.rx != null &&
          (resolved.rx!.properties.notify ||
              resolved.rx!.properties.indicate)) {
        try {
          await resolved.rx!.setNotifyValue(true);
          rxSubscription = resolved.rx!.onValueReceived.listen(
            (data) => _handleIncomingMeshData(device.remoteId, data),
            onError: (error) => reportError(error),
          );
          device.cancelWhenDisconnected(rxSubscription,
              next: true, delayed: true);
        } catch (e) {
          reportError('Mesh notify failed: $e');
        }
      }

      final connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _removeMeshPeer(device.remoteId);
        }
      });

      device.cancelWhenDisconnected(connectionSub, next: true, delayed: true);

      // Exchange mesh information
      await _exchangeMeshInfo(resolved.tx!);

      _peers[device.remoteId] = _MeshPeer(
        device: device,
        tx: resolved.tx,
        rx: resolved.rx,
        rxSubscription: rxSubscription,
        connectionSubscription: connectionSub,
      );
    } catch (e) {
      reportError('Mesh node connect failed: $e');
    }
  }

  _MeshCharacteristicPair _selectMeshCharacteristics(
      List<BluetoothCharacteristic> characteristics) {
    BluetoothCharacteristic? tx;
    BluetoothCharacteristic? rx;

    // Find mesh data characteristics
    for (final characteristic in characteristics) {
      if (characteristic.uuid.toString().startsWith('00002A')) {
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

    return _MeshCharacteristicPair(tx: tx, rx: rx);
  }

  Future<void> _exchangeMeshInfo(BluetoothCharacteristic txChar) async {
    try {
      final meshInfo = {
        'type': 'mesh_info',
        'uuid': _meshUuid,
        'address': _meshAddress,
        'features': ['relay', 'proxy', 'friend'],
      };

      final data = utf8.encode('${jsonEncode(meshInfo)}\n');
      await txChar.write(data, withoutResponse: true);
    } catch (e) {
      reportError('Mesh info exchange failed: $e');
    }
  }

  void _handleIncomingMeshData(DeviceIdentifier peerId, List<int> data) {
    if (data.isEmpty) return;

    final chunk = utf8.decode(data, allowMalformed: true);
    final pending = (_buffers[peerId] ?? '') + chunk;
    final parts = pending.split('\n');

    for (var i = 0; i < parts.length - 1; i++) {
      final line = parts[i].trim();
      if (line.isEmpty) continue;

      try {
        final json = jsonDecode(line);

        // Handle mesh-specific messages
        if (json['type'] == 'mesh_info') {
          _handleMeshInfo(peerId, json);
          continue;
        }

        // Handle regular transport packets
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

  void _handleMeshInfo(DeviceIdentifier peerId, Map<String, dynamic> info) {
    final uuid = info['uuid'] as String?;
    final address = info['address'] as int?;

    if (uuid != null && address != null) {
      _knownNodes.add(address);
      reportStatus(
          'Mesh node discovered: $uuid (0x${address.toRadixString(16)})');
    }
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

    // Send to all connected mesh nodes
    for (final peer in _peers.values) {
      try {
        final characteristic = peer.tx;
        if (characteristic == null) continue;

        final withoutResponse = characteristic.properties.writeWithoutResponse;
        for (final chunk in chunks) {
          await characteristic.write(chunk, withoutResponse: withoutResponse);
        }
      } catch (e) {
        reportError('Mesh broadcast failed: $e');
      }
    }
  }

  @override
  Future<void> connect(String peerId) async {
    final remoteId = DeviceIdentifier(peerId);
    final device = _knownDevices[remoteId];
    if (device == null) return;

    await _connectMeshNode(device);
  }

  void _removeMeshPeer(DeviceIdentifier id) {
    final peer = _peers.remove(id);
    peer?.rxSubscription?.cancel();
    peer?.connectionSubscription?.cancel();
    _buffers.remove(id);
  }

  @override
  Future<void> dispose() async {
    // Mesh advertising cleanup (passive mode)
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    for (final peer in _peers.values) {
      peer.rxSubscription?.cancel();
      peer.connectionSubscription?.cancel();
      try {
        await peer.device.disconnect();
      } catch (_) {}
    }

    _peers.clear();
    _buffers.clear();

    await super.dispose();
  }

  @override
  TransportDescriptor get descriptor => kDescriptor;
}

class _MeshPeer {
  final BluetoothDevice device;
  final BluetoothCharacteristic? tx;
  final BluetoothCharacteristic? rx;
  final StreamSubscription? rxSubscription;
  final StreamSubscription? connectionSubscription;

  _MeshPeer({
    required this.device,
    this.tx,
    this.rx,
    this.rxSubscription,
    this.connectionSubscription,
  });
}

class _MeshCharacteristicPair {
  final BluetoothCharacteristic? tx;
  final BluetoothCharacteristic? rx;

  _MeshCharacteristicPair({required this.tx, required this.rx});
}
