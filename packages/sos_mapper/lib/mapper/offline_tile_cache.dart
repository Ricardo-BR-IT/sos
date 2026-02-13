class OfflineTileKey {
  final int z;
  final int x;
  final int y;

  const OfflineTileKey({
    required this.z,
    required this.x,
    required this.y,
  });

  @override
  String toString() => '$z/$x/$y';
}

class OfflineTile {
  final List<int> bytes;
  final String mimeType;
  final DateTime cachedAt;

  const OfflineTile({
    required this.bytes,
    required this.mimeType,
    required this.cachedAt,
  });
}

abstract class OfflineTileStore {
  Future<OfflineTile?> getTile(OfflineTileKey key);
  Future<void> putTile(OfflineTileKey key, OfflineTile tile);
  Future<bool> hasTile(OfflineTileKey key);
}

class InMemoryTileStore implements OfflineTileStore {
  final Map<String, OfflineTile> _store = {};

  @override
  Future<OfflineTile?> getTile(OfflineTileKey key) async {
    return _store[key.toString()];
  }

  @override
  Future<void> putTile(OfflineTileKey key, OfflineTile tile) async {
    _store[key.toString()] = tile;
  }

  @override
  Future<bool> hasTile(OfflineTileKey key) async {
    return _store.containsKey(key.toString());
  }
}

class OfflineTileManifest {
  final String sourceId;
  final String? description;
  final DateTime createdAt;
  final int minZoom;
  final int maxZoom;

  const OfflineTileManifest({
    required this.sourceId,
    required this.createdAt,
    required this.minZoom,
    required this.maxZoom,
    this.description,
  });
}
