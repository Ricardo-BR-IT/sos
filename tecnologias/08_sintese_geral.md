# 08 - SÍNTESE GERAL E MATRIZ COMPARATIVA

## ÍNDICE
1. Tabela Resumida Tecnologias Comunicação
2. Matriz Decisão Tecnologia
3. Roadmap Tecnológico Brasil 2025-2030
4. Recomendações por Caso Uso
5. Glossário Técnico

---

## 1. TABELA RESUMIDA TECNOLOGIAS COMUNICAÇÃO

### **Ordenado por Frequência**

| Frequência | Tecnologia | Taxa | Alcance | Topologia | Latência | Consumo | Status Brasil | Caso Uso Principal |
|-----------|-----------|------|---------|-----------|----------|---------|-----------------|-------------------|
| **DC-10 Hz** | Power Line | 50-600 kbps | 100m-1km | Ponto-ponto | ~100ms | Alto | ✅ Ativo | Smart Grid, smart meter |
| **3-30 MHz** | HF/NVIS | 50-300 bps | 50-1.000km | Broadcast | ~500ms | Médio | ✅ Amador | Emergência, amador longa distância |
| **88-108 MHz** | FM Radiodifusão | N/A | 80-100km | Broadcast | 0 (analógico) | Baixo | ✅ Ubíquo | Rádio comercial |
| **174-240 MHz** | DAB+ Digital | 9-192 kbps | 80-150km | Broadcast | <100ms | Médio | 🔄 Testes | Rádio digital (futuro FM) |
| **387-403 MHz** | PMR/Walkie-Talkie | N/A | 10-40km | Duplex | <100ms | Médio | ✅ Ativo | Comunicação tática/empresa |
| **402-405 MHz** | Radioamador | N/A | 10-100km | Simplex | 100-500ms | Médio | ✅ Ativo | Amador, emergência |
| **420-450 MHz** | UHF Aéreo | N/A | 50-100km | Duplex | <100ms | Médio | ✅ Ativo | Aéreo, tático |
| **698-806 MHz** | LTE / Celular TV | Até 300 Mbps | 35-50km | Celular | 30-100ms | Médio | ✅ Ubíquo | Mobilidade primária |
| **800-900 MHz** | Celular 800 | Até 150 Mbps | 40-60km | Celular | 30-100ms | Médio | ✅ Ubíquo | Cobertura interior rural |
| **850 MHz** | Satélite IoT | 1-10 kbps | Cobertura global | Satelite | 200-1.000ms | Baixo | 🔄 Crescimento | IoT cobertura global |
| **868 MHz** | LoRaWAN | 50 kbps | 15km LdV | Star | 1-10s | Ultra-baixo | 🔄 Piloto | Sensor longa distância |
| **902 MHz** | Sigfox | 12 bps | 40-50km | Star | 10-60s | Ultra-baixo | 🔄 Limitado | Telemetria barata |
| **915 MHz** | ISM (Xbee, Zigbee) | 100-250 kbps | 100m-1km | Mesh | 50-200ms | Médio-baixo | ✅ Ativo | IoT doméstico, industrial |
| **1-2 GHz** | Bluetooth | 2 Mbps | 240m | Ponto-ponto | 10-50ms | Médio | ✅ Ubíquo | Wearable, periféricos |
| **1.8-2.1 GHz** | Celular 2G/3G/4G | Até 300 Mbps | 35-50km | Celular | 50-150ms | Alto | ⚠️ Obsoleto 2G/3G | Legado (descontinuar) |
| **2.4 GHz** | WiFi | 50-1.200 Mbps | 100-300m | WLAN | 10-50ms | Alto | ✅ Ubíquo | Broadband primário |
| **2.6 GHz** | LTE-M | 250 kbps | 25km | Celular | 50-100ms | Médio-baixo | 🔄 Piloto | IoT celular, fone |
| **3-6 GHz** | C-Band Satélite | 10-50 Mbps | Global | Satélite | 500-700ms | Alto | 🔄 Crescimento | Internet rural, backup |
| **5 GHz** | WiFi5/6 | 200-2.400 Mbps | 100-200m | WLAN | 10-30ms | Alto | ✅ Ubíquo | Broadband próxima geração |
| **6 GHz** | WiFi6E | 2.4-10 Gbps | 100m | WLAN | 10-30ms | Alto | ⏳ 2026-2027 | WiFi ultra-rápido futuro |
| **10-100 GHz** | Microondas backhaul | 10 Mbps-10 Gbps | 50-100km | Ponto-ponto | <50ms | Alto | ✅ Operador | Backhaul operadora |
| **20+ kHz (ultrassônico)** | Ultrassônico | 100-500 bps | 0.5-3m | Ponto-ponto | <50ms | Baixo | 🔄 Nicho | Proximidade, indoor tracking |
| **Acústica subaquática** | Acoustic modem | 50-13 kbps | 1-100km subaq | Ponto-ponto | 100-1.000ms | Médio | 🔬 Pesquisa | Comunicação submarino |

