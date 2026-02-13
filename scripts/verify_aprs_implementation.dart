/// verify_aprs_implementation.dart
/// Script to verify APRS Bridge implementation

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Verificando implementação APRS Bridge...\n');

  final results = <String, bool>{};
  
  // 1. Verificar arquivo principal
  results['Arquivo principal'] = await _checkFileExists(
    'packages/sos_transports/lib/transport/aprs_bridge_transport.dart',
    'APRS Bridge Transport implementation',
  );

  // 2. Verificar testes
  results['Testes unitários'] = await _checkFileExists(
    'test/aprs_bridge_test.dart',
    'APRS Bridge unit tests',
  );

  // 3. Verificar documentação
  results['Documentação'] = await _checkFileExists(
    'docs/APRS_BRIDGE_SETUP.md',
    'APRS Bridge setup guide',
  );

  // 4. Verificar registro de tecnologia
  results['Registro de tecnologia'] = await _checkTechRegistry();

  // 5. Verificar mapeamento
  results['Mapeamento atualizado'] = await _checkMappingFile();

  // 6. Verificar dependências
  results['Dependências'] = await _checkDependencies();

  // 7. Verificar estrutura de código
  results['Estrutura do código'] = await _checkCodeStructure();

  // 8. Verificar funcionalidades
  results['Funcionalidades'] = await _checkFeatures();

  // Exibir resultados
  _displayResults(results);

  // Gerar relatório
  await _generateReport(results);
}

Future<bool> _checkFileExists(String path, String description) async {
  final file = File(path);
  final exists = await file.exists();
  
  if (exists) {
    final size = await file.length();
    print('✅ $description: ${size} bytes');
    return true;
  } else {
    print('❌ $description: Arquivo não encontrado');
    return false;
  }
}

Future<bool> _checkTechRegistry() async {
  try {
    final file = File('packages/sos_kernel/lib/tech/tech_registry.dart');
    final content = await file.readAsString();
    
    if (content.contains('ham_aprs')) {
      print('✅ Registro de tecnologia: ham_aprs encontrado');
      return true;
    } else {
      print('❌ Registro de tecnologia: ham_aprs não encontrado');
      return false;
    }
  } catch (e) {
    print('❌ Registro de tecnologia: Erro ao verificar - $e');
    return false;
  }
}

Future<bool> _checkMappingFile() async {
  try {
    final file = File('TECNOLOGIAS_MAPEAMENTO.md');
    final content = await file.readAsString();
    
    if (content.contains('ham_aprs') && content.contains('HAM/APRS Bridge')) {
      print('✅ Mapeamento atualizado: ham_aprs encontrado');
      return true;
    } else {
      print('❌ Mapeamento atualizado: ham_aprs não encontrado');
      return false;
    }
  } catch (e) {
    print('❌ Mapeamento atualizado: Erro ao verificar - $e');
    return false;
  }
}

Future<bool> _checkDependencies() async {
  try {
    final file = File('packages/sos_transports/pubspec.yaml');
    final content = await file.readAsString();
    
    // Verificar dependências básicas
    final hasDartIo = content.contains('dart:io');
    final hasDartAsync = content.contains('dart:async');
    final hasDartConvert = content.contains('dart:convert');
    
    if (hasDartIo && hasDartAsync && hasDartConvert) {
      print('✅ Dependências: Bibliotecas Dart básicas disponíveis');
      return true;
    } else {
      print('❌ Dependências: Bibliotecas Dart básicas ausentes');
      return false;
    }
  } catch (e) {
    print('❌ Dependências: Erro ao verificar - $e');
    return false;
  }
}

Future<bool> _checkCodeStructure() async {
  try {
    final file = File('packages/sos_transports/lib/transport/aprs_bridge_transport.dart');
    final content = await file.readAsString();
    
    // Verificar estrutura básica
    final hasClass = content.contains('class AprsBridgeTransport extends BaseTransport');
    final hasInitialize = content.contains('Future<void> initialize()');
    final hasSend = content.contains('Future<void> send(TransportPacket packet)');
    final hasBroadcast = content.contains('Future<void> broadcast(String message)');
    final hasDescriptor = content.contains('TransportDescriptor get descriptor');
    
    if (hasClass && hasInitialize && hasSend && hasBroadcast && hasDescriptor) {
      print('✅ Estrutura do código: Classe base implementada corretamente');
      return true;
    } else {
      print('❌ Estrutura do código: Métodos obrigatórios ausentes');
      return false;
    }
  } catch (e) {
    print('❌ Estrutura do código: Erro ao verificar - $e');
    return false;
  }
}

Future<bool> _checkFeatures() async {
  try {
    final file = File('packages/sos_transports/lib/transport/aprs_bridge_transport.dart');
    final content = await file.readAsString();
    
    // Verificar funcionalidades principais
    final hasInternetConnection = content.contains('_initializeInternetConnection');
    final hasRadioConnection = content.contains('_initializeRadioConnection');
    final hasPosition = content.contains('sendPosition');
    final hasTelemetry = content.contains('sendTelemetry');
    final hasEmergency = content.contains('sendEmergencyAlert');
    final hasPacketParsing = content.contains('_parseAprsPacket');
    
    int featuresFound = 0;
    if (hasInternetConnection) featuresFound++;
    if (hasRadioConnection) featuresFound++;
    if (hasPosition) featuresFound++;
    if (hasTelemetry) featuresFound++;
    if (hasEmergency) featuresFound++;
    if (hasPacketParsing) featuresFound++;
    
    print('✅ Funcionalidades: $featuresFound/6 implementadas');
    return featuresFound >= 5; // Pelo menos 5 de 6 funcionalidades
  } catch (e) {
    print('❌ Funcionalidades: Erro ao verificar - $e');
    return false;
  }
}

void _displayResults(Map<String, bool> results) {
  print('\n📊 RESULTADOS DA VERIFICAÇÃO:');
  print('=' * 50);
  
  int passed = 0;
  int total = results.length;
  
  results.forEach((test, result) {
    final icon = result ? '✅' : '❌';
    print('$icon $test');
    if (result) passed++;
  });
  
  print('\n📈 RESUMO:');
  print('Aprovados: $passed/$total (${(passed/total*100).toStringAsFixed(1)}%)');
  
  if (passed == total) {
    print('🎉 IMPLEMENTAÇÃO APRS BRIDGE CONCLUÍDA COM SUCESSO!');
  } else {
    print('⚠️  IMPLEMENTAÇÃO INCOMPLETA - VERIFICAR ITENS COM FALHA');
  }
}

Future<void> _generateReport(Map<String, bool> results) async {
  final report = {
    'timestamp': DateTime.now().toIso8601String(),
    'technology': 'HAM/APRS Bridge',
    'version': '1.0.0',
    'results': results,
    'summary': {
      'total': results.length,
      'passed': results.values.where((r) => r).length,
      'failed': results.values.where((r) => !r).length,
      'percentage': (results.values.where((r) => r).length / results.length * 100).toStringAsFixed(1),
    },
    'status': results.values.every((r) => r) ? 'COMPLETED' : 'INCOMPLETE',
  };

  final reportFile = File('reports/aprs_implementation_${DateTime.now().millisecondsSinceEpoch}.json');
  await reportFile.parent.create(recursive: true);
  await reportFile.writeAsString(jsonEncode(report));
  
  print('\n📄 Relatório gerado: ${reportFile.path}');
}
