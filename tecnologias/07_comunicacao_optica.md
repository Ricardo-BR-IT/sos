# COMUNICAÇÃO ÓPTICA E FOTÔNICA

## Fiber Optics (Fibra Óptica)

### Fibra Óptica Monomodo (SMF)
- **Tipo**: Single-mode fiber
- **Comprimento onda**: 1.310 nm, 1.550 nm (bandas C, L, U)
- **Taxa de dados**: 10 Gbps - 800+ Tbps (conforme modulação)
- **Alcance**: 20-100 km sem amplificação (depende comprimento onda)
- **Aplicação**: Backbone internet, links transoceânicos
- **Padrão**: ITU-T G.652, G.653, G.654, G.655 (variedades)
- **Status**: Padrão global, ubíquo
- **Modulação**: OOK (On-Off Keying), QPSK, QAM até 4096-QAM
- **Duplexing**: WDM (Wavelength Division Multiplexing)
- **Vantagem**: Capacidade imensa, sem interferência RF
- **Custo**: Infraestrutura inicial alto, custo operacional baixo

### Fibra Multimodo (MMF)
- **Tipo**: Multi-mode fiber
- **Aplicação**: Redes locais, dentro edifício
- **Alcance**: 200m-2km (taxa alta), 20+ km (taxa baixa)
- **Taxa**: 100 Mbps - 100 Gbps
- **Padrão**: ITU-T G.651, OM1-OM5 (vários graus)
- **Status**: Operacional, declínio substituído SMF + Ethernet
- **Vantagem**: Acoplamento mais fácil, maior diâmetro núcleo

### Tecnologias Ópticas Avançadas

#### Coarse Wavelength Division Multiplexing (CWDM)
- **Canais**: Até 18 (banda 1.270-1.610 nm)
- **Espaçamento**: 20 nm
- **Taxa por canal**: 10 Gbps típico
- **Custo**: Moderado
- **Status**: Operacional, usado em metropolitan area networks

#### Dense Wavelength Division Multiplexing (DWDM)
- **Canais**: 40, 80, 160, 320+ por fibra
- **Espaçamento**: 0,4 nm, 0,2 nm (50 GHz, 100 GHz grid)
- **Taxa por canal**: 10 Gbps - 800 Gbps (DP-16QAM)
- **Alcance**: 40-80 km (sem regenerador)
- **Padrão**: ITU-T G.694.1
- **Status**: Padrão em redes modernas
- **Aplicação**: Backbone, links alta capacidade
- **Tecnologia recente**: Coherent DWDM (2015+)

#### Coherent Optical Communication
- **Modulação**: DP-QPSK, DP-16QAM, DP-64QAM, DP-256QAM
- **Taxa**: 100 Gbps - 800 Gbps por comprimento onda
- **Alcance**: 80-1000 km
- **Status**: Standard em operadores (2015+)
- **Vantagem**: Capacidade ultrahigh, alcance sem repetidor
- **Detector**: Coerente (Heterodyne/Homodyne)

#### Space-Division Multiplexing (SDM)
- **Conceito**: Múltiplas fibras em mesmo cabo, núcleos múltiplos em fibra
- **Status**: Pesquisa/early deployment (2023-2025)
- **Fibra**: Multi-core fiber (MCF), Few-mode fiber (FMF)
- **Capacidade**: Exponencialmente maior
- **Aplicação**: Datacenters interconectados, backbone futuro
- **Desafio**: Crosstalk entre núcleos/modos

#### Polarization-Multiplexed Transmission
- **Técnica**: Usar ambas polarizações da luz para dados
- **Ganho**: 2x capacidade em mesmo comprimento onda
- **Status**: Padrão em DWDM moderno
- **Protocolo**: DP (Dual Polarization)

## Comunicação de Espaço Livre Óptica (FSO / Free Space Optical)

### Laser Comunicação Ponto-a-Ponto
- **Frequência**: Visível a IR (400nm-1.600nm)
- **Tipo**: Laser, LED para curto alcance
- **Taxa de dados**: 100 Mbps - 10 Gbps
- **Alcance**: 100m-5km (claro), 500m chuva/neblina
- **Aplicação**: Backhaul, cross-building, satélite-terra
- **Padrão**: IEEE 802.15.7 (VLC), ITU-T (FSO)
- **Status**: Operacional em niches, crescimento
- **Vantagem**: Sem licença, immune RF interference, coerência
- **Desafio**: Atmosfera (chuva, neblina), visada direta

### Visible Light Communication (VLC / Li-Fi)
- **Frequência**: 380-780 nm (luz visível)
- **Modulação**: OOK, OFDM usando LEDs/OLEDs
- **Taxa**: 1-100 Mbps (conforme implementação)
- **Alcance**: 5-20m típico
- **Padrão**: IEEE 802.11bb (em desenvolvimento), IEEE 802.15.7
- **Status**: Pesquisa/protótipos avançados (2023-2025)
- **Vantagem**: 
  - Sem radiação RF
  - Iluminação dupla (comunicação + luz)
  - Largura banda visível (~400 THz) potencial
  - Segurança física (luz visível)
- **Desafio**: Luz solar, requerimento LOS, obstrução
- **Aplicação**: Interiores, hospitais, aviões, underwater
- **Tecnologia**: OLED-based, LED modulation

