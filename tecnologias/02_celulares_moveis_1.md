# 02 - SISTEMAS MÓVEIS E CELULARES

## ÍNDICE
1. Evolução Gerações (2G-6G)
2. Tecnologias GSM/3GPP
3. Arquitetura 5G/6G
4. Bandas de Frequência
5. Protocolos e Padrões
6. Sistemas em Desenvolvimento
7. Open RAN e Virtualização
8. Tendências 2025-2030

---

## 1. EVOLUÇÃO GERAÇÕES

### **2G - GSM (Global System Mobile) - 1991-2025**

**Especificação**
- Frequência: 850/900/1800/1900 MHz
- Modulação: GMSK (Gaussian Minimum Shift Keying)
- Taxa: 9.6 kbps voz, 14.4 kbps dados (GPRS+)
- Cobertura: Global ubíqua

**Operadores Principais**
- Brasil: Vivo, TIM (finalizando 2025-2026)
- Global: 5 bilhões dispositivos ainda em uso
- Serviços: Voz, SMS, dados lentíssimo

**Descontinuação (2025-2028)**
- Brasil: Agência Nacional Telecomunicações anúncio 2025
- US: AT&T (2022), Verizon (2024), T-Mobile (2026)
- EU: Variável por país (2026-2028)

**Motivo Desligamento**
- Espectro liberado para 4G/5G
- Segurança: 64-bit criptografia obsoleta
- Eficiência: Consumo energia > LTE

### **2.5G - GPRS/EDGE (1999-2025)**

**GPRS (General Packet Radio Service)**
- Taxa: 56 kbps (teórico), 28 kbps (real), 14.4 kbps usual
- Uso: Email, navegação básica WAP
- Tecnologia: Packet-switched overlay GSM

**EDGE (Enhanced Data Rates)**
- Taxa: 236 kbps (teórico), 100 kbps (real)
- Melhoria: Modulação 8-PSK
- Uso: Foto baixa resolução, aplicativos leves

**Status: Descontinuação junto GSM (2025-2028)**

### **3G - UMTS/WCDMA (2002-2028)**

**UMTS (Universal Mobile Telecom System)**
- Frequência: 2100 MHz principalmente (900/850 MHz secundário)
- Modulação: WCDMA (banda larga 5 MHz)
- Taxa: 384 kbps comum, 2 Mbps pico
- Serviço: Vídeo chamada, streaming básico

**HSPA/HSPA+** (Melhorias UMTS, 2006-2015)
- HSPA: 14 Mbps downlink
- HSPA+: 42 Mbps downlink (MIMO duplo, 5 portadoras)
- Uso: Ponte 3G→4G

**Status: Sunsetting (2025-2028)**
- Descontinuação começando EUA/EU (2025)
- Alguns países Ásia/Latam (2027-2028)
- Coexistência LTE para roaming

### **4G - LTE (Long Term Evolution) - 2010-2040+**

**LTE Release 8** (2010)
- Frequência: Multiplas: 700, 850, 900, 1800, 2100, 2300, 2600+ MHz
- Modulação: OFDM (downlink), SC-FDM (uplink)
- Taxa: 150 Mbps (Release 8), 300 Mbps (Release 10, MIMO 4x4)
- Latência: 50-100 ms
- Espectro: 1.4-20 MHz canal
- Padrão: 3GPP Release 8

**LTE-A (Advanced) - Release 10-13** (2014-2016)
- Taxa: 300 Mbps (2CC), 600 Mbps (4CC), 1 Gbps (8CC Carrier Aggregation)
- MIMO: Até 8x8
- Modulação: 256-QAM downlink, 64-QAM uplink
- Full-duplex: FDD ou TDD (operadores flexível)

**LTE-M (eMTC)** (IoT longo alcance)
- Taxa: 1 Mbps
- Alcance: Similar 3G/HSPA
- Consumo: 10+ dias bateria
- Implementação: 2014+

**LTE Cat-NB1 / NB-IoT** (Próximo tópico)

**LTE Status (2025)**
- ✅ Operacional ubíquo 4G/LTE-A
- ✅ Dominante conectividade móvel 50% mercado
- ⚠️ Gradual substituição 5G (2025-2035)
- ✅ Suporte LTE-M/NB-IoT expandido

### **4.5G - LTE-Advanced Pro / Cat-NB (2016-2025)**

**NB-IoT (Narrowband IoT)**
- Frequência: LTE band pairs (1.4 MHz ou 200 kHz sub-carrier)
- Taxa: 250 kbps downlink, 20 kbps uplink
- Latência: 10+ segundos (tolerante IoT)
- Alcance: 35 km línea-de-vista
- Bateria: 10+ anos (teórico)
- Operadores: Brasil (Vivo, TIM, Claro - 2022+)

