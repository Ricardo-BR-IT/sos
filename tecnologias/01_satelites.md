# SISTEMAS DE COMUNICAÇÃO VIA SATÉLITE

## Sistemas Operacionais

### Satélites Geoestacionários (GEO)
- **Altitude**: ~36.000 km
- **Órbita**: Sincronizada com a rotação terrestre
- **Latência**: ~250-300 ms
- **Cobertura**: Ampla, ~1/3 da Terra por satélite
- **Aplicações**: Transmissão de TV, comunicações telefônicas internacionais, Internet banda larga fixa
- **Exemplos**: Intelsat, Eutelsat, SES
- **Protocolo principal**: DVB-S2, DVB-S2X
- **Bandwidth**: Até 50+ Gbps por satélite moderno

### Satélites de Órbita Média (MEO)
- **Altitude**: 5.000-15.000 km
- **Latência**: ~50-150 ms
- **Cobertura**: Intermédiária
- **Período orbital**: 6-12 horas
- **Aplicações**: Navegação GPS, comunicações móveis complementares
- **Exemplos**: GPS, GLONASS, Galileo
- **Protocolo**: Sinais de navegação próprios

### Satélites de Órbita Baixa (LEO)
- **Altitude**: 500-2.000 km
- **Latência**: ~20-50 ms
- **Velocidade**: Múltiplas órbitas ao redor da Terra
- **Período**: 90-120 minutos
- **Aplicações**: Internet banda larga global, comunicações móveis, observação terrestre
- **Exemplos comerciais**: 
  - Starlink (SpaceX) - 50.000+ satélites planejados
  - OneWeb - 650+ satélites
  - Kuiper (Amazon) - em desenvolvimento
  - Telesat - em desenvolvimento
- **Protocolos**: 3GPP Release 17 (NTN - Non-Terrestrial Networks)
- **Banda frequência**: n255 (1.626-1.660 MHz uplink, 1.525-1.559 MHz downlink), n256 (1.980-2.010 MHz uplink, 2.170-2.200 MHz downlink)
- **Vantagens**: Baixa latência, cobertura global, rápido acesso
- **Desafios**: Handover entre satélites, capacidade limitada, congestionamento

## Tecnologias em Desenvolvimento

### Direct-to-Device (D2D) via Satélite
- **Status**: Implementação avançada (2024-2025)
- **Descrição**: Comunicação direta entre satélites e smartphones sem infraestrutura terrestre
- **Operadores**: Apple (iPhone 14+), Starlink
- **Padrão**: 3GPP Release 17 NTN (Non-Terrestrial Networks)
- **Benefícios**: Conectividade em áreas remotas, SOS direto do dispositivo
- **Frequências**: Compatíveis com bands n255/n256
- **Compatibilidade**: Funciona em dispositivos 3GPP compatíveis

### Satélites Pequenos (CubeSats)
- **Tamanho**: 10x10x10 cm até 20x20x30 cm
- **Massa**: 1-50 kg
- **Custo reduzido**: 1% do custo de satélites tradicionais
- **Aplicações**: IoT, pesquisa, monitoramento ambiental
- **Exemplos**: Projeto QB50, Spire Global
- **Protocolos**: LoRaWAN, NB-IoT, custom

### Plataformas de Alta Altitude (HAPS)
- **Altitude**: 18-50 km
- **Tipo**: Balões atmosféricos ou aeronaves não tripuladas permanentes
- **Latência**: ~10-30 ms
- **Cobertura**: ~50-100 km de raio
- **Status**: Pesquisa e testes piloto (2024-2025)
- **Aplicações**: Cobertura em zonas de desastre, evento temporário, complementação
- **Exemplos**: Loon (Google), Airbus High Altitude Platform, Facebook/Meta Aquila
- **Vantagens**: Mais baixo que LEO, rápida implantação, reposicionável
- **Desafios**: Regulamentação, resistência climática

### 6G via Satélite
- **Status**: Conceitual/pesquisa (2025+)
- **Características**: Integração LEO com 6G terrestre
- **Frequências**: Terahertz (0.1-10 THz)
- **Capacidade**: 1.000+ Gbps
- **Foco**: Conectividade global integrada, IA distribuída
- **Programas**: EU 6G Flagship, China 6G Initiative, ITU-R SG3

### Satélites Quantum
- **Status**: Pesquisa avançada (2025-2030)
- **Aplicação**: Distribuição de chaves criptográficas quânticas via satélite
- **Exemplo**: Micius (China), planned EU Quantum Internet Alliance satellites
- **Segurança**: Criptografia teórica incondicionalmente segura
- **Alcance**: Global via rede de satélites

## Protocolos Principais

| Protocolo | Frequência | Largura Banda | Aplicação |
|-----------|-----------|---------------|-----------|
| DVB-S2 | Ku/Ka (11-14 GHz, 17-21 GHz) | Até 50 Mbps | TV, Broadcasting |
| DVB-RCS2 | Ku/Ka | Até 2 Mbps uplink | Internet bidirecional |
| 3GPP NTN | n255, n256 | Variável | D2D, IoT |
| LoRaWAN | 868 MHz, 915 MHz | 50 kbps-250 kbps | IoT de longo alcance |
| Iridium | 1.600 MHz | 2.4 kbps | Comunicação de voz |

## Bandas de Frequência Utilizadas

- **L-band**: 1-2 GHz (Iridium, Globalstar)
- **S-band**: 2-4 GHz (comunicações)
- **C-band**: 4-8 GHz (transoceânicos)
- **X-band**: 8-12 GHz (militar)
- **Ku-band**: 11-14 GHz (satélites comerciais)
- **Ka-band**: 17-21 GHz (banda larga satélite)
- **V-band/W-band**: 40-75 GHz (futuro 6G)
- **Terahertz**: 100 GHz - 10 THz (pesquisa 6G)

## Infraestrutura Complementar

### Gateway (Estações Terrenas)
- Antenas parabólicas 1-5m
- Equipamentos de upconversion/downconversion
- Sistemas de rastreamento (tracking)
- Redundância para confiabilidade

### Redes Terrestres de Backhaul
- Fibra óptica
- Microwave de longa distância
- Power line communication

## Regulação e Padronização

- **ITU-R**: Regulação internacional de frequências
- **3GPP**: Padrões de integração satélite-terrestre (Release 17+)
- **ETSI**: Padrões europeus (DVB-S2)
- **FCC**: Regulação americana
- **ANATEL**: Regulação brasileira

## Tendências Futuro (2025-2030)

1. Mega-constelações LEO (100.000+ satélites)
2. Integração 5G/6G completa
3. Comunicação satélite-satélite via laser
4. Redução de custo e latência
5. Maior integração com IoT e IA
6. Criptografia quântica via satélite
7. Cobertura ubíqua global
