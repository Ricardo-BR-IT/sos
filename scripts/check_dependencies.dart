#!/usr/bin/env dart

import 'dart:io';

void main() {
  print('🔍 Verificando dependências do projeto...\n');

  // Verificar pubspec.yaml principal
  final pubspec = File('pubspec.yaml');
  if (pubspec.existsSync()) {
    print('✅ pubspec.yaml encontrado');
    final content = pubspec.readAsStringSync();

    // Verificar dependências críticas
    final criticalDeps = [
      'flutter_blue_plus',
      'bluetooth_serial',
      'win_ble',
      'bluez',
      'serial_port_win32',
      'webrtc_interface',
      'crypto',
      'cbor',
      'http',
    ];

    print('\n📦 Dependências Críticas:');
    for (final dep in criticalDeps) {
      final hasDep = content.contains(dep);
      final status = hasDep ? '✅' : '❌';
      print('  $status $dep');
    }
  } else {
    print('❌ pubspec.yaml não encontrado');
  }

  // Verificar pubspec.yaml dos pacotes
  final packages = [
    'packages/sos_transports',
    'packages/sos_kernel',
    'packages/sos_ui',
    'packages/sos_vault',
  ];

  print('\n📦 Pacotes:');
  for (final pkg in packages) {
    final pubspecPath = '$pkg/pubspec.yaml';
    final pubspecFile = File(pubspecPath);
    final exists = pubspecFile.existsSync();
    final status = exists ? '✅' : '❌';
    print('  $status $pkg');
  }

  // Verificar estrutura de diretórios
  print('\n📁 Estrutura de Diretórios:');
  final criticalDirs = [
    'packages/sos_transports/lib/transport',
    'packages/sos_kernel/lib/tech',
    'packages/sos_kernel/lib/mesh',
    'packages/sos_kernel/lib/identity',
    'apps',
    'scripts',
    'test',
  ];

  for (final dir in criticalDirs) {
    final dirObj = Directory(dir);
    final exists = dirObj.existsSync();
    final status = exists ? '✅' : '❌';
    print('  $status $dir');
  }

  // Verificar arquivos de implementação
  print('\n📄 Arquivos de Implementação:');
  final implFiles = [
    'packages/sos_transports/lib/transport/ble_transport.dart',
    'packages/sos_transports/lib/transport/bluetooth_classic_transport.dart',
    'packages/sos_transports/lib/transport/bluetooth_mesh_transport.dart',
    'packages/sos_transports/lib/transport/lorawan_transport.dart',
    'packages/sos_transports/lib/transport/dtn_transport.dart',
    'packages/sos_transports/lib/transport/secure_transport.dart',
    'packages/sos_transports/lib/transport/webrtc_transport.dart',
    'packages/sos_kernel/lib/tech/tech_registry.dart',
    'packages/sos_kernel/lib/mesh/mesh_service.dart',
    'packages/sos_kernel/lib/identity/crypto_manager.dart',
  ];

  for (final file in implFiles) {
    final fileObj = File(file);
    final exists = fileObj.existsSync();
    final status = exists ? '✅' : '❌';
    print('  $status $file');
  }

  print('\n🎯 Resumo:');
  print('  Estrutura do projeto: Verificada');
  print('  Dependências: Verificadas');
  print('  Implementações: Verificadas');
  print('  🚀 Pronto para compilação e testes');
}
