# 06 - ONDAS DE RÁDIO TRADICIONAL E LPWAN

## ÍNDICE
1. Rádio AM/FM/DAB
2. Rádio Amador (Amateur Radio)
3. Comunicação HF/NVIS
4. LoRaWAN (Long Range Wide Area Network)
5. Sigfox e Comparativos LPWAN
6. Sistemas em Desenvolvimento
7. Tendências 2025-2030

---

## 1. RÁDIO AM/FM/DAB

### **AM (Amplitude Modulation)**

**Especificação**
- Frequência: 535-1.705 kHz (LW), 1.705-30 MHz (MW)
- Modulação: AM (amplitude envelope)
- Largura banda: 10 kHz (AM monofônico)
- Alcance: 1.000+ km ionosférico salto noturno
- Uso: Radiodifusão comercial, amateur

**Rádio AM Brasil**
- Faixa: 530-1.710 kHz (Brasil compliance)
- Operadores: Jovem Pan, CBN, Bandeirantes, centenas estações
- Status: ✅ Operacional ubíquo
- Transição: Gradualmente FM (qualidade superior)

**Descontinuação Planejada (2025-2030)**
- Alguns países (Dinamarca, Suíça): Desligamento 2023-2030
- Brasil: Indefinido (ainda audiência significativa)
- Desvantagem AM: Qualidade áudio, consumo antena grande

### **FM (Frequency Modulation)**

**Especificação**
- Frequência: 88-108 MHz
- Modulação: FM (frequency deviation)
- Largura banda: 200 kHz (estéreo), 150 kHz (mono)
- Alcance: 80-100 km típico (vs AM 1.000+ km)
- Vantagem: Imunidade ruído, qualidade

**Rádio FM Brasil**
- Cobertura: Ubíqua cidades, expandindo interior
- Operadores: Globo, SBT, CNT, centenas independentes
- Status: ✅ Padrão radiodifusão operacional
- Demanda: Crescimento streaming reduzindo audiência

### **DAB+ (Digital Audio Broadcasting)**

**Especificação**
- Frequência: 174-240 MHz (Banda III), 1.452-1.492 GHz (L-band)
- Modulação: OFDM (64-1536 subcarriers)
- Taxa: 9-192 kbps por programa (adaptativo)
- Largura banda: 1.75-9 MHz canal
- Vantagem: Multiplexação múltiplos programas, qualidade digital

**DAB+ Globalmente**
- Países adopção forte: Reino Unido, Alemanha, França, Escandinávia
- Taxa dados: 64 kbps = qualidade FM, 128 kbps = qualidade CD
- Cobertura: Crescimento mas desigual

**DAB+ Brasil (2025)**
- Status: ✅ Autorizado (Agência Nacional Telecom 2016)
- Implementação: Limitada (apenas São Paulo, Rio testes)
- Adoção: Lenta vs FM existente
- Perspectiva: Complementar FM próximos 10+ anos

**Custo Implementação DAB+**
- Infraestrutura: Multiplex + transmissores (alto CAPEX)
- Receptores: Smartphones com DAB+ chipset (raro Brasil)
- Viabilidade: Operadores esperam adoção antes investir

---

## 2. RÁDIO AMADOR (AMATEUR RADIO)

### **Banda Alocação**

**VHF/UHF Aéreo**
- **2m** (144-148 MHz): Local, repeaters, satélite
- **70cm** (420-450 MHz): Longo alcance, EME (Earth-Moon-Earth)
- **23cm** (1240-1300 MHz): Imagem, dados

**HF (Curtas)**
- **80m** (3.5-4.0 MHz): Regional noturno
- **40m** (7.0-7.3 MHz): Continental
- **20m** (14.0-14.35 MHz): Intercontinental dia
- **15m** (21.0-21.45 MHz): Intercontinental
- **10m** (28.0-29.7 MHz): Skip curto, promoría

### **Operação Rádio Amador Brasil**

