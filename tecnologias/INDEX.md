# ÍNDICE GERAL - SISTEMAS E TECNOLOGIAS DE COMUNICAÇÃO

**Compilação: Janeiro 2025**  
**Escopo**: Tecnologias operacionais + em pesquisa Brasil e globalmente  
**Atualização**: Mensal (alterações significativas); anual (revisão completa)

---

## 📚 ESTRUTURA ARQUIVOS

### **01 - Redes Celulares e Mobilidade**
**Arquivo**: `01_celular_mobilidade.md`

**Conteúdo**
- 2G (GSM/CDMA) - Descontinuação 2025-2026
- 3G (WCDMA/CDMA2000) - Legado, fim vida 2025
- 4G LTE - Ubiquidade Brasil
- 5G NR - Expansão 2025+
- LTE-M / NB-IoT - IoT celular
- Infraestrutura: RAN, Core Network, Backhaul
- Operadoras Brasil: Vivo, TIM, Claro, Oi
- Roadmap 5G Brasil 2025-2030
- Tendências: 6G pesquisa, NSA→SA transição

**Casos Uso Principais**
- Mobilidade primária (smartphone)
- IoT baixo consumo (NB-IoT)
- Conectividade crítica (ambulância, polícia)

**Status Brasil 2025**
- 5G: ~50% população urbana (crescimento)
- 3G: Desligamento oficial 2025-2026
- 2G: Obsoleto

---

### **02 - WiFi e Redes Locais (WLAN)**
**Arquivo**: `02_wifi_wlan.md`

**Conteúdo**
- WiFi 4 (802.11n) - Legado, ainda uso
- WiFi 5 (802.11ac) - Padrão atual residencial
- WiFi 6 (802.11ax) - Novidade 2022+, crescimento
- WiFi 6E (6 GHz) - Futuro próximo (2025+)
- WiFi 7 (802.11be) - Pesquisa (2026+)
- Segurança: WEP→WPA2→WPA3 evolução
- Otimização: Banda dupla, OFDMA, MU-MIMO
- Comparação WiFi vs Celular
- Casos uso: Casa, Trabalho, Hotspot
- Operadores Brasil: Instalação, conectividade

**Tendências 2025-2030**
- WiFi6E cobertura crescente
- Espectro 6 GHz liberação
- Integração 5G+WiFi seamless

---

### **03 - Redes IoT Mesh (Zigbee, Thread, Bluetooth)**
**Arquivo**: `03_iot_mesh.md`

**Conteúdo**
- Bluetooth (clássico + LE)
- Bluetooth Mesh
- Zigbee (IEEE 802.15.4)
- Thread (IPv6 over 802.15.4)
- Protocolos comparativa
- Casos uso: Wearable, Smart Home, Industrial
- Stack protocolo: Físico→MAC→Rede→App
- Consumo energético vs alcance
- Topologia: Star vs Mesh escalabilidade
- Segurança: AES-128, key derivation

**Aplicações Brasil**
- Smart home (Positivo Smart, Intelbras)
- Wearables (relógios, pulseiras)
- Indústria 4.0 (sensores fábrica)

---

### **04 - Satélites e Comunicação Espacial**
**Arquivo**: `04_satelites.md`

**Conteúdo**
- Tipos órbita: GEO, MEO, LEO
- Comunicação satélite tradicional
- Constelações modernas: Starlink, OneWeb, Kuiper, Amazon Kuiper
- Satélite IoT: Iridium, Globalstar, Inmarsat
- Satélite observação Earth (indiretamente comuns)
- Latência vs alcance análise
- Custo CAPEX/OPEX infraestrutura
- Cobertura Brasil: Amazonas, oceano, desastres
- Tendências: Mega-constelações, space internet

**Operadores Brasil 2025**
- Starlink: ~20k subscriptores, crescimento rápido
- Amazonisat (Telebrás): Preparação produção
- Viasat: Cobertura Brasil expandindo
- Satcom tradicional: Embratel, Telecom Italia

---

### **05 - Rede Elétrica e Power Line (PLN)**
**Arquivo**: `05_power_line.md`

**Conteúdo**
- Comunicação pela linha eletricidade (não wireless)
- Tecnologias: PRIME, G3, OFDM adaptativo
- Smart Grid: Medidor→Concentrador→Operadora
- Smart Meter comunicação (últimas milha)
- Frequência: DC-100 kHz tipicamente
- Taxa: 50-600 kbps dependendo distância
- Casos uso: Medição consumo, telemetria eletricidade
- Regulação: ANEEL (Agência Nacional Energia Elétrica)
- Operadores Brasil: Eletrobras, Copel, EDP, Light

**Descontinuação Planejada**
- PLC 2G obsoleto (PRIME v1 → v2)
- Adoção OFDM adaptativo futuro

