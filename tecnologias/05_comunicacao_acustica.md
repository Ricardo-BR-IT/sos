# SISTEMAS DE COMUNICAÇÃO ACÚSTICA E ÁUDIO

## Comunicação Acústica Aérea

### Sistemas Acústicos Convencionais
- **Frequência**: 20 Hz - 20 kHz (audível humano)
- **Meio**: Ar, espaço aberto
- **Alcance**: Até 1 km em condições ideais
- **Aplicação**: Comunicação verbal, PA (Public Address)
- **Protocolo**: Analógico, digital (VoIP)
- **Status**: Fundamental, ubíquo
- **Velocidade som**: 343 m/s (ar, 20°C)

### Sistemas de Identificação por Radiofrequência via Som
- **Frequência**: Ultrassom 20-200 kHz
- **Alcance**: 1-10 metros
- **Aplicação**: Sincronização, localização interna
- **Protocolo**: Custom
- **Status**: Niche (pesquisa, alguns produtos)
- **Exemplo**: Sistemas de localização indoor

### Modems Acústicos Subaquáticos
- **Frequência**: 8-40 kHz típico
- **Taxa**: 50 bps - 80 kbps conforme modelo
- **Alcance**: 10 metros - 20 km (conforme frequência)
- **Meio**: Água doce/salgada
- **Aplicação**: Comunicação submarino, ROV, sensores ocean
- **Padrão**: Proprietário principalmente
- **Status**: Operacional, aplicações científicas/militar
- **Desafios**: 
  - Reflexão em camadas termoclinas
  - Multipercurso (multipath)
  - Ruído de navios, cetáceos
- **Exemplo produtos**: Sonardyne, Water Linked, Teledyne Benthos

### Comunicação Acústica Subaquática Emergente
- **Li-Fi subaquático**: Luz visível em água
  - Frequência: Azul-verde (460-510 nm melhor penetração)
  - Taxa: 1-100 Mbps
  - Alcance: 100-300m em água clara
  - Status: Protótipos, pesquisa (2023-2025)
  - Vantagem: Não afeta cetáceos
  - Desafio: Turbidez da água

### Sonares Acústicos
- **Tipo**: Ativo e Passivo
- **Frequência**: 10 kHz - 500+ kHz
- **Aplicação**: Detecção, navegação, mapeamento
- **Status**: Padrão militar/científico
- **Protocolo**: Proprietário principalmente
- **Exemplo**: Sonares multifeixe, DIDSON

## Comunicação Ultrassônica

### Ultrassom de Médio Alcance (20-100 kHz)
- **Frequência**: 20-100 kHz
- **Alcance**: 1-50 metros
- **Taxa de dados**: 100 bps - 10 kbps
- **Aplicação**: Localização interna, sensores de proximidade
- **Meio**: Ar, água
- **Padrão**: IEEE 802.15.4 (parcialmente), Custom
- **Status**: Comercial em niches

### Ultrassom de Curto Alcance (100+ kHz)
- **Frequência**: 100 kHz - 1 MHz
- **Alcance**: 0,5-10 metros
- **Aplicação**: Sensores, medição, diagnóstico médico
- **Protocolo**: Custom/proprietário
- **Status**: Padrão em muitas aplicações

## Comunicação via Vibrações Mecânicas

### Comunicação Háptica (Vibração)
- **Frequência**: 10-1000 Hz
- **Alcance**: Contato direto - alguns metros em estrutura
- **Taxa**: Baixa (bits, não Mbps)
- **Aplicação**: Realimentação tátil, comunicação por contato
- **Status**: Pesquisa (2023-2025)
- **Exemplo**: Wearables, interfaces hápticas

### Vibrações em Estrutura (Ground/Structure Vibration)
- **Frequência**: 5-1000 Hz
- **Alcance**: 10-100m na estrutura
- **Taxa**: Ultra-baixa
- **Aplicação**: Monitoring estrutural, comunicação emergencial
- **Status**: Pesquisa
- **Desafio**: Absorção, dissipação energia

## Comunicação Óptica via Som

### FSO (Free Space Optical) com Modulação Acústica
- **Conceito**: Usar sinal óptico para modular/amplificar acústica
- **Status**: Conceitual/pesquisa
- **Aplicação**: Longa distância com precisão

## Protocolos e Padrões Acústicos

### JANUS (Joint Acoustic Network and Undersea Systems)
- **Padrão**: NATO STANAG 4748
- **Frequência**: 18.5 - 110.5 kHz
- **Taxa**: 200 bps - 10 kbps
- **Alcance**: 25-400 km (conforme frequência)
- **Aplicação**: Comunicação militar subaquática
- **Status**: Operacional
- **Vantagem**: Interoperabilidade internacional

### Hydroacoustic Data Modems
- **Frequência**: 10-100 kHz
- **Taxa**: Variável
- **Protocolo**: Proprietário (cada fabricante)
- **Exemplo**: Micro-Modem (Woods Hole), WHOI-Micro
- **Status**: Pesquisa/científico

### Acoustic Positioning Systems (USBL - Ultra-Short BaseLine)
- **Frequência**: 100-500 kHz
- **Aplicação**: Localização submarina precisa
- **Alcance**: 100-500m
- **Precisão**: 0,5-2% da distância
- **Status**: Padrão em oceanografia

## Tendências (2025-2030)

1. **Comunicação acústica IA-otimizada** em ambientes subaquáticos
2. **Híbrido acústico-óptico** para maior bandwidth submarino
3. **Proteção cetáceos** com frequências não-invasivas
4. **Comunicação em terra** via ultrassom para IoT
5. **Integração satélite-acústico** para ROVs remotos
6. **Machine learning** para detecção de sinais em ruído
7. **Redes acústicas mesh** submarinas

## Limitações Acústicas

| Aspecto | Ar | Água | Estrutura |
|---------|-----|------|-----------|
| Velocidade | 343 m/s | 1.480-1.540 m/s | 3.000-5.000 m/s |
| Alcance | 1-100 km | 1-400 km | 1-100 km |
| Absorção | Baixa | Alta (ruído) | Alta |
| Largura banda | Média | Baixa | Muito baixa |
| Latência | Média | Alta | Média |

## Aplicações Principais

1. **Comunicação Submarino**: Comando, navegação, ciência
2. **Oceanografia**: Coleta dados sensor, monitoramento
3. **Localização Interna**: Alternativa ultrassom vs WiFi
4. **Sensores**: Proximidade, medição distância
5. **Diagnóstico Médico**: Ultrassom gerador imagem
6. **Militar**: Sonar, JANUS, reconhecimento
7. **Pesquisa**: Comunicação inovadora subaquática
