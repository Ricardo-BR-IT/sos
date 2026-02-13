# 01 - SISTEMAS DE COMUNICAÇÃO POR SATÉLITE

## ÍNDICE
1. Constelações Operacionais
2. Tecnologias Satélite
3. Frequências e Protocolos
4. Aplicações
5. Sistemas em Desenvolvimento
6. Pesquisa Avançada
7. Tendências 2025-2030

---

## 1. CONSTELAÇÕES OPERACIONAIS

### **Órbita Geoestacionária (GEO) - 36.000 km**

#### Comunicação Comercial
- **Intelsat**: 60+ satélites (C, Ku, Ka band) - TV, internet, telefonia
- **SES (SES-1 a SES-22)**: 50+ satélites - broadcasting, telefonia
- **Eutelsat**: 40+ satélites (Ku, Ka band) - TV, dados
- **Hispasat**: 8+ satélites - cobertura Ibérica/Latina
- **Brasilsat**: Satélites defasados (Brasilsat A4/B4 aposentando)
- **Arsat**: Satélites argentinos (Arsat 1/2/3) comunicação regional
- **Embratel Star One**: Satélite hibrido GEO/MEO brasileiro
- **Viasat**: SpacewayX, World View - internet banda larga
- **Amazon Kuiper**: Começando testes (GEO testing)

#### Observação da Terra
- **NOAA**: Satélites meteorológicos GOES-16/17/18 (CONUS/Alaska/Hawaii)
- **Meteosat**: Serie MSG-4 (Eumetsat) - Europa
- **Himawari**: Série MTSAT Japão
- **Fengyun**: Série China

#### Militar/Governo
- **DMSP**: Defense Meteorological Satellite Program (US)
- **DSCS**: Defense Satellite Communications System
- **Milstar/Skynet**: Comunicação militar
- **Venesat**: Telesat bolivariano Venezuela (não operacional)

### **Órbita Média (MEO) - 5.000-20.000 km**

#### Sistema GPS/GNSS
- **GPS**: 24+ satélites (6 planos orbitais, 4-11 satélites/plano)
  - Primeira geração: Block I-IIA (1978-2005)
  - Segunda geração: Block IIR/IIF (1997-2009)
  - Terceira geração: Block IIIA (2023-2030 rollout)
  
- **GLONASS**: 24 satélites (Rússia) - frequência CDMA
- **Galileo**: 30 satélites (UE) - 27 + 3 reserva - completado Dezembro 2023
- **BeiDou**: 45+ satélites (China) - constelação completa 2020
- **NAVIC**: 7-8 satélites (Índia) - cobertura Sul Ásia
- **QZSS**: 4+ satélites quase-zênite (Japão) - cobertura local

#### Comunicação (MEO)
- **Iridium**: 66 satélites (banda L 1.6 GHz)
  - Iridium Next (2017-2019): 81 novos satélites com AIS, payload FlexPayload
  - Plano: 120+ satélites (2025+)
  
- **Globalstar**: 40 satélites (banda L, compatível Iridium em emergência)
- **ICO Global**: Cancelado (frequência 2 GHz MEO)

### **Órbita Baixa (LEO) - 160-2.000 km**

#### Internet via Satélite (Mega-constelações)

**Starlink** (SpaceX)
- Operacional: 5.000+ satélites (Ku, Ka band)
- Plano: 42.000 satélites (5 camadas diferentes frequências/órbitas)
- Tecnologia: Phased array antennas, laser cross-links inter-satélite
- Serviço: Starlink Direct-to-Cell (iPhone 14+, SMS via satélite)
- Velocidade: 50-150 Mbps, latência 20-50ms (excelente para LEO)
- Cobertura: Brasil, Argentina, Uruguai operacionais

**OneWeb** (Bharti Airtel/Eutelsat)
- Operacional: 650+ satélites (Ku band)
- Plano: 648 satélites completado (maioria lançados)
- Serviço: Backhauling, IoT L-band (partnered Iridium)

