import '../edition.dart';
import 'tech_matrix.dart';
import 'tech_registry.dart';
import 'technology.dart';

class TechService {
  final String platform;
  final SosEdition edition;

  TechService({
    required this.platform,
    SosEdition? edition,
  }) : edition = edition ?? EditionConfig.current;

  List<SosTechnology> get technologies => TechRegistry.all;

  TechnologyStatus statusFor(SosTechnology tech) {
    return TechMatrix.statusFor(
      tech,
      platform: platform,
      edition: edition,
    );
  }
}

