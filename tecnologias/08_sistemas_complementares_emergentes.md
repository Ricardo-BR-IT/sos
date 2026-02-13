# SISTEMAS COMPLEMENTARES E EMERGENTES DE COMUNICAÇÃO

## Redes de Sensores sem Fio

### WSN (Wireless Sensor Networks)
- **Padrão**: IEEE 802.15.4
- **Frequência**: 2,4 GHz (global), 868 MHz, 915 MHz (regionais)
- **Taxa**: 250 kbps
- **Alcance**: 10-100m
- **Topologia**: Mesh
- **Consumo**: Ultra-baixo
- **Aplicação**: Monitoramento ambiental, saúde, industrial
- **Status**: Operacional, embedded Zigbee/Thread/LoRaWAN

### 6LoWPAN (IPv6 over Low Power Wireless Personal Area Network)
- **Padrão**: RFC 4944 (IPv6), RFC 6282 (compressão)
- **Tipo**: Encapsulação IPv6 em IEEE 802.15.4
- **Benefício**: IP nativo em dispositivos baixa potência
- **Status**: Operacional em IoT

### Mesh Networks
- **Topologia**: Auto-cicatrizante, cada nó relay
- **Protocolo**: AODV (Ad hoc On-Demand Distance Vector), Babel
- **Aplicação**: Distribuição de sensor, cobertura gap, comunidades
- **Status**: Crescimento (2020+)
- **Exemplo**: Open Mesh (comunidades), City-wide deployments

## Comunicação Molecular / Nanonetworks

### Molecular Communication
- **Status**: Pesquisa fundamental (2024-2030+)
- **Conceito**: Usar moléculas como portador (difusão)
- **Frequência**: Não aplicável (transporte molecular)
- **Taxa**: Ultra-baixa (bps-kbps)
- **Alcance**: Nanômetros até centímetros
- **Aplicação**: Nanotecnologia, saúde (corpo humano), pesquisa
- **Padrão**: Em desenvolvimento (IEEE 802.15.10 potencial)
- **Exemplo**: Bacteria communication, nano-robots dentro corpo
- **Horizonte**: 2035-2050

### Biophotonic Communication
- **Status**: Pesquisa (2024-2025)
- **Conceito**: Usar bioluminescência/fluorescência para comunição
- **Taxa**: Ultra-baixa
- **Aplicação**: Organismos vivos, biocomputadores
- **Horizonte**: 2030-2050

## Comunicação Gravitacional (Teórica)

### Gravitational Wave Communication
- **Status**: Conceitual (pesquisa 2024+)
- **Conceito**: Modular ondas gravitacionais para transmissão
- **Desafio**: Geração/detecção extremamente difícil
- **Potencial**: Comunicação cósmica
- **Horizonte**: 2050+

## Comunicação por Plasma

### Plasma Communication
- **Status**: Pesquisa (2024+)
- **Conceito**: Usar plasma controlado como portador
- **Frequência**: VLF-HF
- **Aplicação**: Comunicação subaquática alternativa, propulsão
- **Horizonte**: 2030-2050

## Broadcasting Terrestre

### Televisão Digital Terrestre (TDT)
- **Padrão**: DVB-T2 (Europa), ISDB-T (Brasil/Japão/Américas), ATSC 3.0 (USA)
- **Frequência**: 470-862 MHz (VHF/UHF)
- **Taxa de dados**: Múltiplos canais SD/HD em ~8 MHz
- **Modulation**: OFDM
- **Status**: Operacional, transmissão ainda forte
- **Transição**: Gradual para streaming (2025-2035)
- **Aplicação**: Radiodifusão publica, backup broadcasting
- **Vantagem**: Alcance amplo, reception grátis

### DVB-T2 (Digital Video Broadcasting - Terrestrial 2nd Generation)
- **Padrão**: ETSI EN 302 755
- **Frequência**: 470-862 MHz
- **Taxa**: Até 50 Mbps por multiplex
- **Modulation**: OFDM, múltiplas portadoras
- **Status**: Standard em Europa, crescimento global
- **Vantagem**: Eficiência espectral vs DVB-T
- **Aplicação**: TV aberta, radiodifusão

### ISDB-T (Integrated Services Digital Broadcasting - Terrestrial)
- **Padrão**: Arib STD-B31 (Japão), ABNT NBR 15601 (Brasil)
- **Frequência**: 470-806 MHz
- **Taxa**: 13-18 Mbps (multiplex)
- **Padrão**: OFDM
- **Status**: Operacional Brasil, América Latina, Japão
- **Feature**: One-seg (transmissão móvel integrada)
- **Aplicação**: TV terrestre, receção portátil

### ATSC 3.0 (Advanced Television Systems Committee 3.0)
- **Status**: Padrão ratificado (2017), implementação lenta USA
- **Frequência**: 470-806 MHz
- **Taxa**: 19-32 Mbps por multiplex
- **Modulation**: OFDM, LDPC
- **Vantagem**: Melhor eficiência, mobile TV, interatividade
- **Aplicação**: Futuro TV terrestre USA
- **Horizonte**: Rollout 2024-2030

## Comunicação por Infrared Direto (Ponto-a-Ponto)

### IR Remote Control
- **Frequência**: ~38 kHz (típico)
- **Tipo**: Simplex, comando
- **Alcance**: 10-15m
- **Padrão**: NEC, Sony, RC5, RC6
- **Status**: Ubíquo em eletrônicos
- **Taxa de dados**: Muito baixa (comando)