**LTE-M / eMTC**
- Taxa: 1 Mbps (10x NB-IoT)
- Alcance: Semelhante NB-IoT
- Latência: 100-200 ms
- Foco: Wearables, localização, vídeo leve

**Status NB-IoT/LTE-M (2025)**
- 150+ operadores globalmente
- Brasil: Crescimento 2024-2025
- Preferência: NB-IoT (eficiência), LTE-M (velocidade)

### **5G - NR (New Radio) - 2020-2030+**

**5G FR1 (Frequency Range 1)** - Sub-6 GHz
- Banda: 450 MHz - 6 GHz
- Principais: n78 (3.5 GHz), n79 (4.5-4.9 GHz), n41 (2.5 GHz)
- Taxa: 1-10 Gbps (1200 Mbps típico)
- Latência: 1-20 ms
- MIMO: Até 64x64 (massive MIMO)
- Modulação: QPSK, 16-QAM, 64-QAM, 256-QAM

**5G FR2 (mmWave)** - Milimétricas
- Banda: 24.25-100 GHz
- Principais: n257 (28 GHz), n258 (39 GHz), n260 (39 GHz)
- Taxa: 10-20 Gbps (pico, real 2-5 Gbps)
- Latência: <1 ms
- Propagação: Linha de vista, chuva atenua
- Foco: Interiores densos, estádios, campuses

**5G RAN Arquitetura**
- **NSA (Non-Standalone)**: LTE anchor, 5G enhancement (2020-2023)
- **SA (Standalone)**: 5G núcleo nativo (2021+)

**5G Casos Uso**
- **eMBB (Enhanced Móbile Broadband)**: Video 4K/8K, VR/AR
- **URLLC (Ultra-Reliable Low-Latency)**: Cirurgia remota, carros autônomos
- **mMTC (Massive Machine Type Comm)**: Bilhões IoT simultâneos

**5G Status Brasil (2025)**
- ✅ Operacional: Vivo, TIM, Claro, Oi
- ✅ Cobertura: 95%+ capitais, 60%+ interior
- 🔄 Expansão: Interiores, periferia (2024-2025)
- ⚠️ Falta: mmWave maioria cidades (custos altos)

### **5G Advanced / 5G+ (2024-2028)**

**3GPP Release 17-18 (2023-2025)**
- Uplink melhorado (duplex completo)
- UL grant-free (reduz overhead)
- Satélite NTN integração
- D2D satélite (iPhone, Starlink)
- Reconfigurable Intelligent Surfaces (RIS) teoria

**3GPP Release 19-20 (2026-2028)**
- 6G foundations (sub-THz research)
- Energy efficiency improvements
- Full integration heterogeneous networks

**Frequências 5G Novas (2024-2025)**
- **n96** (3.7 GHz faixa, China)
- **n90** (2.3 GHz, realocação)
- **6 GHz unlicensed**: WiFi + cellular coexistence (experimentais)

**Status 5G Advanced (2025)**
- 🔄 Protocolos finalizando
- 🔄 Implementação chipsets (Snapdragon Gen 3 2024)
- 🔬 Lab tests começando
- 📅 Comercialização 2026+

### **6G - IMT-2030 (2030-2035)**

**Visão 6G**
- Frequência: Sub-THz (100-300 GHz), THz (0.3-3 THz)
- Taxa: 100+ Gbps (100x 5G)
- Latência: <0.1 ms (10x 5G)
- Caso uso: Holografia, extended reality nativa, IA ubíqua
- Sustentabilidade: Energy-efficient by design

**Características 6G**
- Reconfigurable Intelligent Surfaces (RIS) nativa
- THz + Sub-THz múltiplas bandas
- AI/ML native network (não apenas aplicação)
- Quantum integration (QKD + procesamento)
- Satélite integrado nativamente
- Terrestre-não-terrestre seamless

**Status 6G (2025)**
- 📋 Working groups 3GPP (Release 21+)
- 🔬 Protótipos lab (2025-2026)
- 📡 Spectrum allocation discussions ITU
- 📅 Padrão final esperado 2030-2031
- 🚀 Comercialização estimada 2031-2035

**Organizações 6G Pesquisa**
- 3GPP (standardization body)
- ITU-R (frequency coordination)
- IMTC (IMT-2030 Focus Group)
- 6G Flagship (Finlândia)
- 6G ACIA (Academia-Indústria)

---

## 2. TECNOLOGIAS GSM/3GPP

