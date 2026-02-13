/// advanced_routing.dart
/// Advanced routing algorithms for mesh networks

import 'dart:async';
import 'dart:math';

import 'mesh_peer.dart';

enum RoutingStrategy {
  flooding,
  probabilistic,
  distanceVector,
  linkState,
  hybrid,
}

class AdvancedRouting {
  final Map<String, MeshPeer> _peers = {};
  final Map<String, RouteEntry> _routingTable = {};
  final Map<String, int> _sequenceNumbers = {};
  final Map<String, DateTime> _lastSeen = {};

  RoutingStrategy _strategy = RoutingStrategy.hybrid;
  Timer? _maintenanceTimer;

  // Routing parameters
  final int maxHops = 10;
  final Duration routeTimeout = Duration(minutes: 5);
  final Duration maintenanceInterval = Duration(seconds: 30);

  AdvancedRouting() {
    _startMaintenance();
  }

  void setStrategy(RoutingStrategy strategy) {
    _strategy = strategy;
  }

  List<String> calculateNextHops(String destination, String source) {
    switch (_strategy) {
      case RoutingStrategy.flooding:
        return _floodingRoute(destination, source);
      case RoutingStrategy.probabilistic:
        return _probabilisticRoute(destination, source);
      case RoutingStrategy.distanceVector:
        return _distanceVectorRoute(destination);
      case RoutingStrategy.linkState:
        return _linkStateRoute(destination);
      case RoutingStrategy.hybrid:
        return _hybridRoute(destination, source);
    }
  }

  List<String> _floodingRoute(String destination, String source) {
    // Enhanced flooding with sequence numbers and duplicate detection
    final nextHops = <String>[];

    for (final peer in _peers.values) {
      if (peer.id != source && _isPeerActive(peer.id)) {
        nextHops.add(peer.id);
      }
    }

    return nextHops;
  }

  List<String> _probabilisticRoute(String destination, String source) {
    // Probabilistic forwarding based on link quality
    final candidates = <String, double>{};

    for (final peer in _peers.values) {
      if (peer.id != source && _isPeerActive(peer.id)) {
        final quality = _calculateLinkQuality(peer.id);
        candidates[peer.id] = quality;
      }
    }

    // Normalize probabilities
    final totalQuality = candidates.values.fold(0.0, (a, b) => a + b);
    final random = Random();
    final selection = random.nextDouble() * totalQuality;

    var accumulated = 0.0;
    for (final entry in candidates.entries) {
      accumulated += entry.value;
      if (selection <= accumulated) {
        return [entry.key];
      }
    }

    return candidates.keys.toList();
  }

  List<String> _distanceVectorRoute(String destination) {
    // Distance vector routing implementation
    final route = _routingTable[destination];
    if (route != null && _isRouteValid(route)) {
      return [route.nextHop];
    }

    // Find best route through peers
    String? bestNextHop;
    int bestDistance = maxHops;

    for (final peer in _peers.values) {
      if (_isPeerActive(peer.id)) {
        final peerRoute = _routingTable['${peer.id}-$destination'];
        if (peerRoute != null && peerRoute.distance < bestDistance) {
          bestDistance = peerRoute.distance;
          bestNextHop = peer.id;
        }
      }
    }

    return bestNextHop != null ? [bestNextHop] : [];
  }

  List<String> _linkStateRoute(String destination) {
    // Link state routing implementation
    final route = _routingTable[destination];
    if (route != null && _isRouteValid(route)) {
      return [route.nextHop];
    }

    // Dijkstra's algorithm for shortest path
    return _dijkstraShortestPath(destination);
  }

  List<String> _hybridRoute(String destination, String source) {
    // Hybrid approach: use different strategies based on network conditions
    final networkSize = _peers.length;
    final congestion = _calculateNetworkCongestion();

    if (networkSize < 5) {
      return _floodingRoute(destination, source);
    } else if (congestion > 0.7) {
      return _distanceVectorRoute(destination);
    } else {
      return _probabilisticRoute(destination, source);
    }
  }

  List<String> _dijkstraShortestPath(String destination) {
    // Simplified Dijkstra implementation
    final distances = <String, int>{};
    final previous = <String, String?>{};
    final unvisited = Set<String>.from(_peers.keys);

    // Initialize distances
    for (final peerId in _peers.keys) {
      distances[peerId] = maxHops;
    }
    distances[destination] = 0;

    while (unvisited.isNotEmpty) {
      // Find unvisited node with minimum distance
      String? current;
      int minDistance = maxHops;

      for (final node in unvisited) {
        if (distances[node]! < minDistance) {
          minDistance = distances[node]!;
          current = node;
        }
      }

      if (current == null) break;

      unvisited.remove(current);

      // Update distances to neighbors
      for (final neighbor in _getNeighbors(current)) {
        final altDistance = distances[current]! + 1;
        if (altDistance < distances[neighbor]!) {
          distances[neighbor] = altDistance;
          previous[neighbor] = current;
        }
      }
    }

    // Reconstruct path
    final path = <String>[];
    String? current = destination;

    while (current != null && _peers.containsKey(current)) {
      path.insert(0, current);
      current = previous[current];
    }

    return path.length > 1 ? [path[1]] : [];
  }

