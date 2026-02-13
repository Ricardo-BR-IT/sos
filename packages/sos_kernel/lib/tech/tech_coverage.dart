import 'package:sos_transports/sos_transports.dart';

import '../edition.dart';
import 'tech_matrix.dart';
import 'tech_registry.dart';
import 'technology.dart';

enum TechBindingMode {
  native,
  gateway,
  unavailable,
}

class TechCoverageEntry {
  final SosTechnology tech;
  final TechnologyStatus status;
  final TechBindingMode binding;
  final List<TransportDescriptor> transports;

  const TechCoverageEntry({
    required this.tech,
    required this.status,
    required this.binding,
    required this.transports,
  });
}

class TechCoverageReport {
  final List<TechCoverageEntry> entries;

  const TechCoverageReport({required this.entries});

  int get nativeCount =>
      entries.where((e) => e.binding == TechBindingMode.native).length;
  int get gatewayCount =>
      entries.where((e) => e.binding == TechBindingMode.gateway).length;
  int get unavailableCount =>
      entries.where((e) => e.binding == TechBindingMode.unavailable).length;
}

class TechCoverageService {
  final String platform;
  final SosEdition edition;
  final List<TransportDescriptor> descriptors;

  TechCoverageService({
    required this.platform,
    SosEdition? edition,
    List<TransportDescriptor>? descriptors,
  })  : edition = edition ?? EditionConfig.current,
        descriptors = descriptors ?? TransportRegistry.knownDescriptors();

  TechCoverageReport build() {
    final entries = <TechCoverageEntry>[];
    for (final tech in TechRegistry.all) {
      final status = TechMatrix.statusFor(
        tech,
        platform: platform,
        edition: edition,
      );
      final matching = descriptors
          .where((d) => d.technologyIds.contains(tech.id))
          .toList();

      TechBindingMode binding;
      if (status == TechnologyStatus.unsupported) {
        binding = TechBindingMode.unavailable;
      } else if (matching.isEmpty) {
        binding = TechBindingMode.gateway;
      } else if (matching.every((d) => d.requiresGateway)) {
        binding = TechBindingMode.gateway;
      } else {
        binding = TechBindingMode.native;
      }

      entries.add(TechCoverageEntry(
        tech: tech,
        status: status,
        binding: binding,
        transports: matching,
      ));
    }
    return TechCoverageReport(entries: entries);
  }
}