---

### **06 - Ondas de Rádio Tradicional e LPWAN**
**Arquivo**: `06_ondas_radio.md`

**Conteúdo**
- AM (Amplitude Modulation) - Legado
- FM (Frequency Modulation) - Padrão radiodifusão
- DAB+ (Digital Audio Broadcasting) - Futuro FM
- Rádio Amador (Amateur Radio)
- HF/NVIS comunicação longa distância
- LoRaWAN (Long Range Wide Area Network)
- Sigfox LPWAN alternativa
- Comparativa LPWAN: LoRa vs NB-IoT vs Sigfox
- Freqüência alocação Brasil ANATEL

**Transições Esperadas**
- FM descontinuação alguns países (2025+)
- DAB+ lenta adoção Brasil
- LoRaWAN + NB-IoT competição futuro
- Satélite IoT + LoRaWAN convergência

---

### **07 - Sistemas de Áudio e Comunicação Acústica**
**Arquivo**: `07_sistemas_audio.md`

**Conteúdo**
- VoIP (Voice over IP)
- Protocolos: SIP, RTP, RTCP
- Codecs: G.711, G.729, Opus, Speex
- WebRTC navegador comunicação
- Ultrassônico comunicação (20-200 kHz)
- Acústica subaquática marinha
- TTS (Text-To-Speech) síntese neural
- ASR (Automatic Speech Recognition) IA
- Qualidade voz, latência, jitter
- Operadores Brasil: Google, Azure, AWS, open source

**Tendências 2025**
- Neural TTS padrão (substitui concatenativa)
- ASR 97%+ acurácia português
- Spatial audio streaming crescimento
- Voice cloning ética/segurança questões

---

### **08 - Síntese Geral e Matriz Comparativa**
**Arquivo**: `08_sintese_geral.md`

**Conteúdo**
- Tabela resumida todas tecnologias
- Matriz decisão (alcance, consumo, custo, latência)
- Roadmap Brasil 2025-2030
- Recomendações por caso uso
- Glossário técnico siglas/conceitos
- Resumo executivo quick reference

**Seções Principais**
1. Comparativa 25+ tecnologias
2. Matriz 2x2 simplicidade vs performance
3. Timeline Brasil próximos 5 anos
4. Guia seleção tecnologia específica
5. Definições termos recorrentes

---

## 🎯 COMO USAR ESTA DOCUMENTAÇÃO

### **Busca por Tecnologia Específica**

```
Quer aprender sobre WiFi?
→ Arquivo 02_wifi_wlan.md

Precisa entender 5G?
→ Arquivo 01_celular_mobilidade.md (seção 5G)

Quer implementar IoT sensores?
→ Arquivo 03_iot_mesh.md + 06_ondas_radio.md (LoRaWAN)
```

### **Busca por Caso Uso**

```
"Comunicação emergência sem rede"
→ Arquivo 06_ondas_radio.md (HF Rádio) + 04_satelites.md

"Internet cobertura rural"
→ Arquivo 04_satelites.md + 01_celular_mobilidade.md (5G futuro)

"Smart home conectada"
→ Arquivo 03_iot_mesh.md + 02_wifi_wlan.md

"Sistema VoIP empresa"
→ Arquivo 07_sistemas_audio.md (VoIP, SIP, Codecs)
```

### **Busca por Localização Geográfica**

```
"Tecnologias operacionais Brasil 2025"
→ Cada arquivo seção "Status Brasil"

"Transições planejadas próximos 2 anos"
→ Arquivo 08_sintese_geral.md (Roadmap)

"Operadores telecom locais"
→ Procure seção "Operadores Brasil" arquivo relevante
```

---

## 📊 MATRIZ RÁPIDA DECISÃO

### **Qual Tecnologia Escolher? (Simplificado)**

| Preciso... | Recomendação | Arquivo |
|-----------|--------------|---------|
| **Conectividade grande distância, baixo consumo** | LoRaWAN | 06 |
| **Internet rápida casa/escritório** | WiFi6 | 02 |
| **Comunicação emergência sem infraestrutura** | HF Rádio Amador | 06 |
| **Telefonia empresarial** | VoIP (3CX/Asterisk) | 07 |
| **Wearables/periféricos** | Bluetooth LE | 03 |
| **Internet zona rural** | Satélite (Starlink) | 04 |
| **Smart metering, IoT industrial** | NB-IoT ou LoRaWAN | 01, 06 |
| **Smart home automação** | Zigbee + WiFi | 03, 02 |

---

## 🔄 ATUALIZAÇÕES E MANUTENÇÃO

**Calendário**
- **Mensal** (manutenção): Atualizações significativas
- **Trimestral** (revisão): Alterações regulatórias
- **Anual** (completo): Atualização janeiro

