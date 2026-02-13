# 03 - REDES LOCAIS E PRÓXIMAS (LAN/WLAN/WPAN)

## ÍNDICE
1. WiFi (WLAN) - Evolução 802.11
2. Bluetooth/BLE
3. Zigbee/Thread/Matter
4. NFC/RFID
5. Li-Fi (Visible Light Communication)
6. Ultra-Wideband (UWB)
7. Síntese: Qual tecnologia para quê
8. Tendências 2025-2030

---

## 1. WiFi (WLAN) 802.11

### **802.11b (1999) - 1-2 Mbps**
- Frequência: 2.4 GHz (não licenciada ISM)
- Modulação: DSSS (Direct Sequence Spread Spectrum)
- Taxa: 11 Mbps teórico, 5 Mbps real
- Alcance: 100-150m em ambiente aberto
- Status: Obsoleto (2015+)

### **802.11g (2003) - 6-54 Mbps**
- Frequência: 2.4 GHz
- Modulação: OFDM (como 11a)
- Taxa: 54 Mbps teórico, 25-30 Mbps real
- Compatibilidade: Backward 802.11b (reduz velocidade)
- Status: Sunset (2018+)

### **802.11a (1999) - 6-54 Mbps**
- Frequência: 5 GHz (menos congestionada)
- Modulação: OFDM
- Taxa: 54 Mbps teórico, 30-40 Mbps real
- Uso: Corporativo, DFS (Doppler/radar awareness)
- Status: Obsoleto legado, base 802.11n/ac

### **802.11n (WiFi 4) - 2008-2024**

**Especificação**
- Frequência: 2.4 GHz + 5 GHz dual-band
- Modulação: OFDM (20 canais)
- Taxa: 150 Mbps (1 stream), 600 Mbps (4 streams) teórico
- Real: 50-100 Mbps (típico)
- MIMO: 2x2 até 4x4
- Latência: 20-50 ms
- Alcance: 100-250m

**Adoção**
- ✅ Padrão anterior 802.11ac
- 🔄 Ainda amplamente implantado (homes antigos, IoT)

### **802.11ac (WiFi 5) - 2014-2025**

**Especificação**
- Frequência: 5 GHz (banda estreita ~160 MHz)
- Modulação: OFDM (256-QAM)
- Taxa: 866 Mbps (1 stream), 1.3 Gbps (2 stream), 1.7 Gbps (3 stream)
- Real: 300-500 Mbps (típico)
- MIMO: 2x2 até 8x8 (MU-MIMO)
- Latência: 10-30 ms
- Alcance: 50-100m

**MU-MIMO (Multi-User MIMO)**
- Downlink: Router transmite múltiplos clientes simultâneos (não compartilhado)
- Uplink: Suporte Release 1 (2015)

**Adoção (2025)**
- ✅ Padrão atual (roteadores $50-200)
- ✅ Operacional ubíquo home/trabalho
- 🔄 Gradual substituição por 802.11ax

### **802.11ax (WiFi 6) - 2020-2025**

**Especificação**
- Frequência: 2.4 GHz + 5 GHz (160 MHz canais)
- Modulação: OFDM (1024-QAM)
- Taxa: 1.2 Gbps (1 stream), 2.4 Gbps (2 stream), 4.8 Gbps (pico com agregação)
- Real: 600-900 Mbps (típico)
- OFDMA: Múltiplos clientes compartilhado subcanal (vs MU-MIMO)
- Latência: 5-10 ms (melhorado)
- Eficiência: Target Wake Time (TWT) - deep sleep IoT

**Key Features**
- OFDMA: Compartilhamento espectro eficiente
- MU-MIMO: Uplink/downlink
- TWT: Agendamento sono economiza bateria
- BSS Coloring: Diferencia vizinhos múltiplos (reduz colisão)

**Adoção (2025)**
- ✅ Novo padrão (roteadores $100-300)
- ✅ Crescimento lento (2024-2025)
- 🎯 Substituição 802.11ac esperado 2026-2027

### **802.11be (WiFi 7) - 2024-2026**

**Especificação**
- Frequência: 2.4/5/6 GHz triple band
- Banda: 320 MHz (vs 160 MHz WiFi 6)
- Modulação: 4096-QAM (vs 1024-QAM WiFi 6)
- Taxa: 2.9 Gbps (single stream), 46 Gbps (aggregate teórico)
- Real esperado: 2-5 Gbps típico
- Latência: <1-2 ms (muito reduzido)
- Latência: 1-5 ms
- PPDU aggregation: Múltiplas frames
- MLO (Multi-Link Operation): Usar múltiplas bandas simultâneas

**6 GHz Unbanded (new)**
- Frequência: 5.850-7.125 GHz (US allocation, 1.2 GHz new)
- Uso: WiFi 6E (2021+) e WiFi 7 (2024+)
- Características: Menos congestionada, indoor penetration lower

