# SISTEMAS DE COMUNICAÇÃO VIA ONDAS DE RÁDIO

## RF (RadioFrequência) - Fundamentos

### Espectro Eletromagnético em Comunicações
- **Faixa**: 3 kHz até 300 GHz
- **Divisão**: 
  - VLF (3-30 kHz): Navegação, submarinos
  - LF (30-300 kHz): Rádio AM longa onda
  - MF (300 kHz-3 MHz): Rádio AM média onda
  - HF (3-30 MHz): Rádio onda curta, amador
  - VHF (30-300 MHz): Rádio FM, TV, aviação
  - UHF (300 MHz-3 GHz): Celular, TV, WiFi, GPS
  - SHF (3-30 GHz): Satélite, microwave, 5G mmWave
  - EHF (30-300 GHz): 5G/6G, pesquisa
  - Terahertz (0.1-10 THz): Pesquisa 6G

## Rádio Comercial

### Rádio AM (Amplitude Modulation)
- **Frequência**: 525-1.705 kHz (MF)
- **Padrão**: NRSC (E.U.), CEP (Brasil)
- **Modulação**: AM
- **Alcance**: 10-100 km
- **Taxa de dados**: Áudio analógico
- **Status**: Operacional mas em declínio
- **Aplicações**: Notícias, música, talk show
- **Transição**: DAB+ digital em alguns países

### Rádio FM (Frequency Modulation)
- **Frequência**: 88-108 MHz (VHF)
- **Padrão**: ITU-R BS.412, ITU-R BS.1114
- **Modulação**: FM com RDS (Serviço de Dados)
- **Alcance**: 10-50 km
- **Qualidade**: Melhor que AM, menor alcance
- **Status**: Operacional, ainda forte em 2025
- **RDS**: Dados embarcados (estação ID, tráfego, música)
- **Transição**: Lento para DAB+ e streaming

### DAB/DAB+ (Digital Audio Broadcasting)
- **Frequência**: 174-240 MHz (VHF-3, Bandas L)
- **Padrão**: ETSI EN 300 401, ITU-R BS.1114
- **Modulação**: OFDM
- **Taxa de áudio**: 64-256 kbps conforme qualidade
- **Alcance**: 50-100 km
- **Status**: Ativo/Crescimento em Europa, adoção limitada
- **Vantagem**: Qualidade digital, mobilidade, múltiplos canais
- **Serviços adicionais**: Textos, imagens, vídeo low-res
- **Cronograma**: Expansão na Ásia (2024-2025)

### DRM/DRM+ (Digital Radio Mondiale)
- **Frequência**: HF (3-30 MHz) e VHF (30-300 MHz)
- **Padrão**: ITU-R BO.1130
- **Modulação**: COFDM (Coded OFDM)
- **Taxa**: 8-72 kbps (conforme modo)
- **Alcance**: Até 2000 km (HF)
- **Status**: Implementação emergente, poucos países
- **Vantagem**: Substituição AM/FM com reutilizar frequências
- **Foco**: Rádio tropical, serviços de onda curta

### Rádio por Internet (Internet Radio / Streaming)
- **Protocolo**: HTTP, RTMP, HLS
- **Taxa**: 32-320 kbps típico
- **Alcance**: Global via internet
- **Status**: Dominante (Spotify, Apple Music, Amazon Music)
- **Aplicação**: Substitui rádio tradicional
- **Padrão**: De facto (não regulado como RF)

## Rádio Amador

### Bandas VHF/UHF Amador
- **Frequência**: 144-146 MHz (2m), 420-450 MHz (70cm)
- **Tipo**: FM simplex, repeater
- **Padrão**: ITU Região (varies)
- **Modulação**: FM ou SSB (Single Sideband)
- **Alcance**: 5-50 km (depende potência e terreno)
- **Aplicação**: Comunicação emergencial, hobby, eventos
- **Status**: Ativo, comunidade vibrante
- **Tecnologia**: Analógica (D-STAR, DMR, Fusion adicionando digital)

### Rádio Amador Digital
- **D-STAR**: DSTAR (Japan), USA, Europa - OFDM
- **DMR**: Digital Mobile Radio, 12.5 kHz channels, TDMA
- **Fusion (Yaesu)**: Analógico+Digital híbrido, banda estreita
- **NXDN**: Japão, 6.25 kHz/12.5 kHz
- **Status**: Crescimento (2015+), comunidade adotando
- **Vantagem**: Dados + voz, melhor alcance mesmo potência

### Bandas HF Amador
- **Frequência**: 1.8-29.7 MHz (múltiplas sub-bandas)
- **Tipo**: SSB, CW, Digital (RTTY, PSK31, JT65)
- **Alcance**: Até mundo inteiro (ionosfera)
- **Status**: Ativo, comunidade de comunicação DX
- **Aplicação**: Contatos internacionais, comunicação emergencial
- **Propagação**: Varia por hora/estação solar

## Comunicação Móvel Alternativa

### PMR/Professional Mobile Radio
- **Frequência**: 446 MHz (ISM, sem licença muitos países)
- **Tipo**: Rádio portátil, simplex
- **Alcance**: 1-5 km típico
- **Padrão**: EN 300 296 (europa), variam regiões
- **Status**: Comercial, popular segurança/eventos
- **Exemplo**: Rádios Motorola, Kenwood GMRS