---

## 2. MATRIZ DECISÃO TECNOLOGIA

### **Qual Tecnologia Escolher?**

**Pergunta 1: Qual alcance necessário?**

```
Curto (< 1 km)
├─ WiFi (taxa alta)
├─ Bluetooth (baixo consumo)
├─ Zigbee (IoT mesh)
└─ Ultrassônico (privacidade proximidade)

Médio (1-50 km)
├─ Celular LTE (ubiquidade)
├─ LoRaWAN (baixo consumo longa distância)
├─ WiFi Outdoor + repetidor (custo baixo)
└─ UHF Walkie-talkie (sem infraestrutura)

Longo (50-1.000 km)
├─ HF Rádio Amador (sem infraestrutura)
├─ Satélite (cobertura global)
├─ LTE-M/NB-IoT (celular baixo consumo)
└─ Sigfox (telemetria ultra-barata)

Muito Longo (> 1.000 km, Global)
├─ Satélite (cobertura global 24/7)
├─ Internet via fibra (se infraestrutura)
├─ HF Rádio Múltiplos saltos
└─ Satélite Constelação Starlink (crescimento)
```

**Pergunta 2: Qual consumo energético?**

```
Ultra-Baixo (<1 mA médio, 10+ anos bateria AA)
├─ LoRaWAN
├─ Sigfox
├─ NB-IoT
└─ Sensor ultrassônico passivo

Baixo (1-10 mA médio, 1-5 anos bateria)
├─ Bluetooth Low Energy
├─ Zigbee
├─ WiFi com sleep agressivo
└─ GPS Rastreador + celular intermitente

Médio (10-100 mA médio, dias-semana bateria)
├─ WiFi ativo
├─ Celular LTE
├─ HF Radio transmissão contínua
└─ Microfone + processador local

Alto (>100 mA médio, horas bateria)
├─ Transmissão HF contínua
├─ WiFi Hotspot
├─ Satélite high-bandwidth
└─ Processamento GPU local
```

**Pergunta 3: Qual custo por dispositivo?**

```
Custo Baixo (< R$ 100 / $ 20)
├─ Sensor LoRaWAN
├─ Sigfox rastreador
├─ Módulo Zigbee
└─ Receptor FM genérico

Custo Médio (R$ 100-500 / $ 20-100)
├─ Telefone IP (refurbished)
├─ Gateway LoRaWAN / WiFi
├─ Smartphone básico
└─ Modem SIM card LTE

Custo Alto (R$ 500-5.000 / $ 100-1.000)
├─ Equipamento satélite terminal
├─ Estação rádio profissional
├─ Access point WiFi industrial
└─ Servidor VoIP PBX

Custo Muito Alto (> R$ 5.000)
├─ Infra satélite uplink
├─ Torre celular completa
├─ Sistema sonar subaquático
└─ Estação HF profissional
```

**Pergunta 4: Qual requisito Latência?**

```
Baixa (<50 ms) - Tempo Real
├─ Voz/Vídeo: VoIP, WebRTC
├─ Jogos: WiFi, celular LTE
├─ Controle: Bluetooth, UHF duplex
└─ Telemetria crítica: Microondas backhaul

Média (50-500 ms) - Interativo
├─ Mensagens: WhatsApp, email
├─ Sensores: LoRaWAN, Zigbee
├─ HF Radio: Comunicação amador
└─ Satélite LEO: Video conferência

Alta (500+ ms) - Não-crítico
├─ Telemetria: Sigfox, satélite GEO
├─ Backup: Satélite broadband
├─ Acústica subaquática
└─ Rádio FM / AM
```

### **Matriz 2x2: Simplicidade vs Performance**

