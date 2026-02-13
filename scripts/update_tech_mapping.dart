#!/usr/bin/env dart

import '../packages/sos_kernel/lib/tech/tech_registry.dart';
import '../packages/sos_kernel/lib/tech/technology.dart';

void main() async {
  print('# Mapeamento de Tecnologias e Protocolos');
  print('Gerado automaticamente a partir de tech_registry.dart.');
  print('');
  print('| ID | Tecnologia | Categoria | Status | Plataformas |');
  print('|---|---|---|---|---|');

  for (final tech in TechRegistry.all) {
    final status = tech.status.name;
    final platforms = tech.platforms.join(', ');

    print(
      '| ${tech.id} | ${tech.name} | ${tech.category.name} | $status | $platforms |',
    );
  }

  print('');
  print('## Resumo');
  print('- Total de tecnologias: ${TechRegistry.all.length}');

  final supported = TechRegistry.all
      .where((t) => t.status == TechnologyStatus.supported)
      .length;
  final partial = TechRegistry.all
      .where((t) => t.status == TechnologyStatus.partial)
      .length;
  final planned = TechRegistry.all
      .where((t) => t.status == TechnologyStatus.planned)
      .length;
  final experimental = TechRegistry.all
      .where((t) => t.status == TechnologyStatus.experimental)
      .length;

  print('- Suportadas: $supported');
  print('- Parciais: $partial');
  print('- Planejadas: $planned');
  print('- Experimentais: $experimental');
}