**Adoção (2025)**
- 🔬 Protótipos 2023-2024
- 🔄 Primeiros produtos lançados 2024-2025
- 📅 Roteadores comerciais Q1-Q2 2025
- 🎯 Adoção mainstream 2026-2027

**Casos Uso WiFi 7**
- VR/AR wireless imersivo (<5ms latência)
- 8K video wireless
- Gaming multiplayer ultra-competitivo
- Cloud PC/gaming (ray tracing em tempo-real)

### **6GHz WiFi Allocation (2024-2025)**

| País/Região | Frequência | Canais | Status |
|------------|-----------|--------|--------|
| **EUA** | 5.850-7.125 GHz | 14 x 80 MHz | ✅ Vigente 2021 |
| **EU** | 5.925-6.425 GHz | 12 x 40 MHz | ✅ Vigente 2023 |
| **Brasil** | Consulta pública 2024 | TBD | 🔄 2025 definição |
| **Japão** | 6.0-6.2 GHz | Parcial | ✅ Vigente 2024 |
| **China** | Espectro restrito | Não público | ⚠️ Alocação distinta |

---

## 2. BLUETOOTH / BLE

### **Bluetooth Classic (2000-2025)**

**Especificação**
- Frequência: 2.4 GHz (ISM, 79 MHz band)
- Modulação: GFSK (Gaussian Frequency Shift Keying)
- Taxa: 3 Mbps (Bluetooth 3.0+), 2 Mbps (versões antigas)
- Alcance: 10-100m (dependente classe)
- Latência: 100-200 ms (tolerante para voz)

**Classes de Potência**
| Classe | Potência | Alcance |
|--------|----------|---------|
| 1 | 20 dBm (100 mW) | 100m |
| 2 | 4 dBm (2.5 mW) | 10-30m |
| 3 | 0 dBm (1 mW) | 1-10m |

**Casos Uso**
- Fones sem fio (headsets, earbuds clássico)
- Controle remoto
- Periféricos computador

**Status (2025)**
- ✅ Operacional ubíquo
- 🔄 Gradual migração BLE para wearables
- ⚠️ Descontinuação alguns fabricantes (foco BLE)

### **Bluetooth Low Energy (BLE)**

**Especificação**
- Frequência: 2.4 GHz (3 canais primários: 37, 38, 39)
- Modulação: GFSK (1 Mbps)
- Taxa: 1 Mbps (vs 3 Mbps Bluetooth classic)
- Alcance: 50-240m (vs 100m classic)
- Latência: 20-50 ms (10x melhor que classic)
- Bateria: Anos (vs dias/semanas classic)
- Throughput: 27 kbps (limited, designed IoT)

**Versões Recentes**

- **BLE 5.0 (2016)** - Extensão alcance 240m
- **BLE 5.1 (2019)** - Direction Finding AoA/AoD
- **BLE 5.2 (2020)** - Isochronous channels (latência fixa)
- **BLE 5.3 (2022)** - Advertising Extensions, Channel Classification
- **BLE 5.4 (2023)** - Backward compatibility, transports novas

**Topologia**
- Star (hub): Um central múltiplos periféricos
- Mesh (BLE Mesh 2014): Auto-healing network IoT
- Point-to-point
- Broadcast (beacon)

**Casos Uso**
- ✅ Wearables (smartwatch, fitness band, ring)
- ✅ Smart home (locks, thermostats, lights)
- ✅ Beacons (localização indoor)
- ✅ IoT sensores (temperatura, umidade)
- ✅ Hearing aids (auditivos digitais)

**Adoção Brasil (2025)**
- ✅ Ubíquo em smartphones
- ✅ Crescimento wearables
- ✅ Smart home adotando (ainda niche)

### **Bluetooth Mesh (BLE Mesh)**

**Conceito**
- Rede auto-reparável múltiplos hops
- Cada dispositivo retransmite (vs single hop BLE clássico)
- Cobertura: Centenas metros através paredes

**Topologia**
```
Relay 1 - Relay 2 - Device 3
  |         |
Device A   Device B
```

**Aplicações**
- Iluminação comercial (prédios)
- Smart buildings (>10.000 dispositivos)
- Industrial IoT

**Status (2025)**
- ✅ Operacional (Philips Hue iluminação, LEDVANCE)
- 🔄 Adoção crescimento lento (complexidade)
- 📅 Integração Matter esperada 2025+

---

## 3. ZIGBEE / THREAD / MATTER

### **Zigbee (IEEE 802.15.4 2003-2025)**