```
                    SIMPLES         COMPLEXO
PERFORMANCE
ALTA        WiFi 6E, LTE      Satélite, Micr-ondas
MÉDIA       WiFi, BLE        LoRaWAN, HF
BAIXA       FM, AM           Power Line, Ultrassônico
```

**Recomendação**
- Começar canto inferior-esquerdo (simples + performance)
- Evitar canto superior-direito (complexo + low return)
- Escalabilidade: WiFi→LTE→Satélite; Bluetooth→Zigbee→LoRaWAN

---

## 3. ROADMAP TECNOLÓGICO BRASIL 2025-2030

### **2025 (Ano Atual)**

**Tecnologias Consolidadas**
- ✅ Celular LTE ubíquo (4G)
- ✅ WiFi padrão (802.11ac)
- ✅ FM Rádio (ainda dominante)
- ✅ VoIP softphone crescimento
- ✅ Bluetooth periféricos padrão
- ✅ LoRaWAN pilotos iniciam

**Transições Observadas**
- 🔄 2G/3G descontinuação acelera
- 🔄 5G cobertura expandindo
- 🔄 NB-IoT primeiros deployments operadora
- 🔄 Starlink internet rural início

**Investimentos Anunciados**
- Vivo, TIM, Claro: 5G cobertura 50%+ população
- Anatel: Leilão 5G faixa C-band (2025)
- Operadora: Desligamento 3G 2025-2026

### **2026 (Transição)**

**Esperado**
- ✅ 5G cobertura urbana principais cidades
- ✅ WiFi6 padrão residencial
- ⚠️ FM Rádio descontinuação início (alguns estados)
- ✅ DAB+ testes expandem
- 🔄 NB-IoT cobertura nacional pilotos
- 🔄 Starlink/Amazonisat satélite internet

**Fim de Vida**
- ❌ 3G encerramento oficial Brasil
- ❌ 2G completamente obsoleto

**Investimentos**
- ANATEL: Regulamentação DAB+ expansão
- Operadoras: IPv6 migração LTE/5G
- Telebrás: Satélite Amazonisat operação

### **2027-2028 (Consolidação)**

**Expectativa**
- ✅ 5G cobertura 70%+ Brasil
- ✅ WiFi6E iniciar deployment (2027+)
- ✅ NB-IoT ubíquo smart metering
- ✅ DAB+ cobertura expandida (não FM dominante ainda)
- ✅ Satélite Starlink/Amazon Kuiper 1.000+ estações
- 🔬 6G pesquisa acelera

**Fim de Vida**
- ⚠️ FM rádio descontinuação múltiplos países (ainda Brasil?)
- ❌ Power Line 2G obsoleto (PRIME v2.0 adoptado)

**Investimentos**
- Brasil: Fiber-optic federal expandir
- Operadoras: Edge computing 5G preparando
- Pesquisa: Universidades 6G consortiuns

### **2029-2030 (Pós-5G)**

**Visão**
- ✅ 5G cobertura 85%+ Brasil
- ✅ WiFi6E comum (preparação WiFi7 futuro)
- ✅ Satélite internet rural "última milha"
- ⏳ 6G primeiro deployment testbeds
- 📡 Quantum network testes primeiros
- ⚠️ FM rádio marginal (podcast/streaming dominam)

**Tendência**
- Fragmentação espectro: Tráfego data crescimento 300%+
- Segurança: Post-quantum criptografia padrão
- Sustentabilidade: 5G power consumption otimização
- Regulação: Internacionalização padrões

---

## 4. RECOMENDAÇÕES POR CASO USO

### **IoT Sensor Distribuído (1.000+ nós)**

**Recomendação**
1. **Primeira escolha**: LoRaWAN (alcance, custo, consumo)
2. **Alternativa**: Zigbee (alcance reduzido, mesh, complex)
3. **Alternativa**: NB-IoT (requer operador, mas ubíquo futuro)

**Motivo**
- LoRaWAN: TTN gratuito + equipamento barato + gateway simples
- Gateway: Raspberry Pi + LoRa shield (~R$ 300)
- Nó sensor: ~R$ 50 (módulo LoRa + sensor)
- Consumo: 10+ anos bateria AA esperado
- Cobertura: 15 km linha de vista (urbano ~5km)

