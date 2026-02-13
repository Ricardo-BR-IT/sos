/// Represents a single route entry in the mesh.
class RouteEntry {
  final String destinationId;
  final String nextHopId;
  final int hopCount;
  final Duration rtt;
  final DateTime lastSeen;
  final int sequenceNumber;

  RouteEntry({
    required this.destinationId,
    required this.nextHopId,
    required this.hopCount,
    required this.rtt,
    required this.lastSeen,
    required this.sequenceNumber,
  });

  bool get isExpired =>
      DateTime.now().difference(lastSeen) > const Duration(minutes: 5);
}

/// Manages multi-hop routing paths for the SOS Mesh.
class RoutingTable {
  final Map<String, RouteEntry> _routes = {};

  /// Adds or updates a route entry.
  void updateRoute({
    required String destinationId,
    required String nextHopId,
    required int hopCount,
    required Duration rtt,
    required int sequenceNumber,
  }) {
    final existing = _routes[destinationId];

    // AODV Logic: Update if better sequence or better metric for same sequence
    if (existing == null ||
        sequenceNumber > existing.sequenceNumber ||
        (sequenceNumber == existing.sequenceNumber &&
            hopCount < existing.hopCount)) {
      _routes[destinationId] = RouteEntry(
        destinationId: destinationId,
        nextHopId: nextHopId,
        hopCount: hopCount,
        rtt: rtt,
        lastSeen: DateTime.now(),
        sequenceNumber: sequenceNumber,
      );
    }
  }

  /// Gets the best next hop for a destination.
  String? getNextHop(String destinationId) {
    final route = _routes[destinationId];
    if (route == null || route.isExpired) return null;
    return route.nextHopId;
  }

  /// Removes expired routes.
  void purgeExpired() {
    _routes.removeWhere((id, entry) => entry.isExpired);
  }

  /// Gets all active routes.
  List<RouteEntry> get allRoutes =>
      _routes.values.where((r) => !r.isExpired).toList();

  /// Checks if a route exists.
  bool hasRoute(String destinationId) =>
      _routes.containsKey(destinationId) && !_routes[destinationId]!.isExpired;
}