**Regulação**
- Órgão: ANATEL (Agência Nacional Telecomunicações)
- Licença: Exigida (classe A, N, E)
- Frequências: Tabela ANATEL compliance 3GPP
- Potência: Limitada por banda (típico 1.200W PEP HF)

**Casos Uso**
- Comunicação emergencial (desastres naturais)
- Educação técnica
- Hobbyismo competitivo (contestes)
- Experimentação RF/SDR

**Comunidade Brasil**
- Liga Brasileira Rádio Amadores (LBRA): Associação principal
- Operadores: ~40.000 ativos
- Crescimento: Novo interesse jovens (SDR, entusiasta RF)

### **Satélites Amador**

**Conceito**
- Satélites LEO baixa altitude (200-2.000 km)
- Modo: Uplink UHF/VHF + downlink diferente frequência
- Exemplo: SO-50 (ISS piggyback), AO-91 (cubesat)
- Uso: Comunicação intercontinental amador

**Operação**
- Predição: Orbitron software (passagem satélite real-time)
- Duplex: Uplink 144 MHz, downlink 432 MHz típico
- Janela comunicação: 10-15 minutos passagem

---

## 3. COMUNICAÇÃO HF/NVIS

### **HF (High Frequency) 3-30 MHz**

**Propagação**
- Ionosférica: Reflexão camadas ionosfera
- Skip distance: 0-1.000+ km (depende hora/frequência/atividade solar)
- Penetração: Não atravessa estrutura densas bem

**Aplicações**
- Comunicação emergencial (não depende infraestrutura)
- Radiodifusão internacional (VOA, BBC, China Radio)
- Amador transcontinental
- Militar/marítimo SSB (Single Sideband)

**Vantagem**
- Infraestrutura mínima (antena simples, sem repetidor)
- Confiabilidade emergência (ausência rede)
- Alcance intercontinental

**Desvantagem**
- Qualidade variável (fade, flutter)
- Congestionamento banda
- Antenas grandes (comprimento onda ~10m 3 MHz)

### **NVIS (Near Vertical Incidence Skywave)**

**Conceito**
- Radiação vertical (vs oblíqua HF clássico)
- Reflexão ionosférica próximo (50-300 km)
- Penetração: Estruturas melhor que skip-zone

**Aplicações**
- Comunicação regionais seguras (não skip distante)
- Militar comunicação (não detectável distante)
- Emergencial redes comunitárias

**Frequências NVIS**
- 5-8 MHz (range 50-150 km típico)
- 3.5 MHz (range 100+ km)
- Melhor noturno (ionosfera mais ionizada)

---

## 4. LORAWAN (LONG RANGE WIDE AREA NETWORK)

### **Especificação**

- Frequência: ISM 868/915 MHz (depende país), 470-510 MHz China
- Modulação: LoRa (Chirp Spread Spectrum)
- Taxa: 50 kbps máximo
- Alcance: 15 km línea de vista (vs 1 km classe WiFi)
- Latência: Segundos (não crítico)
- Topologia: Star (gateway central, múltiplos nós)
- Consumo: 10+ anos bateria típico AA

### **Arquitetura LoRaWAN**

```
Sensor 1 --- \
Sensor 2 ----- Gateway ----- LoRaWAN Server --- Aplicação Cloud
...         /
```

**Gateway**
- Receptor múltiplos nós simultâneos
- Transmissor unicast downlink (ACK, commands)
- Conectividade: Ethernet/WiFi/Cellular ao servidor

**Servidor**
- Deduplicação mensagens (múltiplos gateways possível)
- Autenticação nó + Gateway (chave compartilhada)
- Roteamento aplicação backend

### **Operadores Brasil (2025)**

**Público**
- **Lora Alliance (agora LoRa Alliance)**: Padrão aberto
- **TTN (The Things Network)**: Comunitário gratuito (cobertura limitada Brasil)

**Privado**
- **Operadoras telecom**: Vivo, TIM testando LoRaWAN
- **Empresas**: EDP, Copel (smart metering pilotos)