**Telesat Lightspeed** (Canadá)
- Planejado: 300 satélites (Ka band) - primeira geração
- Investidores: Telesat, Canso
- Status: Desenvolvimento (lançamento 2025+)

**Amazon Project Kuiper**
- Planejado: 3.236 satélites (Ka/Ku band, 590-630 km altitude)
- Status: Testes iniciais 2024, lançamentos 2025-2029
- Parceria: Amazon Logistics + Blue Origin New Glenn

**Outras constelações menores:**
- **Kinéis** (França): 25 satélites IoT UHF LPWAN
- **Swarm Technologies** (SpaceX subsidiary): 150+ satélites IoT
- **Lacuna Space** (UK): IoT LPWAN
- **ExoAnalytics**: Observação terrestre (não comunicação)

#### Observação da Terra (LEO)
- **Landsat 8/9**: USGS - resolução 30m, 16 dias revisit
- **Sentinel-1/2**: Copernicus ESA - SAR + óptica, 5 dias revisit
- **Planet Labs**: 150+ satélites doves (5m resolução, diário)
- **Maxar GeoEye-1/WorldView**: Resolução 0.3m comercial
- **Huanjing**: China observação ambiental
- **CBERS**: Brasil-China observação recursos terrestre

#### Comunicação Militar/Governo (LEO)
- **Milstar-2**: Militar US
- **Wideband Global SATCOM (WGS)**: Banda Ka militar US
- **SKYNET**: Britânico
- **SICRAL**: Italiano

### **Órbita Altíssima/Tundish**
- **Vega**: Satélites exploração mineral (propriedade privada)
- **Janus**: Satélites observação exoplanetária

---

## 2. TECNOLOGIAS SATÉLITE

### **Bandas de Frequência**

| Banda | Frequência | Uso Primário | Característica |
|-------|-----------|--------------|-----------------|
| **L-Band** | 1.5-2.7 GHz | Iridium, Globalstar, INMARSAT | Móvel handheld, IoT |
| **S-Band** | 2-4 GHz | Milstar, INMARSAT-C | Militar, dados |
| **C-Band** | 4-8 GHz | Telecomunicação clássica | Chuva tolerable |
| **Ku-Band** | 12-18 GHz | TV satelital, internet | Internet DSL-like |
| **Ka-Band** | 26-40 GHz | Internet banda larga, militar | Muito rápido, chuva sensível |
| **V-Band** | 40-75 GHz | Pesquisa, futuro | Muito chuva sensível |
| **W-Band** | 75-110 GHz | Pesquisa (6G futuro) | Muito chuva sensível |
| **Mm-Wave** | >100 GHz | 6G pesquisa | Experimental |

### **Protocolos de Comunicação**

**Legacy (Descontinuação)**
- **INMARSAT-A**: Analógico (descontinuado 2007)
- **INMARSAT-B**: Voz/dados 64 kbps (descontinuado 2008)
- **Iridium Generation 0**: Original 1998-2007 (substituído Iridium Next)

**Operacional**
- **INMARSAT-C/F (Mini-M)**: 2.4 kbps-64 kbps, email, SMS
- **INMARSAT IsatHub**: Internet variável até 432 kbps
- **Iridium**: 2.4 kbps, SMS, voz de qualidade
- **Iridium Next**: Até 88.2 kbps, FlexPayload customizado
- **Globalstar**: 9.6 kbps, SMS, voz
- **OneWeb**: 100+ Mbps (backhaul)
- **Starlink**: 50-150 Mbps via terminal portátil

**Emergente**
- **NTN (Non-Terrestrial Networks)**: Integração satélite 5G (3GPP Release 17)
  - Protocolo: Baseband similar 5G NR
  - Latência: 20-50ms (tolerância longa)
  - Uplink: 15-30 dB loss maior que terrestre