**Brasil 2025**
- TTN cobertura crescendo (São Paulo, Rio, BH, Brasília)
- Operadores: Vivo/TIM NB-IoT piloto (mais caro)
- Recomendação: LoRaWAN até operador NB-IoT ubíquo

### **Comunicação Emergência (Sem infraestrutura)**

**Recomendação**
1. **Primeira escolha**: Rádio Amador HF (experiência + legítimo)
2. **Alternativa**: Walkie-talkie UHF simplex (sem licença, alcance 5-10km)
3. **Backup**: Satellite messaging (Garmin, Apple Emergency SOS)

**Motivo**
- HF: Pode atingir 1.000+ km sem repetidor (ionosfera)
- Amador: Comunidade LBRA Brasil treinada emergência
- Walkie-talkie: Acessível, imediato (sem rede celular)
- Satélite: Cobertura 100% global (custo subscriptions)

**Recomendação Setup**
```
Estação Fixa HF:
- Transceptor: Icom IC-7300 (~R$ 8.000)
- Antena: Dipolo half-wave 10m (~R$ 300)
- Bateria: UPS 2.000W (~R$ 3.000)
Total: ~R$ 11.000 estação completa

Portable:
- Transceptor: QRP 5W (~R$ 1.500)
- Antena: Whip vertical portátil
- Bateria: 20 Ah LiFePO4 (~R$ 500)
Total: ~R$ 2.000 estação mobile
```

### **Internet Cobertura Rural**

**Recomendação (Priority Order)**
1. **Melhor**: Fiber-optic já presente (executar)
2. **Segundo**: Satélite internet (Starlink, Viasat, Amazonisat)
3. **Terceiro**: LTE rural (operadora cobertura existente)
4. **Último**: WiFi backhaul PTP (ponto-ponto distância)

**2025 Situação Brasil**
- Starlink: ~20.000 subscriptores Brasil (crescimento)
- Velocidade: 50-150 Mbps (vs 5-10 Mbps 4G)
- Latência: 30-50ms (vs 50-100ms GEO tradicional)
- Custo: ~R$ 599 mensalmente (equipamento)

**Recomendação**
- **Rural próximo cidade** (~50km): Satélite Starlink
- **Rural remoto** (>50km): Satélite + Sigfox telemetria
- **Interior com LTE**: Esperir 5G operadora (melhor preço futuro)

### **VoIP Enterprise (100-1.000 usuários)**

**Recomendação**
1. **Melhor**: 3CX PBX nuvem (gerenciado)
2. **Alternativa**: Asterisk/FreePBX (self-hosted, técnico)
3. **Alternativa**: Microsoft Teams (se Office 365 já)

**Motivo**
- 3CX: Interface moderna + suporte português
- Custo: ~R$ 2.000/ano 100 usuários (vs R$ 20.000 Cisco legado)
- Escalabilidade: Cresce até 10.000 usuários
- Codec: Opus (melhor voz comprimida)

**Infraestrutura**
```
Topologia:
Telefone IP/Softphone -WiFi/Ethernet-> 3CX Server (cloud) -Internet-> Operadora PSTN/Outro VoIP

3CX Cloud:
- Uptime: 99.9% SLA
- Localização servidor: Região geográfica
- Backup: Replicação automática
```

### **Rádio Digital Futura Preparação**

**Recomendação**
- **Curto prazo** (2025): Manter FM (audiência ainda existe)
- **Médio prazo** (2026): DAB+ testes complementares
- **Longo prazo** (2027+): Planejamento FM descontinuação

**Brasil Contexto**
- FM dominância: 300+ estações operacionais
- Receita: Publicidade 80% (vs streaming)
- Consumidor: Hábito carro + emergência
- Transição: 10+ anos esperado (vs 5 anos EU)

**Recomendação Setup DAB+**
```
Custa alto (CAPEX 1-5M R$ operadora):
- Multiplex: 6-10 programas por 8 MHz
- Transmissor: 1-10 kW típico
- Cobertura: Metropolitano (vs nacional FM)

Esperar:
- Receptores smartphone integrado (mais comum)
- Mais programadores adotarem
- Subsídio governo/anatel
```

---

## 5. GLOSSÁRIO TÉCNICO

### **Siglas Frequentes**

