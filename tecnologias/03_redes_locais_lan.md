# REDES LOCAIS (LAN - Local Area Networks)

## Padrões IEEE 802.11 (WiFi)

### WiFi 6 (802.11ax)
- **Frequência**: 2,4 GHz, 5 GHz
- **Taxa de dados**: Até 9,6 Gbps (teórico)
- **Duplexing**: OFDMA, MU-MIMO 8x8
- **Latência**: <10 ms
- **Alcance**: 30-100m
- **Eficiência energética**: +30% vs WiFi 5
- **Modulação**: 1024-QAM
- **Protocolo**: IEEE 802.11ax (2021)
- **Status**: Implementação em produção, larga adoção
- **Aplicações**: Trabalho remoto, gaming, 4K/8K
- **Padrão segurança**: WPA3

### WiFi 6E
- **Extensão de**: WiFi 6
- **Frequência adicionada**: 6 GHz (5.925-7.125 GHz)
- **Taxa**: Mesmo 9,6 Gbps
- **Vantagem**: Redução congestionamento de espectro
- **Status**: Crescimento 2023-2025
- **Dispositivos**: Roteadores, laptops, smartphones premium

### WiFi 7 (802.11be)
- **Status**: Padrão ratificado (2024)
- **Frequência**: 2,4 GHz, 5 GHz, 6 GHz
- **Taxa de dados**: Até 46 Gbps (teórico)
- **MIMO**: 16x16
- **Duplexing**: MLO (Multi-Link Operation)
- **Latência**: <5 ms
- **Alcance**: Mesmo ~100m
- **Modulação**: 4096-QAM
- **Benefícios**: Ultra-baixa latência, múltiplas bandas simultâneas
- **Aplicações**: Gaming competitivo, streaming 8K, VR
- **Cronograma comercial**: 2024-2025

### WiFi 6GHz (802.11ax na banda 6GHz)
- **Padrão**: IEEE 802.11ax-2021
- **Frequência**: 5.925-7.125 GHz
- **Canais**: 59 canais de 20 MHz
- **Status**: Regulamentado em 180+ países (2023+)
- **Benéfício**: Espectro novo para reduzir congestionamento
- **Compatibilidade**: WiFi 6E/7 obrigatório

### WiFi 5 (802.11ac)
- **Frequência**: 5 GHz
- **Taxa**: Até 3,5 Gbps
- **Modulação**: 256-QAM
- **MIMO**: Até 8x8
- **Status**: Ainda em uso, substituído por WiFi 6+
- **Protocolo**: IEEE 802.11ac

### WiFi 4 (802.11n)
- **Frequência**: 2,4 GHz, 5 GHz
- **Taxa**: Até 600 Mbps
- **MIMO**: Até 4x4
- **Status**: Obsolescente
- **Protocolo**: IEEE 802.11n

### WiFi 5GHz de Onda Curta (802.11h)
- **Regulação para**: Detectar radar, sistemas de satélites
- **Padrão**: IEEE 802.11h
- **Status**: Historicamente importante, agora integrado

## WiFi de Longa Distância

### WiFi 4G / Li-Fi (Visible Light Communication)
- **Status**: Pesquisa e protótipos (2024-2025)
- **Frequência**: 380-780 nm (luz visível)
- **Taxa**: 1-100 Mbps dependendo variante
- **Alcance**: 10-20m (sem obstrução)
- **Vantagem**: Sem interferência RF, comunicação via luz/LED
- **Aplicações**: Hospitais, aviões, ambientes sensíveis
- **Protocolo**: IEEE 802.11bb (em desenvolvimento)
- **Status padrão**: Padronização (2024+)
- **Implementação**: OLED, LED (LED de alta frequência)

### WiFi Extendido / 802.11k/v/w (Fast Roaming)
- **Protocolos**: 802.11k (Neighbor Reports), 802.11v (BSS Transition), 802.11w (Management Frame Protection)
- **Benefício**: Roaming seamless entre APs
- **Latência**: Reduzida para aplicações críticas
- **Status**: Suportado WiFi 5/6+

## Ethernet (Cabeado - incluído LAN wired)

### Ethernet Padrão
- **Taxa**: 10/100/1000 Mbps
- **Padrão**: IEEE 802.3
- **Alcance**: 100m (UTP Cat5e)
- **Protocolo**: CSMA/CD (Carrier Sense Multiple Access with Collision Detection)
- **Status**: Fundamental em infraestrutura

### Ethernet de Alta Velocidade
- **10 Gbps (10GBASE-T)**: IEEE 802.3an
  - Alcance: 100m (Cat6A)
  - Status: Comum em data centers
  
- **25/40/100 Gbps**: IEEE 802.3bz, 802.3by, 802.3ba
  - Alcance: 30m (40 Gbps), variam por tipo
  - Uso: Data centers, backbone
  - Status: Implantação crescente
  
