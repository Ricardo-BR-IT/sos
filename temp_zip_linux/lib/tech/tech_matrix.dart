import '../edition.dart';
import 'technology.dart';
import 'tech_registry.dart';

class TechMatrix {
  static TechnologyStatus statusFor(
    SosTechnology tech, {
    required String platform,
    SosEdition? edition,
  }) {
    final normalized = platform.toLowerCase();
    if (tech.platforms.isNotEmpty &&
        !tech.platforms.map((p) => p.toLowerCase()).contains(normalized)) {
      return TechnologyStatus.unsupported;
    }

    // Edicao mini: mantem status, mas pode indicar limitacoes futuras.
    if (edition == SosEdition.mini &&
        tech.status == TechnologyStatus.supported &&
        tech.category == TechnologyCategory.optical) {
      return TechnologyStatus.partial;
    }

    return tech.status;
  }

  static List<SosTechnology> allForPlatform(String platform) {
    return TechRegistry.all;
  }
}