### Infrared Free Space Optical (IR-FSO)
- **Frequência**: 700nm-10μm (IR)
- **Taxa**: 1 Mbps - 100 Gbps
- **Alcance**: 100m - 50km
- **Padrão**: ITU-T G.9991, proprietário
- **Status**: Operacional comercialmente
- **Vantagem**: Invisível, melhor penetração atmosfera vs visível
- **Desafio**: Atenuação neblina/chuva, segurança laser
- **Aplicações**: Satélite-terra, torres, DataCenter interconexão

### Underwater Visible Light Communication
- **Frequência**: Azul-verde (460-510 nm) melhor penetração água
- **Taxa**: 1-100 Mbps
- **Alcance**: 100-300m em água clara
- **Status**: Pesquisa/protótipos (2023-2025)
- **Aplicação**: ROVs, sensores submarinos, comunição dolphin-free
- **Vantagem**: Não afeta cetáceos (vs sonar acústico)
- **Desafio**: Turbidez, reflexão, backscatter
- **Tecnologia**: Modulação OFDM adaptiva

## Comunicação Ultravioleta (UV)

### UV Communication
- **Frequência**: 10-400 nm (UV)
- **Tipo**: NLOS (Non-Line-of-Sight) possível via scattering
- **Taxa**: 100 bps - 10 kbps (pesquisa)
- **Alcance**: 100m-1km
- **Status**: Pesquisa conceitual (2024-2025)
- **Vantagem**: NLOS comunicação, covert
- **Desafio**: Atmosfera absorção, segurança UV
- **Aplicação**: Comunicação tática, militar potencial

## Comunicação Terahertz (THz) - Futuro

### THz Wireless Communication
- **Frequência**: 0.1-10 THz (100 GHz - 10 THz)
- **Taxa**: 100 Gbps - 10 Tbps (potencial)
- **Alcance**: 1-100m (conforme frequência, atmosfera)
- **Status**: Pesquisa ativa (2024+), pré-comercial 2026-2030
- **Modulação**: QPSK, QAM, potencial para maior
- **Aplicação**: 6G, datacenters ultrahigh bandwidth, imaging
- **Padrão**: Formando (IEEE 802.11, ITU-R)
- **Vantagem**: Ultra-larga largura banda, coerência óptica
- **Desafio**: 
  - Hardware complexo (mix eletrônico/fotônico)
  - Atmosfera absorção/oxigênio (line dips)
  - Difração (pequeninhas comprimento onda)
  - Segurança ocupacional (raios THz)

### Quantum Key Distribution (QKD)
- **Frequência**: Fotônico (ótico) ou microwave-based
- **Tipo**: Comunicação criptografia quântica
- **Taxa**: 100 bps - 100 kbps (conforme sistema)
- **Alcance**: 100km-1000km (fibra), 100m (espaço livre)
- **Padrão**: ITU-T X.1735, IEEE (em desenvolvimento)
- **Status**: Comercial (fibra-based), operadores começando implementar
- **Protocolo**: BB84, GLLP, E91, device-independent potencial
- **Segurança**: Incondicionalmente seguro (matemática quântica)
- **Aplicação**: Governo, financeiro, infraestrutura crítica
- **Exemplo**: ID Quantique, Toshiba, Chinese Quantum Sat (Micius)
- **Tendência**: Integração 5G/6G networks (2025+)

## Protocolos Ópticos

| Padrão | Aplicação | Taxa | Status |
|--------|-----------|------|--------|
| Ethernet ótico | LAN | 1-800 Gbps | Operacional |
| SONET/SDH | Telecom backbone | 2.5-40 Gbps | Operacional |
| OTN (Optical Transport Network) | Telecom | 2.7-111 Gbps | Operacional |
| Coherent (DP-16QAM+) | DWDM backbone | 100-800 Gbps | Operacional |
| FSO/Li-Fi | Espaço livre | 100 Mbps-10 Gbps | Comercial/Pesquisa |
| THz (futuro) | 6G | 100 Gbps-10 Tbps | Pesquisa |

## Modulação Óptica

- **Intensidade**: OOK, PAM (Pulse Amplitude Modulation)
- **Fase**: QPSK, BPSK
- **Quadratura**: QAM (16-QAM até 4096-QAM)
- **Polarização**: DP (Dual Polarization)
- **Tempo**: Pulse Position Modulation (PPM)
- **Espaço**: Space-division multiplexing (múltiplos núcleos)

## Tendências Ópticas (2025-2030)

1. **800 Gbps/1.6 Tbps DWDM**: Rollout operadores
2. **Coerente óptico**: Padrão em todo backbone
3. **Li-Fi comercial**: Primeiros produtos mainstream
4. **Underwater VLC**: Comunicação submarina óptica
5. **QKD integrado**: Redes seguras governo/financeiro
6. **THz protótipos**: Primeiros enlaces experimentais
7. **Space-division multiplexing**: Multi-core fibra deployment
8. **Silicon photonics**: Integração fotônica em chips (costo reduzido)
9. **Optical switching**: Substitui eletrônico para velocidades ultra-altas
10. **Quantum repeaters**: Extensão QKD alcance