**Cobertura Atual**
- Cidades principais: Disponível (especialmente São Paulo, Rio)
- Interior: Fragmentada (empresas específicas apenas)
- Rural: Raro

### **Casos Uso LoRaWAN**

**Smart City**
- Lixeiras cheias detecção
- Estacionamento espaço ocupação
- Iluminação pública monitoramento

**Agricultura**
- Umidade solo sensores
- Temperatura plantas
- Previsão irrigação ótima

**Logística**
- Rastreamento container
- Temperatura carga (cold chain)
- Localização GPS-free (trilateration)

**Ambiente**
- Qualidade ar (PM2.5, ozônio)
- Nível rio/enchente
- Terramoto sensores

### **Desafios LoRaWAN**
- Downlink limitado (vs uplink)
- Latência não determinístico
- Congestionamento banda (tráfego crescente)
- Segurança: Chave não raro compartilhado (vs TLS internet)

---

## 5. SIGFOX E OUTROS LPWAN

### **Sigfox**

**Especificação**
- Frequência: 902 MHz Brasil, 868 MHz EU
- Modulação: BPSK
- Taxa: Ultra-baixo 12 bytes/mensagem (não Kbps)
- Alcance: 40-50 km rural
- Topologia: Star (todos devices→Sigfox rede)
- Custo: Subscriptions baixo (vs operador LTE-M)

**Desvantagens**
- Taxa ultra-baixa (apenas telemetria simples)
- Topologia dependente Sigfox rede (não aberto)
- Cobertura irregular Brasil

**Status Brasil (2025)**
- 🔄 Operacional limitado (algumas cidades)
- ⚠️ Competição: NB-IoT + LoRaWAN
- 📍 Nicho: Telemetria barata fixa locais

### **NB-IoT (Narrowband IoT)**

**Cobertura Brasil (2025)**
- ✅ Operacional: Vivo, TIM, Claro testes/pilotos
- 📈 Crescimento rápido (operadores investindo)
- ✅ Advantage: Usa espectro LTE existente (3GPP padronizado)
- 💰 Custo operador subscriptions (vs LoRaWAN free)

---

## 6. SÍNTESE LPWAN

| Tecnologia | Frequência | Taxa | Alcance | Poder | Caso Uso |
|-----------|-----------|------|---------|-------|----------|
| **LoRaWAN** | 868/915 MHz | 50 kbps | 15 km | Ultra-baixo | Sensor, rastreamento |
| **Sigfox** | 868/902 MHz | 12 bps | 40-50 km | Baixo | Telemetria, alarme |
| **NB-IoT** | LTE 700-2600 MHz | 250 kbps | 35 km | Baixo | Medição, conectividade |
| **LTE-M** | LTE 700-2600 MHz | 1 Mbps | 25 km | Médio | Vídeo baixo, fone |
| **Wi-Fi** | 2.4/5 GHz | 50-900 Mbps | 100m | Alto | Casa, trabalho |
| **Bluetooth** | 2.4 GHz | 2 Mbps | 240m | Médio | Wearables, periféricos |

---

## 7. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- ✅ FM descontinuação algumas países acelerando
- ✅ DAB+ crescimento EU (Brasil ainda lento)
- 🔄 NB-IoT expansão Brasil começa
- 🔄 LoRaWAN cobertura urbana crescendo

**Médio Prazo (2026-2027)**
- ✅ AM descontinuação mais países
- 🔄 NB-IoT substitui Sigfox alguns segmentos
- 🔄 HF amador comunidade crescimento novo interesse
- 📈 Satélite IoT + LoRaWAN integração (híbrido)

**Longo Prazo (2028-2030)**
- ⚠️ Rádio tradicional (AM/FM) legado
- 🎯 Broadcast digital (DAB+) padrão novo países
- 🔄 NB-IoT ubíquo mobilidade
- 📡 Satélite LPWAN eclipsando LoRaWAN rural

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