**Especificação**
- Frequência: 2.4 GHz (11-26 canais 16 MHz each)
- Modulação: OQPSK (Offset Quadrature Phase Shift Keying)
- Taxa: 250 kbps
- Alcance: 10-100m (dependente power)
- Latência: 30-100 ms
- Topologia: Mesh (auto-healing)

**Versões**
- Zigbee 1.0-2.0 (Consórcio Zigbee)
- Zigbee 3.0 (2015): Unificação banda 2.4 GHz + sub-GHz

**Casos Uso**
- Smart lighting (Philips Hue, LEDVANCE)
- Smart thermostats (Ecobee)
- Smart locks (algumas Yale)

**Status Brasil (2025)**
- 🔄 Adoção moderada (vs WiFi mais simples)
- 📍 Concentrado iluminação/climatização premium
- ⚠️ Ameaça: Matter (próximo tópico)

### **Thread (IEEE 802.15.4 IPv6)**

**Conceito**
- Mesh baseado IPv6 nativo
- Cada nó roteador (vs Zigbee com router específico)
- Integração Internet nativa (vs Zigbee bridge)
- Desenvolvido: Thread Group (Google/Apple/Samsung/Philips)

**Especificação**
- Frequência: 2.4 GHz (IEEE 802.15.4)
- Modulação: OQPSK (250 kbps)
- Topologia: Mesh IPv6
- Latência: <100 ms
- Segurança: AES-128

**Vantagens**
- Interoperável IPv6 (rede única vs silos)
- Self-healing automático
- Escalável (>300 nós típico)
- Transporte: 6LoWPAN (IPv6 low power wireless)

**Casos Uso**
- Smart home (Google Nest, Eve HomeKit)
- IoT industrial (futuro)

**Status (2025)**
- 🔬 Operacional Thread nativo 2020+
- ✅ Matter integration esperada 2025+
- 🎯 Adoção crescimento com Matter

### **Matter (Conectividade IP Agnóstica)**

**O que é**
- Camada applicação agnóstica (WiFi, Thread, BLE, mais)
- Criada: Connectivity Standards Alliance (ex-Zigbee Alliance)
- Objetivo: Eliminar silos "Matter for [X]"
- Versões: Matter 1.0 (2022), 1.1 (2023), 1.2 (2024), 1.3 (2025+)

**Stack**
```
┌──────────────────────────┐
│ Matter Application Layer │
│ (Clusters, Devices)      │
├──────────────────────────┤
│ Matter Common Protocol   │
│ (Messaging, Security)    │
├──────────────────────────┤
│ Transport Layer          │
│ ┌─────┬────────┬────────┐│
│ │WiFi │ Thread │  BLE   ││
│ └─────┴────────┴────────┘│
└──────────────────────────┘
```

**Device Types Matter**
- Lights (on/off, dimmer, color)
- Thermostats
- Locks/doors
- Plugs/outlets
- Sensors (temp, umidade, ocupação)
- Switches
- Shade curtains
- Cameras
- +50 tipos em desenvolvimento

**Adoção (2025)**
- ✅ Operacional: Apple HomeKit+Matter (2022+)
- ✅ Google Home+Matter (2023+)
- ✅ Amazon Alexa+Matter (2023+)
- ✅ Ecossistema crescendo (>2000 dispositivos Matter certificados)
- 🎯 2025 esperado tipping point (mainstream)

**Prognóstico Brasil (2025)**
- 🔬 Produtos Matter chegando 2024-2025
- 📈 Crescimento esperado 2025-2026
- 🎯 Padrão de facto 2027+

---

## 4. NFC / RFID

### **NFC (Near Field Communication)**

**Especificação**
- Frequência: 13.56 MHz
- Modulação: ASK/OOK
- Taxa: 106-424 kbps
- Alcance: 1-10 cm típico
- Latência: <1 ms
- Protocolo: ISO/IEC 14443, FeliCa, Mifare

**Modos**
- **Reader/Writer**: Smartphone lê tag estática
- **Peer-to-Peer**: Dois dispositivos trocar dados
- **Card Emulation**: Smartphone age como cartão (pagamento)

**Casos Uso**
- ✅ Pagamento móvel (Apple Pay, Google Pay)
- ✅ Pairing Bluetooth/WiFi (setup rápido)
- ✅ Acesso (cartões de proximidade)
- ✅ Tags informação (QR code alternativa)

**Adoção Brasil (2025)**
- ✅ Ubíquo smartphones (2020+)
- ✅ Operacional pagamentos
- 🔄 Crescimento infraestrutura varejo

---

## 5. LI-FI (Visible Light Communication)

### **Conceito**

Transmissão dados modulando luz visível (LED). Tecnologia em transição protótipos → comercial.

**Especificação**
- Frequência: 380-780 nm (espectro visível + IR próximo)
- Modulação: OFDM, PAM, OOK
- Taxa: 100-300 Mbps (lab), 50-100 Mbps (comercial esperado)
- Latência: <1 ms
- Alcance: 5-30m (dependente intensidade)
- Penetração: Não atravessa paredes (vantagem privacidade)