### **Esquemas Modulação**

| Geração | Modulação | Taxa Código | PAPR | Eficiência |
|---------|-----------|-------------|------|------------|
| **2G** | GMSK | 1/2 | Baixo | 0.5 bits/Hz |
| **3G** | WCDMA (QPSK) | 1/2-1/3 | Alto | 1.0 bits/Hz |
| **4G** | OFDM (QPSK-256QAM) | 1/3-9/10 | Médio | 5+ bits/Hz |
| **5G** | OFDM (QPSK-1024QAM) | 1/4-948/1024 | Médio | 10+ bits/Hz |
| **6G** | OFDM+gOFDM (sub-THz) | Adaptativo | Alto | 20-50 bits/Hz |

### **Bandas de Frequência Móvel**

**GSM/EDGE/3G (Banda Histórica)**
- 850 MHz: Band 5 (E-UTRAN), Band 26 (3G) - Brasil, Américas
- 900 MHz: Band 8 (E-UTRAN) - Europa, Ásia
- 1800 MHz: Band 3 (E-UTRAN) - Brasil, Europa, Ásia
- 1900 MHz: Band 2 (E-UTRAN) - Américas, alguns Ásia

**LTE (4G)**
- 700 MHz: Band 12/13/14 - Américas (penetração, ruído baixo)
- 800 MHz: Band 20 - Europa
- 850 MHz: Band 5 - Brasil, Américas
- 900 MHz: Band 8 - Europa, Ásia
- **1800 MHz: Band 3 - Brasil, Europa, Ásia, ubíquo**
- **2100 MHz: Band 1 - Histórico 3G, mantido LTE Europa/Ásia**
- 2300 MHz: Band 40 (Band 40 TDD China) - China, Índia
- **2600 MHz: Band 7 - Europa, Ásia (alta capacidade)**
- 3.5 GHz: Band 78 (TDD) - China, Brasil (parte espectro 5G)

**5G (FR1, sub-6 GHz)**
- n1 (2100 MHz) - Histórico 3G, mantido 5G alguns operadores
- **n3 (1800 MHz) - Band 3 reutilização**
- **n7 (2600 MHz) - Band 7 reutilização**
- **n41 (2500 MHz) - Band 41 TDD China**
- **n78 (3.5-3.8 GHz) - Espectro 5G principal, Brasil alocação 3.5-3.7 GHz**
- **n79 (4.4-5.0 GHz) - Espectro 5G secundário, subutilizado Brasil**
- n257/n258/n260 (mmWave 28/39 GHz) - Ainda experimental Brasil

**Alocação Brasil 5G (2024-2025)**
- 3.5 GHz: 3500-3700 MHz (200 MHz total)
  - Vivo: 3500-3600 MHz (100 MHz)
  - TIM: 3600-3700 MHz (100 MHz)
  
- 2.3 GHz: 2.3-2.4 GHz (100 MHz)
  - Vivo: 2.3-2.35 GHz
  - TIM/Claro: 2.35-2.4 GHz

- **Futuro 2025-2026:**
  - 3.8-4.0 GHz possível alocação
  - 6 GHz unlicensed (experiência coexistência WiFi)

**5G mmWave**
- n257: 26.5-29.5 GHz (EUA, Japão, Coréia)
- n258: 37-40 GHz (EUA, EU, alguns Ásia)
- n260: 37-43.5 GHz (China, Japão)
- Status Brasil: Alocação 28-29.5 GHz planejada (2026+)

### **Tecnologias RAN (Radio Access Network)**

**MIMO (Multiple Input Multiple Output)**
- 2G/3G: Single antenna (1x1)
- 4G LTE: 2x2 MIMO (banda 3, 7), 4x4 MIMO (banda 7+)
- 5G: 
  - Massive MIMO: 64x64 (typical), 128x128 (large cells)
  - Phased array antennas eletrônicas (beam steering)
  - Beam management (adaptive narrow beams)

**Carrier Aggregation (CA)**
- Agregação múltiplos bandas/componentes
- 4G: Até 8 CC (Carrier Components) = 160 MHz agregado, 1 Gbps pico
- 5G: Suporte nativo múltiplas bandas, sem limite prático

**Beam Management (5G)**
- Beam selection (múltiplos candidatos)
- Beam refinement (precisão sub-wavelength)
- Beam switching (handover entre beams, <10ms)
- Beam correspondence (reciprocidade frequência-espaço)

**Full-Duplex (FDD/TDD)**
- **FDD (Frequency Division Duplex)**: Downlink + uplink simultâneos frequências diferentes
  - Vantagem: Simetria, latência baixa
  - Desvantagem: Espectro bilateral (mais caro)
  - Uso: Público móvel, Américas, Europa

