# REDES PELA REDE ELÉTRICA (Power Line Communication - PLC)

## Tecnologias PLC Operacionais

### PLC Narrowband
- **Frequência**: 3-500 kHz
- **Taxa de dados**: 0,6-600 kbps
- **Alcance**: 1-2 km
- **Aplicação**: Automação residencial, medição, smart grid
- **Padrão**: IEC 61334, IEC 61850
- **Status**: Operacional, amplamente implantado
- **Exemplos**: Contadores inteligentes, iluminação

### PLC G3
- **Frequência**: 35-91 kHz (G3-PLC)
- **Taxa**: 50-400 kbps
- **Topologia**: Mesh auto-cicatrizante
- **Padrão**: ITU-T G.9903
- **Aplicações**: Smart metering, distribuição de energia
- **Protocolo**: IPv6 nativo
- **Status**: Deployment em operadores (2015+)
- **Vantagem**: Sem necessidade cabeamento novo
- **Exemplo**: PRIME (Power Line Intelligent Metering Evolution)

### PRIME
- **Frequência**: 42-89 kHz
- **Baseado em**: ITU-T G.9904
- **Protocolo**: 6LoWPAN sobre PLC
- **Taxa**: Até 128 kbps
- **Topologia**: Árvore hierárquica
- **Status**: Deployment operadores Europa
- **Foco**: Medidores inteligentes e automação

### PLC Broadband (BPL)
- **Frequência**: 1,6-30 MHz
- **Taxa de dados**: 10-200 Mbps
- **Alcance**: 150-300m
- **Aplicação**: Internet banda larga via rede elétrica
- **Padrão**: IEEE 1901, ITU-T G.hn
- **Status**: Descontinuado/Raro (interferência RF)
- **Desafios**: Ruído variável, interferência, regulação
- **Histórico**: Boom 2000s-2010, decline 2015+

### ITU-T G.hn (Wired Broadband)
- **Tipo**: PLC, Coax, Telecom linha telefônica
- **Frequência**: 4-100 MHz
- **Taxa**: 100 Mbps - 1 Gbps
- **Alcance**: 500m-1km dependendo meio
- **Padrão**: ITU-T G.9960, G.9961
- **Status**: Pesquisa/piloto (raramente comercial)
- **Vantagem**: Unifica múltiplas topologias cabeadas

### PowerLine AV / AV2 (Homeplug)
- **Frequência**: 1,8-30 MHz
- **Taxa**: AV (200 Mbps), AV2 (600 Mbps teórico)
- **Alcance**: 150m típico
- **Uso**: Redes domésticas, adaptadores de tomada
- **Padrão**: IEEE 1901 (AV), IEEE 1901.2 (AV2)
- **Status**: Disponível comercialmente, niche market
- **Exemplo produto**: TP-Link, Netgear Powerline adapters
- **Desafios**: Instalação elétrica varia muito qualidade

## Sistemas de Distribuição Inteligente

### SCADA / EMS (Energy Management Systems)
- **Protocolo**: Modbus, DNP3, IEC 60870-5-104
- **Frequência**: Múltiplas (serial, ethernet, PLC)
- **Aplicação**: Monitoramento e controle redes elétricas
- **Status**: Operacional em grande escala
- **Evolução**: Transitando para IEC 61850 (subestações)

### Smart Grid Advanced Metering Infrastructure (AMI)
- **Protocolo**: PLC G3/PRIME, RF (NB-IoT, Sigfox), híbrido
- **Frequência**: Múltiplas conforme protocolo
- **Dados**: Consumo energia, qualidade poder, eventos
- **Status**: Deployment crescente (2015-2025)
- **Padrão**: IEC 61334 (DLMS/COSEM)
- **Aplicações**: Medidores inteligentes, gestão demanda

### Frequency Bands para PLC

| Banda | Frequência | Uso | Padrão |
|-------|-----------|-----|--------|
| Ultra Narrowband | 3-500 kHz | Metering | IEC 61334 |
| Narrowband | 35-91 kHz | Smart grid | G3/PRIME |
| Broadband | 1,6-30 MHz | Internet | IEEE 1901 |
| Ultra-Broadband | 4-100 MHz | Convergente | ITU-T G.hn |

## Tecnologias em Desenvolvimento

### Hybrid PLC-RF
- **Status**: Pesquisa/piloto (2023-2025)
- **Conceito**: Combinar PLC com wireless (NB-IoT, LoRaWAN)
- **Benefício**: Resiliência, redundância, melhor cobertura
- **Aplicação**: Smart metering, distribuição
- **Exemplo**: Operadores europeus testando soluções

### PLC Terahertz (Futuro)
- **Status**: Conceitual (pesquisa 2025+)
- **Frequência**: 0,1-10 THz
- **Potencial**: Comunicação banda ultra-larga via rede elétrica
- **Desafios**: Hardware, interferência, isolamento
- **Horizonte**: 2030-2035

### DC Power Distribution com PLC
- **Status**: Pesquisa (2024-2025)
- **Conceito**: PLC em redes de energia DC (datacenters, renovável)
- **Benefício**: Eficiência, integração com armazenamento
- **Exemplo**: Datacenters com energia local + PLC

## Aplicações Principais

1. **Medição Inteligente (Smart Metering)**
   - Coleta automática consumo
   - Operadores: EDP, Enel, Hydro

2. **Distribuição de Energia Inteligente (Smart Grid)**
   - Monitoramento qualidade poder
   - Detecção falhas
   - Demanda resposta

3. **Automação Residencial**
   - Iluminação inteligente
   - Aquecimento/climatização
   - Aparelhos conectados

4. **Internet Doméstica (menor uso)**
   - Adapter powerline (TP-Link, Netgear)
   - Backup para WiFi
   - Custo vs WiFi moderno

## Vantagens vs Desvantagens

### Vantagens
- ✅ Infraestrutura existente (sem novo cabeamento)
- ✅ Alcance relativo
- ✅ Penetração paredes
- ✅ Redundância em smart grid
- ✅ Segurança física (rede privada)

### Desvantagens
- ❌ Qualidade variável por instalação elétrica
- ❌ Interferência EMI (ruído)
- ❌ Taxa vs cabeamento direto
- ❌ Latência variável
- ❌ Regulação de EMI em alguns países
- ❌ Declínio internet BPL

## Regulação e Padrões

- **Brasil (ANATEL)**: Regulamentação PLC em desenvolvimento
- **EU**: Diretivas EMC, RTTE, CE marking
- **US/FCC**: Limitações EMI para BPL
- **Padrões internacionais**: ITU-T, IEC, IEEE
- **Segurança**: IEC 62820 (EMC para PLC)

## Tendências (2025-2030)

1. Expansão G3/PRIME para smart metering global
2. Hybrid PLC-wireless padrão
3. Integração IoT via PLC em smart cities
4. Suporte vehicle-to-grid (V2G) via PLC
5. Microgrids com PLC como backbone
6. Edge computing integrado com medidores PLC
7. Criptografia aprimorada para segurança