**Próxima Revisão Completa**: Janeiro 2026

**Questões / Sugestões?**
- Remova compatibilidade antiga
- Adicione nova tecnologia emergente
- Corrija imprecisões fato
- Melhore clareza explicações

---

## 🗂️ LISTA ARQUIVOS

| Arquivo | Tópico Principal | Última Atualização | Próxima Revisão |
|---------|-----------------|-------------------|-----------------|
| `01_celular_mobilidade.md` | 2G→5G, LTE-M, NB-IoT | Jan 2025 | Jul 2025 |
| `02_wifi_wlan.md` | WiFi4→6E, WLAN | Jan 2025 | Jul 2025 |
| `03_iot_mesh.md` | Bluetooth, Zigbee, Thread | Jan 2025 | Abr 2025 |
| `04_satelites.md` | GEO, MEO, LEO, Constelações | Jan 2025 | Abr 2025 |
| `05_power_line.md` | PLC, Smart Grid, Smart Meter | Jan 2025 | Out 2025 |
| `06_ondas_radio.md` | AM/FM/DAB, HF, LoRaWAN | Jan 2025 | Jul 2025 |
| `07_sistemas_audio.md` | VoIP, ASR, TTS, WebRTC | Jan 2025 | Mar 2025 |
| `08_sintese_geral.md` | Matriz, Roadmap, Glossário | Jan 2025 | Jun 2025 |
| `INDEX.md` **(este arquivo)** | Navegação geral | Jan 2025 | Jan 2026 |

---

## 📈 ESTATÍSTICAS DOCUMENTAÇÃO

**Cobertura**
- ✅ 25+ tecnologias descritas
- ✅ 5+ anos roadmap (2025-2030)
- ✅ 50+ operadores/fabricantes mencionados
- ✅ 100+ casos uso inclusos
- ✅ 40+ tabelas comparativas

**Escopo Geográfico**
- 🇧🇷 Brasil (foco local)
- 🌍 Global (contexto internacional)
- 🔮 Tendências futuro

**Nível Técnico**
- 📘 Iniciante: Conceitos básicos
- 📗 Intermediário: Implementação prática
- 📕 Avançado: Arquitetura, segurança, otimização

---

## 🚀 COMO COMEÇAR

**Roteiro Recomendado para Diferentes Perfis**

### **Desenvolvedor IoT**
1. Leia: `08_sintese_geral.md` → Matriz Decisão
2. Escolha: LoRaWAN vs Zigbee vs NB-IoT
3. Estude: `06_ondas_radio.md` (LoRa) ou `03_iot_mesh.md` (Zigbee)
4. Implemente: Teste com gateway + sensor prototipagem

### **Engenheiro Telecom**
1. Leia: `01_celular_mobilidade.md` → Entenda 5G
2. Estude: `08_sintese_geral.md` → Roadmap Brasil
3. Acompanhe: Próximos 6 meses regulação ANATEL
4. Planeje: Roadmap corporativo 2025-2027

### **Profissional TI / Sistemas**
1. Leia: `02_wifi_wlan.md` → WiFi6 empresa
2. Estude: `07_sistemas_audio.md` → VoIP PBX
3. Implemente: Teste WiFi6 + VoIP 3CX
4. Plano: Migração infraestrutura 18-24 meses

### **Gestor/Executivo**
1. Leia: `08_sintese_geral.md` → Resumo Executivo
2. Foco: Roadmap Brasil, investimento recomendado
3. Decisão: Qual tecnologia adotar primeiro
4. Timeline: Quando investir (2025, 2026, 2027)

---

## 🔗 REFERÊNCIAS EXTERNAS

### **Órgãos Reguladores**
- ANATEL (Brasil): https://www.anatel.gov.br
- 3GPP (Padrões Celular): https://www.3gpp.org
- IEEE (Padrões Rede): https://www.ieee.org
- ITU (Telecomunicações Global): https://www.itu.int

### **Consortiuns / Alianças**
- WiFi Alliance: https://www.wi-fi.org
- LoRa Alliance: https://lora-alliance.org
- Bluetooth SIG: https://www.bluetooth.com
- Thread Group: https://www.threadgroup.org

### **Empresas / Operadores Principais Brasil**
- Vivo: https://www.vivo.com.br
- TIM: https://www.tim.com.br
- Claro: https://www.claro.com.br
- Starlink: https://www.starlink.com/pt-br

---

**Versão Documentação: 2025-01**  
**Última Atualização: 31-01-2025**  
**Próxima Atualização Completa: 31-01-2026**

---

**Dúvidas ou Sugestões?** Revise respeitando precisão técnica e contexto operacional Brasil 2025.