- **TDD (Time Division Duplex)**: Downlink + uplink alternados tempo
  - Vantagem: Monousuário espectro eficiente
  - Desvantagem: Latência síncrona, interferência uplink-downlink
  - Uso: China (3GPP-TDD), privado (5G campus)

---

## 3. ARQUITETURA 5G/6G

### **5G RAN Evolução**

**2020: NSA (Non-Standalone)**
```
┌─────────────────────────────────────┐
│ 5G gNB (radio cell)                 │
│ ├─ 5G NR air interface             │
│ └─ Traffic to LTE eNB (core 4G)    │
├─────────────────────────────────────┤
│ LTE eNB (4G cell)                   │
│ ├─ Anchor connectivity              │
│ └─ Core (EPC 4G)                    │
└─────────────────────────────────────┘
```

**2021+: SA (Standalone)**
```
┌─────────────────────────────────────┐
│ 5G gNB (radio cell)                 │
├─────────────────────────────────────┤
│ 5G Core (5GC)                       │
│ ├─ AMF (Access/Mobility Mgmt)      │
│ ├─ SMF (Session Management)        │
│ ├─ UPF (User Plane Function)       │
│ ├─ NEF (Network Exposure)          │
│ └─ NRF (Network Repository)        │
├─────────────────────────────────────┤
│ Backhaul/Fronthaul                  │
│ ├─ Fibra/mmWave (bHaul)            │
│ └─ Fibra/Wireless (fHaul)          │
└─────────────────────────────────────┘
```

### **Edge Computing (MEC/MES)**

**Benefícios**
- Reduz latência (processamento local, não cloud)
- Reduz consumo LTE/5G (local caching)
- Privacidade melhorada (dados não enviam cloud)

**Arquitetura**
- MEC host: Computador edge datacentro local
- Aplicações: AR/VR rendering, video análise, autonomous vehicle control
- Latência: 1-50ms típico (vs 100-500ms cloud)

**Status (2025)**
- ✅ Operacional: MEC+5G operadores premium
- 🔄 Expansão: Peças de cobertura 5G
- 📅 Padrão: ETSI MEC (European Telecom Standards Institute) finalizado

### **6G Architecture (Visão)**

**Princípios**
- Satélite + terrestre integrado nativamente
- AI native routing e predição
- Quantum-ready (integração QKD)
- Reconfigurable Intelligent Surfaces
- THz + Sub-THz support

**Componentes Esperados**
- 6G Core: CNF (containerized native functions)
- RAN: Programmable radio (software-defined)
- Edge: AI inference <1ms
- Backhaul: THz links, free-space optics (FSO)

---

## 4. OPERADORES BRASIL (2025)

### **Vivo (Telefónica)**
- 4G LTE: Band 3 (1800), Band 5 (850), Band 7 (2600)
- 5G: Band 3, Band 78 (3.5 GHz), pequeno Band 79
- Cobertura: 95%+ cidades, expandindo interior
- 5G tráfego: 15-20% total (2024 estimativa)

### **TIM (Telecom Italia)**
- 4G LTE: Band 3 (1800), Band 7 (2600)
- 5G: Band 78 (3.5 GHz)
- Cobertura: 90%+ cidades, 40%+ interior
- 5G tráfego: 10-15% total (2024 estimativa)

### **Claro (América Móvil)**
- 4G LTE: Band 3 (1800), Band 7 (2600), Band 40 (2.3 TDD)
- 5G: Entrada 2024 (Band 78)
- Cobertura: 90%+ cidades, 30%+ interior
- 5G tráfego: Iniciando (1-5%, 2024)

### **Oi (Telefónica)**
- 4G LTE: Band 3 (1800), Band 7 (2600)
- 5G: Planejado 2025-2026
- Cobertura: 70%+ cidades
- Status: Reestruturação financeira (leilão 2024)

---

## 5. SISTEMAS EM DESENVOLVIMENTO (2024-2026)

### **5G Phase 2 Features**

**Uplink Enhancement**
- Grant-free transmission (menos overhead)
- Simultaneous transmission e reception (full-duplex)
- UL power control refinement

**NTN (Non-Terrestrial Networks)**
- Integração satélite 5G padrão
- Tolerância latência longa (satélite LEO ~50ms)
- Release 17 (2023) especificação, implementação 2024-2026

**3GPP Release 18 (2024-2025)**
- Uplink melhorias especificação
- Satélite IoT direct
- Advanced antenna systems (AAS)
- RIS (Reconfigurable Intelligent Surface) teórico