### GMRS (General Mobile Radio Service) - USA
- **Frequência**: 462-467 MHz (UHF)
- **Tipo**: Simplex, repeater
- **Alcance**: 1-25 km
- **Status**: Comercial, requer licença (USA)
- **Aplicação**: Família, outdoor, negócio pequeno

### CB Radio (Citizen Band)
- **Frequência**: 27 MHz (AM), 26-28 MHz alguns países
- **Tipo**: Simplex
- **Alcance**: 1-30 km (varia)
- **Padrão**: FCC Part 95 (USA), variam internacionais
- **Status**: Declínio (substituído celular)
- **Histórico**: Popular 1970s-1990s

## IoT Wireless (Longo Alcance, Baixa Potência)

### LoRaWAN (Long Range Wide Area Network)
- **Frequência**: 868 MHz (EU), 915 MHz (USA), 920 MHz (JP), 780-900 MHz (China)
- **Tipo**: LPWAN (Low Power Wide Area Network)
- **Taxa de dados**: 0,3-50 kbps
- **Alcance**: 2-15 km (campo aberto)
- **Topologia**: Star (gateway) + mesh
- **Protocolo**: LoRa PHY + LoRaWAN MAC
- **Status**: Operacional, crescimento em smart cities
- **Consumo**: Ultra-baixo (bateria 5+ anos)
- **Aplicações**: Smart metering, sensores ambientais, rastreamento
- **Padrão**: LoRa Alliance
- **Vantagem**: Sem licensça (ISM), alcance longo
- **Latência**: ~5 segundos (não real-time)

### NB-IoT (Narrowband IoT) / LTE-M
- **Frequência**: Bandas LTE existentes (600 MHz - 3.8 GHz)
- **Tipo**: LPWAN cellular
- **Taxa de dados**: 32-250 kbps
- **Alcance**: 1-10 km (urbano), 35+ km (rural)
- **Topologia**: Cellular
- **Protocolo**: 3GPP (Release 13+)
- **Status**: Operacional, implantação operadores
- **Consumo**: Ultra-baixo
- **Aplicações**: Smart metering, rastreamento, sensores urbanos
- **Latência**: <500 ms típico
- **Vantagem**: Infraestrutura operador, autenticação 3GPP
- **Custo operação**: Modelo similar 2G/3G

### Sigfox
- **Frequência**: 868 MHz (EU), 915 MHz (USA), 920 MHz (JP)
- **Tipo**: LPWAN proprietário
- **Taxa de dados**: 100 bps (uplink), 600 bps (downlink)
- **Alcance**: 10-40 km
- **Topologia**: Star
- **Protocolo**: Proprietário (Ultra Narrowband)
- **Status**: Operacional, implantação global reduzida
- **Consumo**: Extremamente baixo
- **Aplicações**: Sensores simples, rastreamento
- **Modelo negócio**: Conectividade global por assinatura
- **Desafio**: Taxa muito baixa, competição LoRaWAN/NB-IoT

### Weightless (LPWAN alternativa)
- **Status**: Descontinuado/Mínimo desenvolvimento
- **Frequência**: TV whitespace, sub-GHz
- **Taxa**: 10-100+ kbps
- **Histórico**: Proposto como alternativa LoRa/Sigfox

## Comunicação Ponto-a-Ponto RF

### Microwave Ponto-a-Ponto
- **Frequência**: 2, 6, 11, 13, 15, 18, 23 GHz (típico)
- **Tipo**: Enlace direto, visada direta (LOS)
- **Taxa**: 10 Mbps - 10 Gbps
- **Alcance**: 1-100 km dependendo frequência
- **Aplicação**: Backhaul, conexão entre torres, backup
- **Padrão**: IEEE 802.11ad, proprietário
- **Status**: Operacional, padrão em operadores telecom
- **Vantagem**: Velocidade alta, sem cabeamento
- **Desafio**: LOS requerido, atenuação chuva em altas frequências

### Enlace Satélite Ponto-a-Ponto
- **Vide seção Satélites** para detalhes

## Comunicação Emergencial

### VHF/UHF Busca e Resgate
- **Frequência**: 156 MHz (Marine VHF), 146 MHz (Amador)
- **Tipo**: FM simplex + repeater
- **Alcance**: 10-50 km
- **Status**: Padrão internacional
- **Protocolo**: Simples FM

### HF Emergência Internacional
- **Frequência**: 3.5, 7, 14, 21, 28 MHz (bandas amador)
- **Tipo**: SSB/CW
- **Alcance**: Global (ionosfera)
- **Status**: Essencial backup comunicações
- **Protocolo**: Não padronizado, técnicas manuais

### DME (Distance Measuring Equipment) - Aviação
- **Frequência**: 960-1.215 MHz (UHF)
- **Tipo**: Navegação/distância para aeronaves
- **Alcance**: Até 200 nm
- **Status**: Padrão aviação
- **Protocolo**: Pulsos encoded

## Tendências RF (2025-2030)

1. **Sunsetting GSM/UMTS**: Descontinuação rádio analógica antiga
2. **5G-Advanced + NR+**: Expansão 5G non-standalone (NSA) → Standalone (SA)
3. **Integração satélite RF**: 3GPP NTN (Non-Terrestrial Networks)
4. **6G RF**: Terahertz para comunicações (pesquisa)
5. **LoRaWAN 2.0**: Melhorias segurança, latência
6. **Digital AM/FM**: Transição DAB+ em mais países
7. **AI em RF**: Otimização espectro, detecção interferência
8. **Spectrum sharing**: Compartilhamento dinâmico bandas