- **3GPP Release 18**: Satélite direto-a-celular
  - Iridium + smartphone integração (via partnerip)
  - Starlink Direct-to-Cell (iPhone 14+ nativo)

### **Antenas e Tecnologias Payload**

**Antenas Tradicionais**
- **Reflectores parabólicos**: 1-5m, GEO (posição fixa)
- **Phased Arrays**: 1-2m, GEO móvel, LEO rastreamento
- **Flat-panel antennas**: Evolução phased array, <1cm espessura

**Novo (Starlink/OneWeb style)**
- **Phased Array Digital**: 0.5-1m, millimeter-precise steering
- **Electronically Steerable Phased Arrays (ESPA)**: Sem partes móveis
- **Reconfigurable Intelligent Surfaces (RIS)**: Pesquisa (6G)

**Tecnologia Payload**
- **Regenerativo**: Processamento a bordo (decodifica/recodifica)
- **Transparente**: Simples repetidor (legacy)
- **Bent-pipe**: Switch on-board (moderno)
- **Flexible Payload**: Reconfigurable em-órbita (Iridium Next, futuro)

### **Propulsão e Deorbiting**

**Propulsão Satélite**
- **Químico**: Hydrazina (tradicional)
- **Elétrico**: Ion drives, hall effect (Starlink, OneWeb)
- **Velas solares**: Pesquisa (ainda não satélites com carga)
- **In-situ resource utilization**: Teórico (combustível coleta órbita)

**Deorbiting (Responsabilidade ambiental)**
- **Propulsão própria**: Novos satélites levam combustível final fase
- **Vela solar passiva**: Starlink design (deorbita em 5 anos)
- **Debris removal**: Operacionais 2024+ (Astroscale, ClearSpace)

---

## 3. APLICAÇÕES OPERACIONAIS

### **Telecomunicações (Voz/Dados)**
- Telefones satélite portátil (Iridium 9555, GlobalStar SP-V200)
- Backup telecom áreas remotas (garimpos, navios, exploração)
- Conectividade rural banda larga (Starlink rural areas)
- Redes privadas (VSAT corporativa)

### **Broadcasting**
- TV via satélite (> 500 milhões casas Brasil+LatAm)
- Rádio via satélite (Sirius XM North America)
- Jornalismo remoto (uplink trucks)

### **Observação da Terra**
- Meteorologia: previsão, alerta clima
- Agricultura: NDVI, produtividade, irrigação
- Geologia: mapeamento, mineração, deformação
- Ambiental: desmatamento, queimadas, glaciares
- Urbano: expansão, infraestrutura, desastre

### **GPS/Posicionamento**
- Navegação (aviação, marítima, automóvel)
- Sincronização temporal (redes, bolsa de valores)
- IoT tracking geolocalização
- Pesquisa científica (tectônica, glacial, atmosférica)

### **IoT Satelital**
- Monitoramento gado (colares GPS Starlink)
- Sensores ambientais remotos (chuva, temperatura, umidade)
- Buoys oceanográficas (temperatura, correntes)
- Botões SOS/emergência (Globalstar PLB)

### **Marítimo**
- Posicionamento navios (GPS, DGPS)
- Comunicação navios (Iridium, INMARSAT)
- Monitoramento navegação automática
- Segurança (EPIRB satélite)

### **Aviação**
- Tracking global (ADS-B via satélite - Aireon/Iridium)
- Comunicação avião-terra (SATCOM)
- Navegação (GPS, WAAS)

### **Militar/Governo**
- Reconhecimento por imagem (NRO satélites classificados)
- Comunicação segura (MILSTAR, SKYNET)
- Vigilância (IMINT, SIGINT)
- Comando e controle

---

## 4. SISTEMAS EM DESENVOLVIMENTO (2024-2025)

### **Satélite Direto-a-Celular (D2D)**