### **Private 5G / Campus Networks**

**Conceito**
- Operador empresa (não público móvel)
- Frequências autoridades, típico 2.3-2.4 GHz ou sub-6
- Casos: Fábricas (Industry 4.0), hospitais, universidades

**Exemplos Brasil**
- Embraer (Campus 5G privado)
- Petrobras (Testes plataforma offshore)
- Universidades (Protótipos educação)

**Status (2025)**
- 🔄 Primeiros deployments operacionais
- 📅 Regulação Brasil finalizar 2025-2026

### **Redes Slicing (Network Slicing)**

**O que é**
- Divisão lógica rede física em "slices" isolados
- Cada slice otimizado para caso uso
- Exemplo: Slice 1 (IoT baixa latência), Slice 2 (Video HD), Slice 3 (Comunicação crítica)

**Implementação**
- NFV (Network Function Virtualization) + SDN (Software Defined Networking)
- Orchestration automático (ONAP, OpenStack)
- SLA garantido por slice

**Status (2025)**
- ✅ Lab operacional
- 🔄 Primeiras implementações operators premium
- 📅 Comercialização 2026+

---

## 6. OPEN RAN (ORAN)

### **O que é**

Arquitetura RAN com componentes open-source, interoperáveis:
- **O-RAN Alliance**: Padrão aberto (vs. monolítico fornecedor único)
- **Separação arquitetura:**
  - RRU (Remote Radio Unit): Antena (pode ser qualquer fornecedor)
  - CU (Centralized Unit): Processamento alto-nível (split funcional)
  - DU (Distributed Unit): Processamento baixo-nível (próx antena)
  - RIC (RAN Intelligent Controller): IA/ML decisões em tempo-real

### **Arquitetura O-RAN**

```
┌────────────────────┐
│ RIC (RAN Controller)
│ - Non-RT RIC (longo prazo, ML)
│ - Near-RT RIC (<20ms decisões)
└─────────┬──────────┘
          │
    ┌─────┴─────┐
    │           │
┌───┴──────┐ ┌─┴───────┐
│ CU-UP    │ │ CU-CP   │
│(User Pl.)│ │(Control)│
└────┬─────┘ └────┬────┘
     │            │
   ┌─┴────────────┴──┐
   │                 │
   │  ┌──────────────┴─────┐
   │  │                    │
┌──┴─┴──┐ ┌───────────┐ ┌─┴──────┐
│ DU-1   │ │ DU-2      │ │ DU-N   │
│(RRU-1) │ │(RRU-2)    │ │(RRU-N) │
└────────┘ └───────────┘ └────────┘

[Open fronthaul: Padrão W, WS, W+]
```

### **Benefícios**
- Reduz vendor lock-in
- Flexibilidade: customização por caso uso
- Eficiência: compartilhamento recursos
- Inovação: Terceiros desenvolve componentes

### **Desvantagens**
- Complexidade: Integração múltiplos vendors
- Latência: Split funcional vs monolítico
- Madureza: Ainda em evolução (2025-2027)

### **Implementadores (2024-2025)**

**Operadores**
- Telefónica (Espanha, testes)
- Orange (França, testes)
- Deutsche Telekom (Alemanha, testes)
- Vodafone (EU, testes)

**Fabricantes Componentes**
- **RRU/CU-DU:** Nokia, Ericsson, Samsung, Mavenir, Radical
- **RIC:** Mavenir, OpenStack (comunidade)
- **Orchestration:** Red Hat OpenStack, ONAP

**Status Brasil (2025)**
- 🔬 Protótipos universidades
- 📅 Operadores avaliar 2025-2026
- 🎯 Adoção esperada 2027+

---

## 7. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- ✅ 5G SA operacional ubíquo
- ✅ LTE-M/NB-IoT dominando IoT
- 🔄 5G mmWave primeiros testes Brasil
- 🔬 6G protótipos lab aumentando
- ⚠️ Descontinuação GSM/3G começando

**Médio Prazo (2026-2027)**
- ✅ 5G-Advanced Release 17-18
- 🔄 Satélite 5G integração (NTN)
- 🔄 Open RAN primeiros deployments
- 🔬 6G especificações 3GPP iniciando
- ⚠️ Descontinuação GSM/3G acelerada

**Longo Prazo (2028-2030)**
- 🔬 6G protótipos sistema integrando
- ✅ Sub-THz testbeds operacionais
- 🔄 Satélite ubíquo 5G/6G
- 🔄 RIS early commercial implementations
- 📅 6G padrão final esperado 2030-2031

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
