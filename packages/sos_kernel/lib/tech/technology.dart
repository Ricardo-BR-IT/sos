enum TechnologyStatus {
  supported,
  partial,
  planned,
  experimental,
  unsupported,
}

enum TechnologyCategory {
  cellular,
  wifi,
  lan,
  mesh,
  iot,
  satellite,
  radio,
  plc,
  acoustic,
  optical,
  audio,
  protocol,
  emerging,
  navigation,
  broadcast,
  wan,
  other,
}

class SosTechnology {
  final String id;
  final String name;
  final TechnologyCategory category;
  final TechnologyStatus status;
  final String summary;
  final List<String> protocols;
  final List<String> requirements;
  final List<String> platforms;

  const SosTechnology({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.summary,
    this.protocols = const [],
    this.requirements = const [],
    this.platforms = const [],
  });
}
