# 04 - COMUNICAÇÃO VIA REDE ELÉTRICA (PLC)

## ÍNDICE
1. PLC (Power Line Communication)
2. Padrões PLC
3. Tecnologias Específicas
4. Smart Grid e Smart Metering
5. Sistemas em Desenvolvimento
6. Tendências 2025-2030

---

## 1. PLC - COMUNICAÇÃO VIA LINHA DE POTÊNCIA

### **Conceito**

Comunicação dados modulando sinal alta frequência sobre fios elétricos existentes. Não requer nova infraestrutura cabeada.

**Vantagem Principal**
- Reutiliza infraestrutura existente (cobre/alumínio distribuição)
- Cobertura ampla (backbone distribuidoras)

**Desvantagens**
- Ambiente altamente ruidoso (motores, equipamentos)
- Atenuação sinal aumenta com frequência
- Interferência eletromagnética (EMI)
- Segurança elétrica (isolação circuitos necessária)

### **Histórico**

**Fase 1: Banda Baixa (1970s-2000s)**
- Frequência: <500 kHz
- Taxa: <1 kbps típico
- Uso: Telemetria, faturamento leitura,lâmpadas públicas comando

**Fase 2: Banda Larga (1990s-2010s)**
- Frequência: 2-30 MHz
- Taxa: 50-200 kbps
- Padrão: ITU-T G.9601, HomePlug 1.0/AV

**Fase 3: Ultra-Banda Larga (2010s-2025)**
- Frequência: 1-100 MHz
- Taxa: 1-2 Gbps (laboratorório), 100-500 Mbps real
- Padrão: ITU-T G.9701, G.hn

---

## 2. PADRÕES PLC OPERACIONAIS

### **HomePlug (Banda Larga Residencial)**

**HomePlug 1.0 (2001)**
- Frequência: 4-21 MHz
- Taxa: 14 Mbps nominal (real ~2-5 Mbps)
- Modulação: OFDM

**HomePlug AV (2005)**
- Frequência: 2-28 MHz
- Taxa: 200 Mbps (nominal), 50-100 Mbps real
- Modulação: OFDM com coding
- Casos: Streaming vídeo residencial

**HomePlug AV2 (2012)**
- Frequência: 2-30 MHz
- Taxa: 600 Mbps (nominal), 150-300 Mbps real
- MIMO: Duplo (2x2)
- Casos: Home theater HD, múltiplos streams

**HomePlug Green PHY (2010)**
- Frequência: 2-28 MHz
- Taxa: 10 Mbps reduzido
- Foco: Ultra-baixo consumo (medidores inteligentes)
- Padrão: IEEE 1901 compatível

**Status (2025)**
- ⚠️ Sunsetting (WiFi competição)
- 🔄 Legado industrial (confiabilidade)
- 📊 <5% mercado vs WiFi

### **G.hn (ITU-T Convergente Padrão)**

**G.hn General Recomendação (2009+)**
- **G.9601**: Cabo coaxial + par trançado
- **G.9701**: Linha elétrica
- **G.9703**: Combinado padrão
- Frequência: 1-100 MHz (dependente meio)
- Taxa: 2 Gbps teórico
- Modulação: OFDM, modulação adaptativa

**Implementadores**
- **Conectus** (US): Solução PLC residencial
- **Copley Electronics** (China): Smart grid
- Adoptores: Alguns operadores telecom

**Status (2025)**
- 🔬 Protótipos
- ⚠️ Pouca adoção (vs homePlug legacy)

### **PRIME (PoweRline Intelligent Metering Evolution)**

**Especificação**
- Padrão: ITU-T G.9904
- Frequência: 400-500 kHz (CENELEC A banda)
- Taxa: 128 kbps (vs 1 Mbps target)
- Topologia: Mesh auto-reparável
- Codificação: OFDM + FEC

**Implementadores**
- Desenvolvimento: Atos, Landis+Gyr, etc.
- Adoção: Espanha, Itália, Portugal (utilities elétricas)

**Casos Uso**
- Smart metering (medidores leitura remota)
- Iluminação pública comando (streetlights)
- Telemedicina (sub-10 kbps suporta)