**Iridium + Celulares**
- Parceria: Iridium, Garmin, US carriers
- Tecnologia: SMS via Iridium network
- Implementação: App móvel + hardware suporte
- Lançamento: 2024-2025
- Custo: Subscriptions $2-5/mês (estimado)

**Starlink Direct-to-Cell**
- Tecnologia: Integração nativa iPhone 14/15
- Frequência: Banda L modificada (900-950 MHz)
- Capacidade: SMS em áreas sem cobertura
- Plano: Suporte full voice/data 2025-2026
- Protocolo: NTN (3GPP Release 17)
- Custo: Avaliação por carrier (AT&T, T-Mobile partnerships)

**OneWeb + Iridium Partnership**
- Fusão tecnologia Iridium L-band + OneWeb Ku-band
- Objetivo: Redundância banda larga + IoT
- Status: Anúncio 2023, implementação 2025+

### **Constelações em Expansão Planejada**

**Starlink Roadmap**
- 2025-2026: Reestabelecimento 5.000→8.000 operacional
- 2027-2029: Expansão 20.000+ satélites
- 2030+: Full 42.000 constellation (fases 5 camadas)
- Novo: Starlink Gen2/Gen3 satélites (maior payload, vida útil 7 anos)

**Amazon Kuiper Roadmap**
- 2025: Primeiros lançamentos (New Glenn, Falcon 9)
- 2026-2027: Atingir cobertura 95% América/Europa
- 2028-2029: Cobertura global + deployment completo 3.236 satélites
- Tecnologia: Ka/Ku band, phased array, laser cross-links
- Parceria: AWS cloud integration

**Telesat Lightspeed**
- 2025: Testes primeiros satélites
- 2026-2027: Deployment primeira geração 300 satélites
- Frequência: Ka band (semelhante Amazon)
- Diferencial: Foco Canadá/América Norte + latência otimizada

**China Desenvolvimento**
- **Guowang Project**: 13.000 satélites planejados (rivalizando Starlink)
  - 2024-2025: Testes fase inicial
  - 2026-2030: Deployment gradual
  - Status: Autoridade regulação MIIT 2023
  
- **GW-A/GW-B**: Diferentes constelações (frequências 37-43 GHz)

### **Tecnologias Payload Novo**

**Regenerative Payload Avançado**
- On-board processing com IA (predição tráfego)
- Roteamento dinâmico inter-satélite
- Adaptação automática modulação (chuva, interferência)

**Laser Cross-links (Inter-satellite)**
- Starlink: 200+ Gbps transmissão laser satélite-satélite
- OneWeb: Iniciar integração 2025+
- Amazon Kuiper: Plano integração nativo design

**Reconfigurable Intelligent Surfaces (RIS)**
- Pesquisa: MIT, Stanford, Telecom Paris
- Aplicação: Amplificação passiva sem consumo energia
- Implementação satélite: 2027-2030 (esperado)

---

## 5. PESQUISA AVANÇADA (2025-2030)

### **6G Satélite Integration**

**Visão 3GPP Release 18-20 (2025-2028)**
- Satélite primitivo banda terrestre 6G (sub-THz)
- Integração nativa arquitetura 6G (não apenas 5G compatível)
- Reconfigurable intelligent surfaces (RIS) on-board
- IA nativa roteamento/predição

**Frequências 6G Satélite**
- Sub-THz: 100-300 GHz (pesquisa labs 2025-2026)
- THz: 0.3-3 THz (protótipos 2026-2028)
- Propagação: Muito reduzida atmosfera, requer precisão de apontamento

### **Satélite Quantum Communication**

**Quantum Key Distribution (QKD) Satelital**
- Projeto: Micius (China), Quantum Xchange (US), SES (EU)
- Tecnologia: Single photon transmissão free-space
- Alcance: 1.200+ km demonstrado China
- Implementação: 2026-2028 primeiras redes nacionais
- Aplicação: Governo/banco dados críticos