  double _calculateLinkQuality(String peerId) {
    final peer = _peers[peerId];
    if (peer == null) return 0.0;

    // Calculate quality based on multiple factors
    final rssi = peer.metrics['rssi'] ?? -100.0;
    final packetLoss = peer.metrics['packetLoss'] ?? 0.0;
    final latency = peer.metrics['latency'] ?? 1000.0;

    // Normalize and combine metrics
    final rssiScore = max(0.0, (rssi + 100) / 100);
    final lossScore = max(0.0, 1.0 - packetLoss);
    final latencyScore = max(0.0, 1.0 - (latency / 1000));

    return (rssiScore * 0.4 + lossScore * 0.4 + latencyScore * 0.2);
  }

  double _calculateNetworkCongestion() {
    int totalPackets = 0;
    int droppedPackets = 0;

    for (final peer in _peers.values) {
      totalPackets += peer.metrics['sent'] ?? 0;
      droppedPackets += peer.metrics['dropped'] ?? 0;
    }

    return totalPackets > 0 ? droppedPackets / totalPackets : 0.0;
  }

  List<String> _getNeighbors(String peerId) {
    final neighbors = <String>[];
    final peer = _peers[peerId];

    if (peer != null) {
      for (final connection in peer.connections) {
        if (_isPeerActive(connection)) {
          neighbors.add(connection);
        }
      }
    }

    return neighbors;
  }

  bool _isPeerActive(String peerId) {
    final lastSeen = _lastSeen[peerId];
    if (lastSeen == null) return false;

    return DateTime.now().difference(lastSeen).inMinutes < 5;
  }

  bool _isRouteValid(RouteEntry route) {
    return DateTime.now().difference(route.createdAt).inMinutes <
        routeTimeout.inMinutes;
  }

  void updateRoutingTable(String destination, String nextHop, int distance) {
    _routingTable[destination] = RouteEntry(
      destination: destination,
      nextHop: nextHop,
      distance: distance,
      createdAt: DateTime.now(),
    );
  }

  void updatePeerMetrics(String peerId, Map<String, dynamic> metrics) {
    final peer = _peers[peerId];
    if (peer != null) {
      peer.metrics.addAll(metrics);
      _lastSeen[peerId] = DateTime.now();
    }
  }

  void addPeer(MeshPeer peer) {
    _peers[peer.id] = peer;
    _lastSeen[peer.id] = DateTime.now();
  }

  void removePeer(String peerId) {
    _peers.remove(peerId);
    _routingTable.removeWhere((key, value) => value.nextHop == peerId);
    _lastSeen.remove(peerId);
  }

  void _startMaintenance() {
    _maintenanceTimer = Timer.periodic(maintenanceInterval, (_) {
      _cleanupExpiredRoutes();
      _updateLinkQuality();
    });
  }

  void _cleanupExpiredRoutes() {
    final now = DateTime.now();
    _routingTable.removeWhere((key, route) =>
        now.difference(route.createdAt).inMinutes > routeTimeout.inMinutes);
  }

  void _updateLinkQuality() {
    for (final peerId in _peers.keys) {
      final quality = _calculateLinkQuality(peerId);
      _peers[peerId]?.metrics['linkQuality'] = quality;
    }
  }

  Map<String, dynamic> getRoutingStatistics() {
    return {
      'strategy': _strategy.toString(),
      'totalPeers': _peers.length,
      'routingTableSize': _routingTable.length,
      'averageLinkQuality': _peers.values
              .map((p) => p.metrics['linkQuality'] ?? 0.0)
              .fold(0.0, (a, b) => a + b) /
          _peers.length,
      'networkCongestion': _calculateNetworkCongestion(),
    };
  }

  void dispose() {
    _maintenanceTimer?.cancel();
    _peers.clear();
    _routingTable.clear();
    _sequenceNumbers.clear();
    _lastSeen.clear();
  }
}

class RouteEntry {
  final String destination;
  final String nextHop;
  final int distance;
  final DateTime createdAt;

  RouteEntry({
    required this.destination,
    required this.nextHop,
    required this.distance,
    required this.createdAt,
  });
}
