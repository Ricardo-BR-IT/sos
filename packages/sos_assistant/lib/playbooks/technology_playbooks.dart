enum EmergencyScenario {
  communication,
  medical,
  shelter,
  water,
  power,
  navigation,
  security,
  evacuation,
}

enum TechnologyType {
  bluetooth_le,
  bluetooth_classic,
  bluetooth_mesh,
  wifi_lan,
  ethernet,
  lorawan,
  dtn,
  secure,
  webrtc,
  zigbee,
}

class TechnologyPlaybook {
  final TechnologyType technology;
  final String title;
  final String description;
  final List<EmergencyScenario> scenarios;
  final List<PlaybookStep> steps;
  final Map<String, dynamic> requirements;
  final Duration estimatedTime;

  TechnologyPlaybook({
    required this.technology,
    required this.title,
    required this.description,
    required this.scenarios,
    required this.steps,
    required this.requirements,
    required this.estimatedTime,
  });
}

class PlaybookStep {
  final int order;
  final String title;
  final String instruction;
  final List<String> verification;
  final Map<String, dynamic> parameters;
  final Duration? timeout;

  PlaybookStep({
    required this.order,
    required this.title,
    required this.instruction,
    required this.verification,
    this.parameters = const {},
    this.timeout,
  });
}

class TechnologyPlaybooks {
  static final Map<TechnologyType, TechnologyPlaybook> playbooks = {
    TechnologyType.bluetooth_le: _bluetoothLePlaybook,
    TechnologyType.bluetooth_classic: _bluetoothClassicPlaybook,
    TechnologyType.bluetooth_mesh: _bluetoothMeshPlaybook,
    TechnologyType.wifi_lan: _wifiLanPlaybook,
    TechnologyType.ethernet: _ethernetPlaybook,
    TechnologyType.lorawan: _lorawanPlaybook,
    TechnologyType.dtn: _dtnPlaybook,
    TechnologyType.secure: _securePlaybook,
    TechnologyType.webrtc: _webrtcPlaybook,
    TechnologyType.zigbee: _zigbeePlaybook,
  };

  static TechnologyPlaybook? getPlaybook(TechnologyType technology) {
    return playbooks[technology];
  }

  static List<TechnologyPlaybook> getPlaybooksForScenario(
    EmergencyScenario scenario,
  ) {
    return playbooks.values
        .where((playbook) => playbook.scenarios.contains(scenario))
        .toList();
  }

  // Bluetooth LE Playbook
  static final TechnologyPlaybook _bluetoothLePlaybook = TechnologyPlaybook(
    technology: TechnologyType.bluetooth_le,
    title: 'Configuração de Bluetooth LE',
    description:
        'Guia completo para configurar e otimizar redes Bluetooth LE em emergências',
    scenarios: [EmergencyScenario.communication, EmergencyScenario.navigation],
    estimatedTime: Duration(minutes: 15),
    requirements: {
      'hardware': 'Dispositivo com Bluetooth LE 4.0+',
      'software': 'SOS Resgate v2.0+',
      'permissions': ['BLUETOOTH_SCAN', 'BLUETOOTH_CONNECT'],
      'power': 'Mínimo 50% de bateria',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Verificar Hardware Bluetooth',
        instruction:
            'Verifique se o Bluetooth está ativado e o hardware está funcionando',
        verification: ['Bluetooth ativado', 'Hardware detectado'],
        parameters: {'checkInterval': '5s'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Iniciar Scanning',
        instruction: 'Inicie varredura de dispositivos BLE próximos',
        verification: ['Scanning ativo', 'Dispositivos encontrados'],
        timeout: Duration(seconds: 30),
      ),
      PlaybookStep(
        order: 3,
        title: 'Configurar Advertising',
        instruction:
            'Ative advertising para que outros dispositivos possam encontrar este nó',
        verification: ['Advertising ativo', 'Nome visível'],
        parameters: {
          'deviceName': 'SOS-Mesh-{ID}',
          'serviceUuid': '0000FD6F-0000-1000-8000-00805F9B34FB',
        },
      ),
      PlaybookStep(
        order: 4,
        title: 'Estabelecer Conexões',
        instruction:
            'Conecte-se aos dispositivos SOS encontrados automaticamente',
        verification: ['Conexões estabelecidas', 'Handshake completo'],
        parameters: {'maxConnections': 10, 'connectionTimeout': '20s'},
      ),
      PlaybookStep(
        order: 5,
        title: 'Testar Comunicação',
        instruction: 'Envie mensagens de teste para verificar funcionamento',
        verification: ['Mensagens enviadas', 'Respostas recebidas'],
        parameters: {'testMessage': 'SOS_TEST', 'testCount': 3},
      ),
    ],
  );