**Quantum Repeaters Satélite**
- Pesquisa: Estender QKD para transcontinental
- Status: Protótipos labs 2025-2027
- Implementação: 2030+ (esperado)

### **HAPS (High Altitude Platform Systems)**

**O que é**
- Plataformas aerostáticas (balões/dirigíveis) ou aerodinâmicas (drones solares) 18-22 km
- Funcionalidade: Satélite mas permanência local (quase-estacionário)
- Vantagem: Latência ultra-baixa (<10ms), cobertura regional barata

**Operacionais**
- **Loon (Google/Alphabet)**: Programa descontinuado 2021 (retomado 2023 como Loon)
- **StratAero (Facebook/Meta)**: Drones solares Aquila - testes 2024+
- **Airbus:** Zephyr solar UAV - testes comercial 2024

**Planejados**
- **Jaunt Air Mobility**: HAPS Região América Latina (2025+)
- **Telesat LEO+HAPS hybrid**: Integração para cobertura redundante

**Frequência HAPS**
- 28 GHz (downlink), 31 GHz (uplink) - ITU alocação
- Integração 5G/6G planejada (compartilhamento espectro)

### **Satélite Nano/CubeSat Comunicação**

**Comunicação LEO Nano**
- Tamanho: 10x10x10 cm, 1-5 kg
- Frequência: UHF (437-438 MHz amador), S-band propriedade
- Taxa: 1-100 kbps típico
- Aplicação: IoT leve, educação, startups

**Operacionais**
- **Swarm by SpaceX**: 150+ CubeSat IoT (2020-2022), integrado Starlink
- **Alba Orbital**: Smallsats 20 kg UK
- **Kinéis**: 25 CubeSat UHF IoT França

**Emergente**
- **Micro-satellites**: 50-100 kg especializado (melhor do que CubeSat)
- **Picosatellites**: <1 kg (ainda experimental)

### **Satélite em Órbita Elíptica Altamente Excêntrica (HEO)**

**Molniya Orbits** (Semi-síncrono, 12h período)
- Histórico: URSS telecom Ártico (altitude apogee 39.000 km)
- Vantagem: Cobre altas latitudes (60-90°)
- Desvantagem: Órbita instável, propulsão frequente necessária

**Tundra Orbits** (Síncrono, 24h período, apogee 48.000 km)
- Pesquisa: Cobertura extrema ártica/antártica
- Status: Proposto (não operacional ainda)

---

## 6. SUSTENTABILIDADE/DEORBITING

### **Problema: Space Debris**
- 34.000+ objetos catalogados >10cm
- 1.000.000+ objetos 1-10cm (não rastreáveis)
- Colisão risco exponencial (Kessler syndrome)
- Starlink design: Deorbita em 5 anos (vela solar passiva)

### **Soluções Ativas**
- **Astroscale ELSA**: Robô remoção debris (testes 2024+)
- **ClearSpace Nyx-1**: Captura satélite desativo (2026+)
- **Altius Space Machines**: Sistema de tração magnetostática

### **Deorbiting Standards**
- **ISO 24113**: Mitigação space debris
- **Novo mandato**: Satélites novos devem deorbitar <25 anos
- **Starlink compliance**: Todos satélites Gen1/Gen2 complacentes

---

## 7. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- D2D satélite (Starlink, Iridium) comercialização
- WiFi 7 + satélite fallback em roteadores
- Open RAN integração satélite (testes)
- Constelações LEO alcançando >50% cobertura global

**Médio Prazo (2026-2027)**
- Amazon Kuiper comercialização (compete Starlink)
- HAPS operacional (Alphabet, Meta testes)
- 6G satelite working groups finalizando especificações
- QKD satélite primeiras implementações governo

**Longo Prazo (2028-2030)**
- 6G satélite integrado padrão
- Deorbiting automático todos novos satélites
- Constelações ultra-densas (100.000+ satélites especulado)
- Transmissão THz satélite laboratório → campo

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
