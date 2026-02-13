# SISTEMAS CELULARES MÓVEIS (WWAN - Wireless Wide Area Networks)

## 2G - Segunda Geração

### GSM (Global System for Mobile Communications)
- **Frequência**: 850 MHz, 900 MHz, 1.800 MHz, 1.900 MHz
- **Tipo**: Digital, TDMA (Time Division Multiple Access)
- **Cobertura**: 35 km de raio
- **Taxa de dados**: 9,6-14,4 kbps
- **Status**: Descontinuado em muitos países, substituído por 3G/4G
- **Protocolo**: GSM 06.10 (speech codec)
- **Modulation**: GMSK (Gaussian Minimum Shift Keying)
- **Canais**: 124 canais de 200 kHz

### CDMA 2000
- **Frequência**: 800 MHz, 1.900 MHz, 2.100 MHz
- **Tipo**: CDMA (Code Division Multiple Access)
- **Taxa de dados**: Até 153,6 kbps
- **Operadores**: Verizon, Sprint (EUA)
- **Status**: Descontinuado (2022 EUA)
- **Protocolo IS-95**, IS-95B

### TDMA
- **Frequência**: 800 MHz, 1.900 MHz
- **Tipo**: TDMA/FDD (Frequency Division Duplex)
- **Taxa**: 9,6 kbps - 14,4 kbps
- **Status**: Obsoleto
- **Protocolo**: IS-136

### PDC (Personal Digital Cellular)
- **Região**: Japão
- **Frequência**: 800 MHz, 1.500 MHz
- **Status**: Descontinuado (2012)
- **Protocolo**: TDMA baseado

## 3G - Terceira Geração

### UMTS (Universal Mobile Telecommunications System)
- **Frequência**: 850 MHz, 900 MHz, 1.700 MHz, 1.900 MHz, 2.100 MHz
- **Tipo**: WCDMA (Wideband CDMA)
- **Taxa de dados**: 384 kbps - 2 Mbps
- **Latência**: ~150 ms
- **Aplicações**: Voz, dados móveis, vídeo chamada
- **Protocolo**: 3GPP Release 99-12
- **Status**: Suporte reduzido, em fase de desativação (2025-2030)

### HSPA/HSPA+
- **Evolução de**: UMTS
- **Taxa**: HSPA (7,2 Mbps), HSPA+ (até 42 Mbps downlink)
- **Frequência**: Mesmas de UMTS
- **Status**: Descontinuado em muitos países
- **Protocolo**: 3GPP Release 5-11

### CDMA 2000 1xEV-DO (EVDO)
- **Frequência**: 800 MHz, 1.900 MHz
- **Taxa**: EVDO Rev 0 (2,4 Mbps), Rev A (3,1 Mbps), Rev B (14,7 Mbps)
- **Status**: Descontinuado
- **Protocolo**: 3GPP2

### TD-SCDMA
- **Região**: China (China Mobile)
- **Frequência**: 1.880-1.920 MHz, 2.010-2.025 MHz
- **Tipo**: TDMA + CDMA
- **Taxa**: 2,8 Mbps - 2,2 Mbps
- **Status**: Descontinuado (2020)
- **Protocolo**: 3GPP Release 4-6

## 4G - Quarta Geração

### LTE (Long-Term Evolution)
- **Frequência**: Bandas 1-32, 68+ (600 MHz a 3,8 GHz)
- **Tipo**: OFDMA (Orthogonal Frequency Division Multiple Access)
- **Taxa de dados**: 100 Mbps downlink, 50 Mbps uplink
- **Latência**: ~20-50 ms
- **Duplexing**: FDD e TDD
- **Protocolo**: 3GPP Release 8-13
- **Aplicações**: Voz sobre LTE (VoLTE), vídeo HD, banda larga móvel
- **Status**: Ainda operacional, gradual transição para 5G
- **Modulação**: QPSK, 16-QAM, 64-QAM
- **MIMO**: Até 4x4 MIMO

### LTE-A (LTE Advanced)
- **Taxa**: 300 Mbps+ (com agregação de portadoras)
- **Features**: CA (Carrier Aggregation), 8x8 MIMO, full-duplex
- **Status**: Suportado/ativo
- **Protocolo**: 3GPP Release 10-12

### LTE-A Pro
- **Taxa**: Até 1 Gbps
- **Features**: 32 portadoras, modulação 256-QAM
- **Status**: Ativo em operadores premium
- **Protocolo**: 3GPP Release 13

## 5G - Quinta Geração