**Padrão: IEEE 802.11bb (2023)**
- Parte 802.11 estendida para VLC/OWC
- Modulation: OFDM
- Taxa: 40-150 Mbps target

**Implementadores (2024-2025)**
- **Philips Hue**: Li-Fi integrado iluminação (testes 2024-2025)
- **Cisco**: Infraestrutura Li-Fi campus
- **Sunrgi**: Chip Li-Fi (spinoff MIT)
- **Purdue**: Pesquisa THz-inspired comunicação visível

### **Vantagens**
- Comunicação + iluminação simultânea
- Privacidade (luz não penetra paredes)
- EMI immunity (não interfere RF)
- Espectro não licenciado muito amplo

### **Desvantagens**
- Linha de vista requerida
- Bloqueio por objetos/pessoas
- Latência luz ambiente (sensor jitter)
- Manutenção linha de vista durante movimento

### **Casos Uso Esperados (2025-2026)**
- Datacenters (banda larga, alta densidade)
- Hospitais (RF-free zones)
- Aeronaves (backup conectividade)
- Smart homes premium (integração iluminação)

### **Status (2025)**
- 🔬 Protótipos comerciáveis
- 🔬 Primeiros produtos lançamento 2025-2026 (esperado)
- 📅 Comercialização mainstream 2027-2030

---

## 6. UWB (Ultra-Wideband)

### **Especificação**

- Frequência: 3.1-10.6 GHz
- Banda: 500 MHz+ tipicamente
- Taxa: 100 Mbps-7 Gbps (depende band/range)
- Alcance: 200m (vs 100m Bluetooth)
- Latência: <10 ms
- Localização: Precisão 10-30 cm (AoA/AoD)
- Power: Ultra-baixo (pulse-based)

### **Caso Uso Principal: Localização Precisa**

**Smartphones Atuais com UWB**
- Apple: iPhone 11+ (UWB chip)
- Samsung: Galaxy S21+ (UWB chip)
- Google: Pixel 6+ (UWB esperado 2025)

**Aplicações**
- **Car access**: Unlock carro proximidade 2m (vs 10m RF classic)
- **Device tracking**: AirTags-like, precisão cm
- **Navigation**: Navegação interior <30 cm
- **Robot fleet**: Coordenação automática fábricas
- **Construction**: Medição precisa volumes

### **Status (2025)**
- ✅ Operacional: Apple Car Key, KeySharing (2021+)
- 🔄 Expansão: Android OEM começando suporte
- 📈 Adoção crescimento 2025-2026
- 🔬 Casos uso novos explorando

---

## 7. SÍNTESE: QUAL TECNOLOGIA?

| Caso Uso | Tecnologia | Razão |
|----------|-----------|-------|
| **WiFi casa** | 802.11ax (WiFi 6) | Banda larga, simplicidade |
| **WiFi empresa** | 802.11ax + 6GHz | Densidade, sem congestionação |
| **IoT bateria longa** | BLE ou NB-IoT | Ultra-baixo consumo, mesh |
| **Smart home novo** | Matter+Thread/WiFi | Padrão aberto, interoperável |
| **Smart home legacy** | Zigbee | Muitos dispositivos existentes |
| **Wearables** | BLE 5.4 | Bateria, taxa, latência |
| **Fones premium** | Bluetooth classic 5.0+ | Taxa 3 Mbps, qualidade áudio |
| **Localização precisa** | UWB | 10-30 cm, rápido handover |
| **Pagamentos móvel** | NFC | Contactless padrão Europeu |
| **VR/AR wireless** | WiFi 7 (2026+) ou 6G | Ultra-baixa latência |
| **Lighting iluminação** | Zigbee/Matter ou Li-Fi futuro | Controle + iluminação |
| **Industrial IoT** | Thread mesh + Matter | Escalabilidade, IP nativo |

---

## 8. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- WiFi 7 primeiros roteadores consumer
- Matter mainstream adoção (>5 milhões dispositivos)
- Li-Fi protótipos → comercial
- 6GHz WiFi alocação Brasil (esperada)

**Médio Prazo (2026-2027)**
- WiFi 7 padrão (como WiFi 6 hoje 2024)
- Matter padrão de facto smart home
- Li-Fi comercialização larga (2026+)
- Thread ubíquo (matter integration)
- UWB expansão Android OEM

**Longo Prazo (2028-2030)**
- WiFi 7 substituição WiFi 6 maioria
- Li-Fi secundário LAN (premium/special cases)
- 6GHz expansão 50%+ RF capacity
- BLE mesh integração Matter
- THz links experimentais (futuro 6G)

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
