# 05 - COMUNICAÇÃO ACÚSTICA E SONAR

## ÍNDICE
1. Acústica Submarina
2. Sonar e Ultrassom
3. Sistemas Ultrassônico Aéreo
4. Acústica em Pesquisa
5. Tecnologias Emergentes
6. Tendências 2025-2030

---

## 1. ACÚSTICA SUBMARINA

### **Ondas Acústicas Propriedades Agua**

**Velocidade Som Água**
- Água doce: ~1.500 m/s (vs ar 343 m/s)
- Água salgada: ~1.500 m/s típico (varia temperatura/salinidade)
- Profundidade: Afeta velocidade (mínimo ~4.700 m profundidade)

**Atenuação Frequência**
- Baixa frequência (<1 kHz): Alcance 10-100 km
- Média frequência (10-100 kHz): 1-10 km
- Alta frequência (>100 kHz): <1 km
- Trade-off: Frequência vs alcance

### **Modems Acústicos Submarinos**

**Especificações Típicas**

| Características | Intervalo | Notas |
|-----------------|-----------|-------|
| Frequência | 10-400 kHz | Depende aplicação |
| Taxa dados | 50-13.000 bps | Vs WiFi Mbps |
| Alcance | 100m-100+ km | Vs WiFi ~100m |
| Latência | 100ms-10s | Maior que RF |
| Alcance profundidade | 0-6.000m | Maioria <1.000m |
| Consumo potência | 1-50W | Para transmissão |

**Implementadores**
- **Water Linked**: Noruega (modems série WM)
- **Teledyne/Benthos**: EUA (modems marinhos)
- **Sonardyne**: UK (telemetria submarino)
- **Tritech**: UK (câmeras, modems, sonar)
- **Hydro Acoustic Systems**: Ucrânia (modems, USBLs)

### **Casos Uso Submarina**

**Pesquisa Oceanográfica**
- Comunicação AUV (Autonomous Underwater Vehicles)
- Sensores profundidade (temperatura, salinidade, corrente)
- Bóias oceanográficas (recoloca dados via satélite)

**Indústria Óleo & Gás**
- ROVs (Remotely Operated Vehicles) submersível controle
- Monitoramento dutos
- BOP (Blowout Preventer) comunicação

**Militar/Segurança**
- Submarinos comunicação
- Minas anti-navio detecção
- Vigilância subaquática

**Pesquisa Marinha Biológica**
- Rastreamento mamíferos marinhos (non-invasive tags)
- Comunicação pesqueiros
- Observação vida marinha

### **USBL (Ultra Short BaseLine) e GNSS**

**USBL - Posicionamento Submarino**
- Princípio: Triangulação acústica fundo vs topo água
- Precisão: 0.5-3% alcance típico
- Uso: Localização ROV, AUV durante mergulho

**GNSS Submarina**
- Tecnologia: Bóia transmite satélite (não funciona água)
- Desvantagem: Ressurface necessária ou bóia emergente

**Futuro: Integração Satélite Acústico**
- Starlink + modem acústico (conceito)
- Dados surface via Starlink, comunicação submarina via acústica
- Status: Pesquisa, prototipagem esperada 2025-2027

---

## 2. SONAR E ULTRASSOM

### **Sonar Ativo vs Passivo**

**Sonar Ativo**
- Emitir som + escutar reflexão (eco)
- Frequência: 10-400 kHz típico
- Detecção: Objetos, peixes, estrutura rocha
- Resolução: Centímetros-metros (frequência dependente)

**Sonar Passivo**
- Escutar ruído ambiente (motores, vida marinha)
- Aplicação: Militar (submarinos detecção)
- Frequência: 5-50 kHz
- Alcance: Limitado ruído ambiente

### **Aplicações Sonar**

**Pesqueira**
- Peixe escola detecção
- Profundidade leitura
- Estrutura fundo

**Pesquisa Arqueológica**
- Naufrágios (busca)
- Estruturas submersas antigas (mapeamento)
- Exemplo: Titanic sonar exploração

**Navegação Submarino**
- Sonar forward-looking (prevenir colisão)
- Fundo mapeamento
- Obstáculos detecção (piscinas rocha, câmaras)

**Comunicação Submarina Alternativa**
- Modulation sonar pulse (vs modem acústico)
- Vantagem: Ruído ambiente encanução (menos inteligível)
- Desvantagem: Taxa muito baixa (<10 bps)

---

## 3. ULTRASSOM AÉREO

### **Especificação**

**Frequência**
- 20-200 kHz (além limite audição humana 20 Hz-20 kHz)
- Atenuação aérea alta vs água

**Aplicações Aéreo**