### 5G NR (New Radio)
- **Frequência**: Sub-6 GHz (600 MHz - 6 GHz), mmWave (24-100+ GHz)
- **Tipo**: OFDM (Downlink), DFT-Spread OFDM (Uplink)
- **Taxa de dados**: 
  - eMBB (Enhanced Mobile Broadband): 1-10 Gbps
  - URLLC (Ultra-Reliable Low-Latency): <1 ms latência
  - mMTC (massive Machine-Type Communication): 1M+ dispositivos/km²
- **Latência**: 1-5 ms (edge computing)
- **Protocolo**: 3GPP Release 15 (NSA), Release 16+ (SA)
- **Bandas principais**:
  - n1 (2.100 MHz), n3 (1.800 MHz), n7 (2.600 MHz)
  - n28 (700 MHz), n78 (3.5 GHz), n79 (4.5-5 GHz)
  - n257 (28 GHz), n258 (24.25-28.35 GHz mmWave)
- **Modulação**: QPSK até 1.024-QAM
- **MIMO**: Até 32x32 (sub-6), 64x64 (mmWave)
- **Duplexing**: FDD, TDD, Full-duplex (pesquisa)
- **Recursos**: Network Slicing, QoS (Quality of Service) granular
- **Status**: Implementação global, expansão contínua

### 5G mmWave
- **Frequência**: 24 GHz - 100+ GHz
- **Taxa**: 10-20 Gbps
- **Cobertura**: Até 200m com visada direta
- **Aplicações**: Video 4K/8K, realidade aumentada, manufatura
- **Desafios**: Obstrução, chuva, interferência
- **Status**: Implantação em áreas urbanas

## Tecnologias em Desenvolvimento

### 5G Advanced / 5G-Advanced
- **Status**: Padronização em progresso (3GPP Release 18+)
- **Features**: 
  - Inteligência artificial nativa
  - Sideklink (comunicação dispositivo-a-dispositivo)
  - Integração satélite (NTN)
  - Eficiência energética melhorada
  - Redes privadas 5G
- **Aplicações**: Manufatura 4.0, cidades inteligentes, veículos autônomos
- **Frequências adicionais**: n255, n256 (satélite)

### 6G / IMT-2030
- **Status**: Conceitual/pesquisa (2024-2030)
- **Padrão esperado**: 3GPP Release 21+ (2030+)
- **Características**:
  - Taxa: 100+ Gbps, latência <100 μs
  - Frequências: Terahertz (0.1-10 THz)
  - Integração AI, quântica, satélite
  - Hologramas 3D em tempo real
  - Comunicação tátil
  - Energia sem fio
- **Protocolo**: Em definição (ITU-R, 3GPP, ETSI)
- **Aplicações**: Cirurgias remotas, realidade virtual total
- **Desafios**: Absorção atmosférica, hardware
- **Iniciativas**: EU 6G Flagship, China 6G Initiative, Samsung 6G Whitepaper

### RAN (Radio Access Network) virtualizado
- **Status**: Implementação 2024+
- **Conceito**: vRAN, Open RAN, Disaggregated RAN
- **Benefícios**: Flexibilidade, redução custo, interoperabilidade
- **Padrão**: O-RAN Alliance
- **Componentes**: DU (Distributed Unit), CU (Central Unit), RIC (RAN Intelligent Controller)

## Protocolos de Camada Superior

| Protocolo | Descrição | Status |
|-----------|-----------|--------|
| RTP | Real-time Transport Protocol | Ativo |
| SIP | Session Initiation Protocol | Ativo (VoIP) |
| IMS | IP Multimedia Subsystem | Suportado 4G/5G |
| HTTP/HTTPS | Navegação web | Ativo |
| MQTT | IoT messaging | Ativo |
| CoAP | Constrained Application Protocol | IoT |
| LwM2M | Lightweight M2M | IoT/Device Management |
| DNS | Domain Name System | Fundamental |
| TCP/UDP | Transporte | Fundamental |

## Bandas de Frequência Global

- **600 MHz - 6 GHz**: Sub-6 GHz (cobertura extensa)
- **24-100+ GHz**: mmWave (alta capacidade)
- **Terahertz**: Pesquisa 6G

## Tendências (2025-2030)

1. Descontinuação gradual GSM, UMTS, CDMA
2. Consolidação 5G e pré-6G
3. Redes abertas (Open RAN)
4. Integração terrestre-satélite
5. IA nativa nas redes
6. Eficiência energética com 5G Green
7. Standalone (SA) 5G padrão