| Sigla | Expansão | Explicação |
|-------|----------|-----------|
| **LPWAN** | Low-Power Wide-Area Network | Redes larga área baixo consumo (LoRa, Sigfox, NB-IoT) |
| **LTE** | Long-Term Evolution | Padrão 4G celular (3GPP Release 8+) |
| **NR** | New Radio | Padrão 5G 3GPP (Release 15+) |
| **UE** | User Equipment | Dispositivo móvel (smartphone, IoT) |
| **RAN** | Radio Access Network | Camada rádio (antena, transceptor) |
| **CN** | Core Network | Camada núcleo (roteador, servidor) |
| **SLA** | Service Level Agreement | Garantia uptime/performance |
| **QoS** | Quality of Service | Prioridade tráfego (latência, jitter) |
| **VoIP** | Voice over IP | Telefonia via internet |
| **SIP** | Session Initiation Protocol | Protocolo controle VoIP (RFC 3261) |
| **RTP** | Real-Time Transport Protocol | Protocolo transporte mídia (RFC 3550) |
| **SRTP** | Secure RTP | RTP encriptado (DTLS) |
| **WebRTC** | Web Real-Time Communication | Comunicação tempo real navegador |
| **ASR** | Automatic Speech Recognition | Reconhecimento automático voz |
| **TTS** | Text-To-Speech | Síntese voz |
| **MFCC** | Mel-Frequency Cepstral Coeff. | Extrato acústico para ML |
| **FFT** | Fast Fourier Transform | Análise espectral |
| **SDR** | Software-Defined Radio | Rádio controlado software |
| **GNU Radio** | Open source SDR | Framework GNU Radio |
| **USRP** | Universal Software Radio Periph. | Hardware Ettus Research |

### **Conceitos Fundamentais**

**Modulação**: Variação parâmetro sinal portadora (amplitude, frequência, fase)
- **AM**: Varia amplitude
- **FM**: Varia frequência
- **PSK**: Varia fase
- **OFDM**: Múltiplas subcarriers (WiFi, LTE)

**Largura Banda**: Espectro frequência sinal ocupa
- Maior banda = taxa bits potencial maior
- Reduz capacidade múltiplos usuários (colisão)

**Latência**: Tempo propagação dados origem→destino
- Crítico: VoIP (<50ms), gaming (<100ms)
- Tolerável: Email, streaming (1000+ ms ok)

**Jitter**: Variação latência entre packets
- RTP + jitter buffer mitiga efeito
- Fala jitter >50ms afeta qualidade

**Throughput**: Taxa dados efetiva real
- Diferente teórico (overhead protocol, retransmissão)
- WiFi teórico 1200 Mbps vs real 400 Mbps típico

**SNR (Signal-to-Noise Ratio)**: Proporção sinal desejado vs ruído
- SNR > 10 dB: Bom
- SNR 0-10 dB: Aceitável
- SNR < 0 dB: Indetectável

---

## RESUMO EXECUTIVO

**Para Decisões Rápidas**

### **Melhor Tecnologia por Categoria**

| Categoria | Melhor Escolha | 2ª Opção | 3ª Opção |
|-----------|---------------|----------|----------|
| **IoT Sensor** | LoRaWAN | NB-IoT | Zigbee |
| **Voz** | VoIP (webRTC) | Celular LTE | HF Rádio |
| **Broadcast** | FM | WiFi / Internet | DAB+ (futuro) |
| **Broadband Casa** | WiFi6 | Fibra | Satélite |
| **Emergência** | HF Amador | Satélite IoT | Walkie-Talkie |
| **Smart City** | LoRaWAN + 5G | NB-IoT | Zigbee |
| **Logística** | LTE-M / Satélite | LoRaWAN | GPS + 4G |
| **Agricultura** | LoRaWAN | Zigbee | NB-IoT |

### **Investimento Recomendado 2025**

1. **Curto (Imediato)**
   - LoRaWAN gateway + sensores (baixo risco)
   - WiFi6 gradual renovação
   - VoIP migração legado

2. **Médio (12-24 meses)**
   - 5G pilotos cobertura
   - NB-IoT testes
   - Satélite backup internet

3. **Longo (2+ anos)**
   - DAB+ transição FM
   - WiFi6E deployment
   - 6G pesquisa/partnership

---

**Documento Versão: 2025-01**
**Próxima atualização: Junho 2025**
**Mantém/Revisa**: Janeiro de cada ano