**Medição Distância**
- Sensores ultrassom robô/sensores de estacionamento
- Frequência: ~40 kHz
- Taxa: 100-1.000 pulsos/segundo
- Alcance: 2-4 metros
- Precisão: +/-5 cm

**Limpeza Ultrassônica**
- Dentaduras, joias
- Frequência: 20-100 kHz
- Cavitação remove detritos

**Terapia Acústica**
- Fisioterapia (aquecimento tecido)
- Frequência: 1-3 MHz
- Penetração: 3-5 cm

**Comunicação Ultrassom Aéreo (Pesquisa)**
- Frequência: 50-200 kHz
- Taxa: 10-100 kbps (laboratorório)
- Alcance: 1-10 metros
- Vantagem: Inaudível, não interfere RF
- Desvantagem: Atenuação alta, sensibilidade ruído

---

## 4. SISTEMAS ACÚSTICOS PESQUISA

### **REMUS (Remote Environmental Monitoring UnitS)**
- AUV autônomo pesquisa
- Comunicação: Modem acústico Teledyne
- Bateria: 24-48 horas típico
- Profundidade: 6.000m+ versão deep
- Pesquisa: NOAA, universidades

### **Argo Floats**
- Bóia descida-ascensão cíclica
- Não comunicação real-time (surface transmite Iridium)
- Sensores: Temperatura, salinidade, correntes
- Rede global: >4.000 floats operacionais

### **Nós Acústicos Submarinos**
- Sensor + modem (comunicação local mesh)
- Exemplo: Brown & Sons modems, Tritech sonares
- Rede: Até 10-20 nós (depends alcance/banda)

---

## 5. TECNOLOGIAS EMERGENTES

### **Underwater VLC (Visible Light Communication)**

**Conceito**
- Transmissão dados luz azul (penetra melhor água que RF)
- Frequência: 470-495 nm (luz azul)
- Taxa: 10-100 Mbps laboratorório
- Alcance: 100-300m
- Latência: <1 ms

**Vantagem**
- Coexistência acústica (não interfere)
- Banda larga vs acústico (kbps)
- Segurança: Luz não penetra além água

**Desafio**
- Linha de vista necessária (bloqueio objetos)
- Turbidez água reduz
- Mobilidade (handover problemas)

**Status (2025)**
- 🔬 Protótipos universitários
- 📅 Comercialização 2026-2030 esperada
- 🎯 Aplicação: Proximidade AUV, mergulhador comunicação

### **Quantum Communication Submarina**

**Conceito Futuro**
- QKD (Quantum Key Distribution) via fibra subaquática
- Segurança: Computador quântico-proof
- Desafio: Fibra marinha atenuação, repeaters necessários

**Status (2025)**
- 🧪 Pesquisa teórica
- 📅 Implementação 2030+

---

## 6. ACÚSTICA INDUSTRIAL

### **Monitoramento Equipamento (Condition Monitoring)**

**Uso**
- Detecção falhas rolamento (assinatura acústica)
- Vazamento ar/gás (ultrassom)
- Cavitação bombas (som de colapso bolha)

**Frequência Análise**
- 20-40 kHz (ultrassom) para detecção falha
- Análise: FFT para assinatura frequência

**Aplicação Brasil**
- Petrobras: Monitoramento bombas remotas
- Usinas: Detecção vazamento vapor
- Indústria: Manutenção preditiva

---

## 7. SÍNTESE: APLICAÇÕES ACÚSTICA

| Aplicação | Meio | Frequência | Taxa | Alcance | Status |
|-----------|------|-----------|------|---------|--------|
| **Modem comunic.** | Água | 50-400 kHz | 1-13 kbps | 100-100km | ✅ Operacional |
| **Sonar peixe** | Água | 50-200 kHz | Não dados | 100-1km | ✅ Operacional |
| **USBL posição** | Água | 50-200 kHz | N/A | 10-1km | ✅ Operacional |
| **Ultrassom distância** | Ar | 40 kHz | Pulsos | 2-4m | ✅ Operacional |
| **Underwater VLC** | Água | Azul 470-495nm | 10-100 Mbps | 100-300m | 🔬 Protótipos |
| **Quantum submarino** | Fibra | N/A | N/A | Fibra | 🧪 Pesquisa |

---

## 8. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- Underwater VLC protótipos avançar
- AUV comunicação modem evolução (higher rates)
- IoT submarino crescimento (boias Iridium + acústico)

**Médio Prazo (2026-2027)**
- Underwater VLC comercialização começar
- Integração Starlink + modem acústico pilotos
- 5G submarino extensão pesquisa

**Longo Prazo (2028-2030)**
- Underwater VLC ubíquo pesquisa oceanográfica
- Comunicação mista acústico+ótico submarino
- 6G "underwater extension" pesquisa inicial

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