- **400 Gbps**: IEEE 802.3db, 802.3ck
  - Status: Pesquisa/early deployment
  - Uso: Super data centers, backbone global

### Power over Ethernet (PoE)
- **Padrão**: IEEE 802.3af (15W), 802.3at (30W), 802.3bt (60-100W)
- **Uso**: Alimentar câmeras, APs, sensores via Ethernet
- **Status**: Padrão em redes modernas

## Wireless LAN (WLAN) Adicional

### Bluetooth / Bluetooth Low Energy (BLE)
- **Frequência**: 2,4 GHz
- **Cobertura**: 10-100m (BLE até 240m com extended range)
- **Taxa**: 1-3 Mbps (Bluetooth 4.0+), 2 Mbps BLE
- **Consumo**: Baixíssimo BLE
- **Padrão**: IEEE 802.15.1 (Bluetooth SIG)
- **Status**: Ubíquo em dispositivos
- **Versão atual**: Bluetooth 5.4 (2023)
- **Aplicações**: Wearables, IoT, periféricos

### Bluetooth 5.4
- **Taxa**: Até 2 Mbps (mesh até 300 Mbps com múltiplos saltos)
- **Alcance**: Até 240m (extended range)
- **Múltiplos canais**: até 3 simultâneos
- **Aplicações**: Mesh networks, IoT escalável
- **Status**: Recente (2023), rápida adoção

### Zigbee
- **Frequência**: 2,4 GHz (888 MHz, 915 MHz também)
- **Padrão**: IEEE 802.15.4
- **Taxa**: 250 kbps
- **Alcance**: 10-100m
- **Topologia**: Mesh
- **Consumo**: Muito baixo
- **Aplicações**: Smart home, iluminação, sensor
- **Padrão**: ZigBee Alliance (Conectivity Standards Alliance)
- **Status**: Estável, ampla adoção

### Thread
- **Frequência**: 2,4 GHz
- **Padrão**: IEEE 802.15.4
- **Taxa**: 250 kbps (mesmo PHY de Zigbee)
- **Protocolo**: Mesh baseado IPv6
- **Aplicações**: Smart home (Matter Alliance)
- **Status**: Crescimento (2023-2025)
- **Vantagem**: Melhor que Zigbee para IP nativo

### Matter / Thread
- **Status**: Padrão conectividade smart home (2022+)
- **Tipo**: Mesh sobre IEEE 802.15.4 e WiFi
- **Objetivo**: Interoperabilidade universal
- **Suportado por**: Apple, Google, Amazon, Samsung
- **Protocolo**: CHIP (Connectivity Home IP Protocol)

### Z-Wave
- **Frequência**: 868 MHz (EU), 915 MHz (US), 920 MHz (JP)
- **Padrão**: Proprietário (Z-Wave Alliance)
- **Taxa**: 9,6-100 kbps
- **Alcance**: 30m
- **Topologia**: Mesh
- **Aplicações**: Automação residencial
- **Status**: Estabelecido mas menos adoção que Zigbee/Thread
- **Versão atual**: Z-Wave 800 (2023)

### WiFi Direct
- **Frequência**: 2,4 GHz, 5 GHz
- **Padrão**: IEEE 802.11 p2p
- **Taxa**: Mesmo que WiFi 6/5/4 por banda
- **Conexão**: P2P sem roteador
- **Alcance**: ~200m
- **Status**: Suportado mas pouco usado
- **Aplicações**: Transferência de arquivos rápida

### NFC (Near Field Communication)
- **Frequência**: 13,56 MHz
- **Alcance**: 10cm típico
- **Taxa**: 106-848 kbps
- **Padrão**: ISO/IEC 14443
- **Aplicações**: Pagamento, ID, acesso
- **Status**: Integrado em smartphones modernos

## Topologias LAN

| Topologia | Descrição | Latência | Escalabilidade |
|-----------|-----------|----------|-----------------|
| Star | Hub/Switch central | Baixa | Alta |
| Mesh | Múltiplos caminhos | Média | Alta |
| Ring | Anel conectado | Média | Média |
| Bus | Barramento único | Alta em congestionamento | Baixa |
| Tree | Hierárquica | Variável | Alta |

## Protocolos de Camada 2/3 em LAN

- **DHCP**: Atribuição dinâmica de IP
- **ARP**: Address Resolution Protocol
- **IGMP**: Group Management
- **VLAN (802.1Q)**: Redes virtuais
- **STP (802.1D/802.1w)**: Spanning Tree (redundância)
- **RSTP**: Rapid STP
- **LACP**: Link Aggregation
- **QoS (802.1p)**: Priorização de tráfego

## Tendências LAN (2025-2030)

1. WiFi 7 larga adoção
2. Integração WiFi-Satellite
3. Li-Fi comercialização inicial
4. Matter smart home padronização
5. Ultra-low latency gaming networks
6. Redes mesh inteligentes com IA
7. Energy harvesting via RF/WiFi
8. 10+ Gbps padrão em households