**Status (2025)**
- ✅ Operacional: Algumas cidades Ibérica
- 🔄 Expansão: Gradual utilities Latam
- 🎯 Brasil avaliar 2025-2026

### **G3 (G3-PLC)**

**Desenvolvimento**: Maxim/Analog Devices, Semtech, outros
**Especificação**
- Padrão: Proprietário baseado ITU-T G.9904
- Frequência: 150 kHz-1.8 MHz (faixa restrita)
- Taxa: 50-200 kbps
- Topologia: Mesh

**Implementadores**
- Utilities globais (Sagemcom, Conzerv, etc.)
- Adoção: Melhor que PRIME em Américas

**Status (2025)**
- ✅ Operacional globalmente
- ✅ Brasil adoção crescimento (utilidades)
- 🎯 Padrão de facto smart metering muitos países

---

## 3. SMART GRID & SMART METERING

### **Infraestrutura Inteligente Rede Elétrica**

**Componentes Comunicação**
1. **Backbone**: Fibra óptica (distribuidoras centrais)
2. **Distribuição**: PLC + microondas (sub-distribuidoras)
3. **Último km**: PLC (medidores) ou Cellular (5G futuro)
4. **IoT**: Sensores linhas, transformadores (WSN, LoRaWAN)

**Cadeia Medição**
```
Medidor Inteligente (Smart Meter)
    ↓ PLC/Cellular
Concentrador (Concentrator)
    ↓ Microondas/Fibra
Subestação Regional
    ↓ Fibra
Distribuição Central/SCADA
```

### **Especificações Medidores Inteligentes**

**Transmissão**
- Comunicação: PLC (G3/PRIME) ou NB-IoT/LTE-M
- Frequência transmissão: Diária (típico), horária (novo)
- Latência tolerância: Minutos (não crítico)

**Dados Coletados**
- Consumo eletricidade (kWh)
- Fator potência
- Harmônicos (qualidade energia)
- Eventos (corte/reexão, falha)

**Segurança**
- Criptografia: AES-128 mínimo
- Autenticação: Certificados X.509
- Anti-tampering: Detecção física abertura

### **Smart Grid Brasil (2025)**

**Iniciativa**
- Programa: Avaliação tecnologias smart metering
- Operadoras: Copel, AES Eletropaulo, Cemig (testes piloto)
- Padrão: Avaliando G3 vs PRIME vs NB-IoT

**Rollout Esperado**
- 2025-2026: Testes grande escala
- 2027-2030: Implementação faseada
- Meta: Medição em tempo-real 50%+ clientes 2030

---

## 4. SISTEMAS EM DESENVOLVIMENTO (2024-2025)

### **NB-IoT vs PLC para Smart Metering**

**PLC Vantagens**
- Usa infraestrutura elétrica existente
- Sem dependência operador móvel
- Pronto (já implementado algumas cidades)

**NB-IoT Vantagens**
- Outdoor confiável (linhas abertas)
- Menos interferência ambiente
- Independente linha elétrica (rede diferente)
- Más: Custos operador subscriptions (vs PLC gratuito)

**Tendência Brasil**
- 🔄 Híbrido esperado: PLC residencial + NB-IoT outdoor/rural
- 📅 Definição padrão 2025-2026

### **5G para Smart Grid (Futuro)**

**Aplicações**
- URLLC: Proteção equipamentos (proteção rápido <100ms)
- eMBB: Câmeras monitoração (segurança)
- mMTC: Sensores distribuídos

**Status (2025)**
- 🔬 Pilotos operadores premium
- 📅 Adoção 2027+ (esperado)

---

## 5. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- G3-PLC crescimento smart metering latam
- Smart metering padrão Brasil definição
- PLC legacy (HomePlug) descontinuação
- NB-IoT adoção paralela alguns operadores

**Médio Prazo (2026-2027)**
- Smart metering rollout começar Brasil/Latam
- Híbrido PLC + celular implementação
- 5G pilotos smart grid aumentar
- Li-Fi potencial último km (futuro remoto)

**Longo Prazo (2028-2030)**
- Smart grid ubíquo muitos países
- PLC possivelmente substituído 5G/6G (longo prazo)
- IA análise real-time consumo
- Integração renewable energy (solar, eólico)

---

**Documento Versão: 2025-01**
**Próxima atualização: Abril 2025**