### IrDA (Infrared Data Association)
- **Frequência**: 875 nm IR
- **Taxa**: 115 kbps - 16 Mbps
- **Alcance**: 1 metro
- **Padrão**: IrDA 1.0 - 1.4
- **Status**: Descontinuado (substituído Bluetooth)
- **Histórico**: Popular 1990s-2000s em laptops, phones

## Comunicação para Aviação e Espaço

### VHF Aviação Comunicações
- **Frequência**: 118-137 MHz
- **Tipo**: AM, simplex
- **Alcance**: Até 200 km (altitude)
- **Status**: Padrão global aviação
- **Protocolo**: Simples voz FM (AM nome histório)
- **Aplicação**: Piloto-ATC comunicação

### ILS (Instrument Landing System)
- **Frequência**: 108-112 MHz
- **Tipo**: Navegação
- **Status**: Padrão aviação
- **Aplicação**: Aterrissagem zero-visibility

### DME (Distance Measuring Equipment)
- **Frequência**: 960-1215 MHz
- **Tipo**: Navegação, pulsos encoded
- **Status**: Padrão aviação

### Satellite L-Band Aeronáutica
- **Sistema**: Inmarsat, Iridium
- **Frequência**: 1.6-1.7 GHz
- **Aplicação**: Comunicação aeronave (ACARS avançado)
- **Status**: Operacional, backup crítico

## M2M (Machine-to-Machine) Geral

### MQTT (Message Queuing Telemetry Transport)
- **Protocolo**: TCP/IP baseado
- **Tipo**: Publish-subscribe
- **Taxa**: Até tamanho message (sem limite protocolo)
- **Alcance**: Internet (qualquer distância)
- **Status**: Standard IoT
- **Aplicação**: Sensores, atuadores, cloud integration
- **Exemplo**: AWS IoT, Azure Hub, Mosquitto

### CoAP (Constrained Application Protocol)
- **Protocolo**: UDP baseado
- **Tipo**: Request-response
- **Taxa**: Similar MQTT
- **Eficiência**: Menor overhead que HTTP
- **Status**: RFC 7252, implementado IoT
- **Aplicação**: Dispositivos baixa potência

### OPC UA (Open Platform Communications Unified Architecture)
- **Protocolo**: TCP/IP baseado
- **Tipo**: Cliente-servidor
- **Aplicação**: Automação industrial, interoperabilidade
- **Status**: Padrão industria 4.0
- **Padrão**: IEC 62541

## Comunicação Molecular de Difusão

### Molecular Diffusion Networks
- **Status**: Pesquisa fundamental (2024+)
- **Conceito**: Transmissor libera moléculas, receptor as detecta
- **Taxa**: Muito ultra-baixa
- **Aplicação**: Bio-nanonetworks, nanotecnologia
- **Horizonte**: 2040+

## Comunicação Eletromagnética Extrema Baixa Frequência (ELF)

### ELF Communication
- **Frequência**: 3-30 Hz
- **Taxa**: Ultra-baixa (1-10 bps)
- **Alcance**: Global (depende potência)
- **Aplicação**: Submarine communication (único penetra água)
- **Status**: Militar (não comercial)
- **Padrão**: Proprietário
- **Exemplo**: US Navy SEAFARER (descontinuado), HAARP
- **Desafio**: Antenas gigantescas

## Redes de Satélite de Constelação Híbrida

### LEO-GEO Hybrid Networks
- **Status**: Pesquisa/piloto (2024-2025)
- **Conceito**: Integrar LEO (baixa latência) + GEO (cobertura)
- **Aplicação**: Cobertura global ótima
- **Exemplo**: Projeto Starlink+Viasat+Intelsat integração
- **Padrão**: 3GPP NTN

## Comunicação de Curto Alcance Emergente

### Ultra-Wideband (UWB) Avançado
- **Frequência**: 3.1-10.6 GHz, 6-100 GHz (futuro)
- **Tipo**: Pulso extremamente curto
- **Taxa**: 110 Mbps - 1 Gbps
- **Alcance**: 10-200m
- **Padrão**: IEEE 802.15.4a (ZigBee), IEEE 802.15.4z
- **Status**: Crescimento (2022+) localização precisa, dados
- **Aplicação**: Localização indoor, pagamento contactless, autorização veículo
- **Vantagem**: Localização centimétrica
- **Exemplo**: iPhone 11+, Galaxy S21+, Tile Ultra

### Backscatter Communication
- **Status**: Pesquisa/protótipos (2023-2025)
- **Conceito**: Refletir sinais ambiente para comunicar (passivo)
- **Potência**: Ultra-baixa/nenhuma
- **Taxa**: kbps
- **Aplicação**: Sensores ultra-baixo-custo, indefinido-bateria
- **Exemplo**: Ambient Backscatter (academia), WiFi backscatter tags
- **Horizonte**: 2025-2030 comercial

## Tendências Gerais (2025-2030)

1. **Integração heterogênea**: Múltiplos protocolos single device (Matter, Thread, WiFi, BLE)
2. **Sustentabilidade**: Energy harvesting, zero-power communication
3. **IA em comunicação**: Otimização espectro, previsão interferência
4. **Segurança quântica**: QKD integrado redes
5. **Comunicação latência ultra-baixa**: Edge computing distribuído
6. **Coexistência espectral**: Sharing dinâmico frequências
7. **Protocolos convergentes**: 6G unificando múltiplas tecnologias
8. **Comunicação consciente contexto**: Inteligência na rede
9. **Resiliência**: Redes redundantes e auto-curativas
10. **Sustentabilidade**: Green communication protocols
