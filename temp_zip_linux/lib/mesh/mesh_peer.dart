class MeshPeer {
  final String id;
  final String name;
  final String platform;
  final String appVersion;
  final String? lastTransportId;
  final DateTime lastSeen;

  const MeshPeer({
    required this.id,
    required this.name,
    required this.platform,
    required this.appVersion,
    this.lastTransportId,
    required this.lastSeen,
  });

  MeshPeer copyWith({
    String? name,
    String? platform,
    String? appVersion,
    String? lastTransportId,
    DateTime? lastSeen,
  }) {
    return MeshPeer(
      id: id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      lastTransportId: lastTransportId ?? this.lastTransportId,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
