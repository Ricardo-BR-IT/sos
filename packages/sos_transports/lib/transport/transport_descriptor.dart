class TransportDescriptor {
  final String id;
  final String name;
  final List<String> technologyIds;
  final List<String> mediums;
  final bool requiresGateway;
  final String? notes;

  const TransportDescriptor({
    required this.id,
    required this.name,
    required this.technologyIds,
    this.mediums = const [],
    this.requiresGateway = false,
    this.notes,
  });
}