  // Bluetooth Classic Playbook
  static final TechnologyPlaybook
  _bluetoothClassicPlaybook = TechnologyPlaybook(
    technology: TechnologyType.bluetooth_classic,
    title: 'Configuração de Bluetooth Classic',
    description:
        'Configuração de RFCOMM/BR-EDR para comunicação ponto-a-ponto confiável',
    scenarios: [EmergencyScenario.communication, EmergencyScenario.medical],
    estimatedTime: Duration(minutes: 20),
    requirements: {
      'hardware': 'Dispositivo com Bluetooth Classic',
      'software': 'Drivers RFCOMM atualizados',
      'permissions': ['BLUETOOTH', 'BLUETOOTH_ADMIN'],
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Verificar Compatibilidade',
        instruction: 'Verifique se o dispositivo suporta Bluetooth Classic',
        verification: ['Bluetooth Classic disponível', 'RFCOMM suportado'],
      ),
      PlaybookStep(
        order: 2,
        title: 'Tornar Descobrível',
        instruction:
            'Ative modo descobrível para que outros possam encontrar este dispositivo',
        verification: ['Modo descobrível ativo', 'Visível na rede'],
        parameters: {'deviceName': 'SOS-Classic-{ID}'},
      ),
      PlaybookStep(
        order: 3,
        title: 'Emparelhar Dispositivos',
        instruction:
            'Realize pareamento com dispositivos confiados previamente',
        verification: ['Pareamento concluído', 'Dispositivos confiáveis'],
        parameters: {'pinRequired': false, 'autoAccept': true},
      ),
      PlaybookStep(
        order: 4,
        title: 'Conectar a Rede Mesh',
        instruction: 'Conecte-se à rede mesh existente ou crie uma nova',
        verification: ['Conectado à mesh', 'IP atribuído'],
        parameters: {'meshType': 'bluetooth_classic', 'securityLevel': 'high'},
      ),
    ],
  );

  // Bluetooth Mesh Playbook
  static final TechnologyPlaybook _bluetoothMeshPlaybook = TechnologyPlaybook(
    technology: TechnologyType.bluetooth_mesh,
    title: 'Configuração de Bluetooth Mesh',
    description:
        'Implementação de rede mesh usando Bluetooth LE para cobertura expandida',
    scenarios: [EmergencyScenario.communication, EmergencyScenario.evacuation],
    estimatedTime: Duration(minutes: 25),
    requirements: {
      'hardware': 'Múltiplos dispositivos BLE com suporte a mesh',
      'software': 'Bluetooth Mesh Stack',
      'minNodes': '3 nós para mesh funcional',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Designar Topologia',
        instruction: 'Planeje a topologia da rede mesh baseada na área',
        verification: ['Topologia definida', 'Nós planejados'],
        parameters: {'topology': 'hybrid', 'maxHops': '5'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar Provisioner',
        instruction: 'Configure o provisioner para gerenciar nós da mesh',
        verification: ['Provisioner ativo', 'Políticas aplicadas'],
        parameters: {
          'provisioningMode': 'auto',
          'networkKey': 'auto-generated',
        },
      ),
      PlaybookStep(
        order: 3,
        title: 'Provisionar Nós',
        instruction: 'Adicione nós à rede mesh com configurações adequadas',
        verification: ['Nós provisionados', 'Chaves distribuídas'],
        parameters: {'nodeType': 'router', 'relayMode': 'enabled'},
      ),
      PlaybookStep(
        order: 4,
        title: 'Otimizar Roteamento',
        instruction: 'Configure algoritmos de roteamento para eficiência',
        verification: ['Roteamento ativo', 'Caminhos otimizados'],
        parameters: {'routingAlgorithm': 'hybrid', 'updateInterval': '30s'},
      ),
      PlaybookStep(
        order: 5,
        title: 'Testar Resiliência',
        instruction:
            'Teste a resiliência da mesh removendo nós temporariamente',
        verification: ['Auto-recuperação', 'Comunicação mantida'],
        parameters: {'testDuration': '5min', 'nodesToRemove': 1},
      ),
    ],
  );

  // LoRaWAN Playbook
  static final TechnologyPlaybook _lorawanPlaybook = TechnologyPlaybook(
    technology: TechnologyType.lorawan,
    title: 'Configuração de LoRa/LoRaWAN',
    description:
        'Configuração de comunicação de longo alcance para áreas remotas',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.evacuation,
      EmergencyScenario.water,
    ],
    estimatedTime: Duration(minutes: 30),
    requirements: {
      'hardware': 'Módulo LoRa e gateway',
      'antenna': 'Antena adequada (868MHz ou 915MHz)',
      'power': 'Fonte de alimentação estável',
      'license': 'Licença de frequência se aplicável',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Instalar Hardware',
        instruction: 'Conecte o módulo LoRa e configure a antena',
        verification: ['Hardware conectado', 'Drivers instalados'],
        parameters: {'port': 'COM3', 'baudRate': '9600'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar Frequência',
        instruction: 'Configure a frequência e parâmetros LoRa para sua região',
        verification: ['Frequência configurada', 'Parâmetros validados'],
        parameters: {
          'frequency': '915MHz',
          'spreadingFactor': '7',
          'bandwidth': '125kHz',
          'codingRate': '4/5',
        },
      ),
      PlaybookStep(
        order: 3,
        title: 'Testar Alcance',
        instruction: 'Realize testes de alcance para determinar cobertura',
        verification: ['Testes concluídos', 'Alcance medido'],
        parameters: {'testDistance': '1km', 'testInterval': '30s'},
      ),
      PlaybookStep(
        order: 4,
        title: 'Configurar Gateway',
        instruction: 'Configure o gateway LoRaWAN para comunicação com a rede',
        verification: ['Gateway configurado', 'Conectividade testada'],
        parameters: {'gatewayMode': 'standalone', 'networkServer': 'local'},
      ),
      PlaybookStep(
        order: 5,
        title: 'Implementar DTN',
        instruction: 'Integre com DTN para store-and-forward de mensagens',
        verification: ['DTN ativo', 'Mensagens armazenadas'],
        parameters: {'storageSize': '100MB', 'retention': '7dias'},
      ),
    ],
  );

  // DTN Playbook
  static final TechnologyPlaybook _dtnPlaybook = TechnologyPlaybook(
    technology: TechnologyType.dtn,
    title: 'Configuração de DTN Bundle Protocol',
    description:
        'Implementação de comunicação tolerante a falhas com store-and-forward',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.navigation,
      EmergencyScenario.evacuation,
    ],
    estimatedTime: Duration(minutes: 20),
    requirements: {
      'storage': 'Espaço em disco para bundles',
      'memory': 'RAM suficiente para buffer',
      'algorithms': 'Bundle Protocol v7, LTP',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Configurar Storage',
        instruction: 'Configure armazenamento local para bundles DTN',
        verification: ['Storage configurado', 'Permissões concedidas'],
        parameters: {'storagePath': 'dtn_storage', 'maxSize': '100MB'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Implementar Custody',
        instruction: 'Ative transferência de custódia para mensagens críticas',
        verification: ['Custody ativo', 'Políticas definidas'],
        parameters: {'custodyTimeout': '1hora', 'retryAttempts': 3},
      ),
      PlaybookStep(
        order: 3,
        title: 'Configurar Roteamento',
        instruction: 'Configure roteamento DTN para redes intermitentes',
        verification: ['Roteamento ativo', 'Tabelas populadas'],
        parameters: {'routingAlgorithm': 'contact', 'maxHops': '10'},
      ),
      PlaybookStep(
        order: 4,
        title: 'Testar Store-and-Forward',
        instruction: 'Teste armazenamento e retransmissão de mensagens',
        verification: ['Mensagens armazenadas', 'Retransmissão funcionando'],
        parameters: {'testMessages': 10, 'testInterval': '1min'},
      ),
    ],
  );

  // Security Playbook
  static final TechnologyPlaybook _securePlaybook = TechnologyPlaybook(
    technology: TechnologyType.secure,
    title: 'Configuração de Segurança OSCORE/EDHOC',
    description:
        'Implementação de segurança ponta a ponta para redes restritas',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.security,
      EmergencyScenario.medical,
    ],
    estimatedTime: Duration(minutes: 15),
    requirements: {
      'crypto': 'libsodium ou equivalente',
      'keys': 'Chaves criptográficas seguras',
      'protocols': 'OSCORE, EDHOC, COSE, CBOR',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Gerar Chaves',
        instruction: 'Gere chaves criptográficas para todos os participantes',
        verification: ['Chaves geradas', 'Backup criado'],
        parameters: {'keySize': '256bits', 'algorithm': 'X25519'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar OSCORE',
        instruction: 'Configure OSCORE para proteção de mensagens CoAP',
        verification: ['OSCORE ativo', 'Contextos estabelecidos'],
        parameters: {'algorithm': 'AES-CCM', 'keyDerivation': 'HKDF'},
      ),
      PlaybookStep(
        order: 3,
        title: 'Implementar EDHOC',
        instruction: 'Configure autenticação por chave efêmera',
        verification: ['EDHOC funcionando', 'Handshake completo'],
        parameters: {'curve': 'X25519', 'hash': 'SHA-256'},
      ),
      PlaybookStep(
        order: 4,
        title: 'Validar Segurança',
        instruction: 'Teste todas as camadas de segurança implementadas',
        verification: ['Criptografia funcionando', 'Integridade verificada'],
        parameters: {'testVectors': 'comprehensive', 'coverage': 'full'},
      ),
    ],
  );

  // WebRTC Playbook
  static final TechnologyPlaybook _webrtcPlaybook = TechnologyPlaybook(
    technology: TechnologyType.webrtc,
    title: 'Configuração de WebRTC',
    description: 'Configuração de comunicação em tempo real com áudio e vídeo',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.medical,
      EmergencyScenario.navigation,
    ],
    estimatedTime: Duration(minutes: 10),
    requirements: {
      'browser': 'Navegador com WebRTC support',
      'camera': 'Câmera para vídeo',
      'microphone': 'Microfone para áudio',
      'network': 'Conexão internet para STUN/TURN',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Verificar Permissões',
        instruction: 'Verifique permissões de câmera e microfone',
        verification: ['Permissões concedidas', 'Hardware detectado'],
        parameters: {'videoResolution': '720p', 'audioCodec': 'Opus'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar STUN/TURN',
        instruction: 'Configure servidores STUN/TURN para NAT traversal',
        verification: ['STUN funcionando', 'TURN configurado'],
        parameters: {
          'stunServers': ['stun.l.google.com:19302'],
          'turnServers': ['turn.example.com:3478'],
        },
      ),
      PlaybookStep(
        order: 3,
        title: 'Estabelecer Conexão',
        instruction: 'Conecte-se a outros nós via WebRTC',
        verification: ['Conexão P2P', 'Mídia funcionando'],
        parameters: {'iceGathering': 'aggressive', 'connectionTimeout': '30s'},
      ),
      PlaybookStep(
        order: 4,
        title: 'Testar Qualidade',
        instruction: 'Teste qualidade de áudio e vídeo',
        verification: ['Áudio claro', 'Vídeo estável'],
        parameters: {'bitrate': '500kbps', 'fps': '15'},
      ),
    ],
  );

  // Zigbee Playbook
  static final TechnologyPlaybook _zigbeePlaybook = TechnologyPlaybook(
    technology: TechnologyType.zigbee,
    title: 'Configuração de Zigbee',
    description: 'Implementação de rede mesh IoT para sensores e atuadores',
    scenarios: [
      EmergencyScenario.water,
      EmergencyScenario.power,
      EmergencyScenario.security,
    ],
    estimatedTime: Duration(minutes: 35),
    requirements: {
      'coordinator': 'Coordenador Zigbee',
      'nodes': 'Dispositivos Zigbee',
      'channel': 'Canal sem interferência',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Configurar Coordenador',
        instruction: 'Configure o coordenador Zigbee com parâmetros adequados',
        verification: ['Coordenador ativo', 'Rede formada'],
        parameters: {
          'channel': '11',
          'panId': '0x1234',
          'networkKey': 'auto-generated',
        },
      ),
      PlaybookStep(
        order: 2,
        title: 'Adicionar Nós',
        instruction: 'Adicione sensores e atuadores à rede Zigbee',
        verification: ['Nós conectados', 'Endereços atribuídos'],
        parameters: {'nodeType': 'router', 'maxNodes': '50'},
      ),
      PlaybookStep(
        order: 3,
        title: 'Configurar Sensores',
        instruction: 'Configure sensores para monitoramento ambiental',
        verification: ['Sensores ativos', 'Dados recebidos'],
        parameters: {
          'sensors': ['temperature', 'humidity', 'smoke'],
          'reportInterval': '60s',
        },
      ),
      PlaybookStep(
        order: 4,
        title: 'Testar Cobertura',
        instruction: 'Teste cobertura da rede em diferentes áreas',
        verification: ['Cobertura mapeada', 'Sinal adequado'],
        parameters: {'testPoints': '10', 'signalThreshold': '-85dBm'},
      ),
    ],
  );

  // WiFi LAN Playbook
  static final TechnologyPlaybook _wifiLanPlaybook = TechnologyPlaybook(
    technology: TechnologyType.wifi_lan,
    title: 'Configuração de WiFi LAN',
    description: 'Configuração de rede local via WiFi com mDNS e TCP',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.shelter,
      EmergencyScenario.power,
    ],
    estimatedTime: Duration(minutes: 10),
    requirements: {
      'router': 'Roteador WiFi',
      'devices': 'Dispositivos com WiFi',
      'network': 'Rede local existente',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Conectar à Rede',
        instruction: 'Conecte todos os dispositivos à mesma rede WiFi',
        verification: ['Conectados à rede', 'IPs atribuídos'],
        parameters: {'ssid': 'SOS-Network', 'security': 'WPA2'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar mDNS',
        instruction: 'Ative descoberta mDNS para dispositivos SOS',
        verification: ['mDNS ativo', 'Serviços publicados'],
        parameters: {'serviceName': '_sos-mesh._tcp', 'domain': 'local'},
      ),
      PlaybookStep(
        order: 3,
        title: 'Testar Conectividade',
        instruction: 'Teste conectividade entre todos os nós',
        verification: ['Ping funcionando', 'Portas abertas'],
        parameters: {'testPort': '8080', 'timeout': '5s'},
      ),
    ],
  );

  // Ethernet Playbook
  static final TechnologyPlaybook _ethernetPlaybook = TechnologyPlaybook(
    technology: TechnologyType.ethernet,
    title: 'Configuração de Ethernet LAN',
    description: 'Configuração de rede cabeada para máxima confiabilidade',
    scenarios: [
      EmergencyScenario.communication,
      EmergencyScenario.medical,
      EmergencyScenario.security,
    ],
    estimatedTime: Duration(minutes: 8),
    requirements: {
      'switch': 'Switch Ethernet',
      'cables': 'Cabos Ethernet CAT5e ou superior',
      'ips': 'Endereços IP estáticos ou DHCP',
    },
    steps: [
      PlaybookStep(
        order: 1,
        title: 'Conectar Cabeamento',
        instruction: 'Conecte todos os dispositivos via cabos Ethernet',
        verification: ['Conexões físicas', 'Link lights ativos'],
        parameters: {'cableType': 'CAT5e', 'speed': '1Gbps'},
      ),
      PlaybookStep(
        order: 2,
        title: 'Configurar IPs',
        instruction: 'Configure endereços IP estáticos ou DHCP',
        verification: ['IPs configurados', 'Conectividade testada'],
        parameters: {'ipRange': '192.168.1.0/24', 'gateway': '192.168.1.1'},
      ),
      PlaybookStep(
        order: 3,
        title: 'Testar Throughput',
        instruction: 'Teste throughput da rede Ethernet',
        verification: ['Throughput medido', 'Latência testada'],
        parameters: {'testDuration': '60s', 'expectedSpeed': '1Gbps'},
      ),
    ],
  );

  static Map<String, dynamic> getPlaybookSummary() {
    return {
      'totalPlaybooks': playbooks.length,
      'technologies': playbooks.keys.map((t) => t.toString()).toList(),
      'scenarios': EmergencyScenario.values.map((s) => s.toString()).toList(),
      'averageTime':
          playbooks.values
              .map((p) => p.estimatedTime.inMinutes)
              .reduce((a, b) => a + b) /
          playbooks.length,
    };
  }

  static List<Map<String, dynamic>> getQuickStartGuides() {
    return playbooks.entries.map((entry) {
      final playbook = entry.value;
      return {
        'technology': entry.key.toString(),
        'title': playbook.title,
        'description': playbook.description,
        'estimatedTime': '${playbook.estimatedTime.inMinutes}min',
        'scenarios': playbook.scenarios.map((s) => s.toString()).toList(),
        'requirements': playbook.requirements,
      };
    }).toList();
  }
}
