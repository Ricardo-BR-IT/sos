# 07 - SISTEMAS DE ÁUDIO E COMUNICAÇÃO ACÚSTICA

## ÍNDICE
1. VoIP (Voice over IP)
2. Protocolos Áudio Tempo Real
3. Sistemas Ultrassônicos
4. Acústica Comunicação Subaquática
5. Tecnologias de Síntese de Fala (TTS)
6. Reconhecimento Fala (ASR)
7. Sistemas em Desenvolvimento
8. Tendências 2025-2030

---

## 1. VoIP (VOICE OVER IP)

### **Conceito Básico**

VoIP comprime voz para packets IP transmitidos por internet/rede. Elimina necessidade linhas telefônicas dedicadas.

**Vantagens**
- ✅ Custo baixo (vs telefonia tradicional)
- ✅ Mobilidade (qualquer dispositivo internet)
- ✅ Integração dados+voz (convergência)
- ✅ Escalabilidade (nenhum hardware central obrigatório)

**Desvantagens**
- ❌ Latência (vs voz direta ~50ms ideal)
- ❌ Perda packet (vs circuit telefone garantido)
- ❌ Dependência internet (outage = serviço)
- ❌ Qualidade áudio compressão (codec tradeoff)

### **Arquitetura VoIP**

```
Telefone IP/Softphone --- Rede Local (LAN) --- Internet Gateway --- Servidor VoIP --- PSTN/Outro VoIP
                         (Packet Real-time)                       (SIP, H.323)
```

**Fluxo Chamada**
1. Cliente VoIP registra servidor (SIP REGISTER)
2. Cliente inicia chamada (SIP INVITE)
3. Servidor localiza calado (DNS, lookup)
4. Estabelece RTP stream áudio bidirecional
5. Packets áudio comprimidos transmitidos
6. Jitter buffer absorve variação latência
7. Decodificador recupera áudio original

### **Protocolos SIP (Session Initiation Protocol)**

**RFC 3261**
- Método: TEXT-based (vs H.323 binário)
- Portas: 5060 (cleartext), 5061 (TLS)
- Componentes:
  - **User Agents (UA)**: Softphone, telefone IP
  - **Proxy Server**: Rota mensagens SIP
  - **Registrar**: Armazena localização usuários
  - **Location Server**: Database endereços

**Mensagens SIP Principais**
- **REGISTER**: Registra UA com servidor
- **INVITE**: Inicia session
- **ACK**: Confirma 200 OK
- **BYE**: Encerra chamada
- **CANCEL**: Aborta INVITE pendente

**Exemplo SIP INVITE**
```
INVITE sip:usuario@dominio.com SIP/2.0
Via: SIP/2.0/UDP 192.168.1.100:5060
From: <sip:alice@dominio.com>;tag=1928301774
To: <sip:bob@dominio.com>
Call-ID: a84b4c76e66710@pc33
CSeq: 314159 INVITE
Contact: <sip:alice@pc33>
Max-Forwards: 70
```

### **Operadores VoIP Brasil (2025)**

**Redes Privadas**
- Skype/Teams: ✅ Ubíquo (Microsoft)
- Google Meet: ✅ Ubíquo (Chrome, Android)
- WhatsApp: ✅ Ubíquo (Facebook/Meta)
- Telegram: ✅ Crescimento (privacidade foco)

**Serviços Telefônico Profissional**
- Asterisk (open source PBX)
- FreePBX (interface Asterisk)
- 3CX (propriedário, menos caro)
- Cisco, Avaya (enterprise)

**Operadoras Telecom**
- Vivo, TIM, Claro: Serviço VoIP + PSTN híbrido
- Portabilidade: Números fixo portáveis para VoIP

### **Codecs de Áudio VoIP**

| Codec | Taxa | Latência | Qualidade | Uso |
|-------|------|----------|-----------|-----|
| **G.711 (PCM)** | 64 kbps | <5ms | Excelente (telefone) | Padrão legado |
| **G.729** | 8 kbps | ~20ms | Bom | Economia banda |
| **Opus** | 6-510 kbps | <5ms | Excelente | Web moderno (WebRTC) |
| **Speex** | 2-44 kbps | 5-10ms | Bom-excelente | Open source flexível |
| **AMR-WB** | 6.6-23.85 kbps | 20ms | Bom | Mobile padrão |

---

## 2. PROTOCOLOS ÁUDIO TEMPO REAL

### **RTP (Real-Time Transport Protocol) - RFC 3550**

**Função**
- Transport áudio/vídeo em tempo real
- Não garante entrega (UDP-based)
- Adiciona timestamp + sequence numbers

**Header RTP**
```
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|V=2|P|X|  CC   |M|     PT      |       sequence number         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           timestamp                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           synchronization source (SSRC) identifier            |
```

**Campos**
- **V** (Version): Sempre 2
- **PT** (Payload Type): Codec (0=PCM G.711, 8=PCMA, 97=custom)
- **Sequence**: Detecção pacotes perdidos/out-of-order
- **Timestamp**: Sincronização áudio/vídeo
- **SSRC**: Identificador fonte

### **RTCP (Real-Time Control Protocol) - RFC 3550**

**Função**
- Feedback qualidade (jitter, perda packet, RTT)
- Sincronização fontes múltiplas
- Identificação participantes

**Dados RTCP**
- Sender Report: Timestamp RTP, packet count
- Receiver Report: Perda, jitter, atraso
- Source Description: Nome, email usuário
- Goodbye: Sinaliza saída sessão

**Taxa RTCP**
- Típico 5% banda RTP (vs 95% dados)
- Recomendação: Mínimo 50ms entre reports

### **WebRTC (Web Real-Time Communication)**

**Stack**
- Signaling: SIP, XMPP, ou JSON custom
- Media: Opus (audio), VP8/VP9/H.264 (video)
- Transporte: RTP/RTCP + SRTP (encriptado)
- NAT Traversal: STUN, TURN, ICE

**Implementação Navegador**
```javascript
// Solução JavaScript nativa (Chrome, Firefox, Edge)
navigator.mediaDevices.getUserMedia({audio: true, video: true})
  .then(stream => {
    const peerConnection = new RTCPeerConnection();
    peerConnection.addTrack(stream.getAudioTracks()[0], stream);
    // ... SDP oferta, candidatos ICE, etc
  });
```

**WebRTC Brasil (2025)**
- ✅ Suporte navegador: Chrome, Firefox, Edge, Safari parcial
- ✅ Aplicações: Jitsi (open source), Whereby, Jami
- 🔄 Segurança: DTLS-SRTP encriptação obrigatória

---

## 3. SISTEMAS ULTRASSÔNICOS

### **Ultrassom para Comunicação**

**Frequência**: 20 kHz - 200 kHz (acima audição humana)

**Vantagens**
- ✅ Indetectável auditivamente
- ✅ Curto alcance determinístico (privacidade)
- ✅ Atravessa não-metálicos
- ✅ Sem licença frequência

**Desvantagens**
- ❌ Atenuação rápida ar (decaimento quadrático)
- ❌ Taxa bits muito baixa (~1 kbps máximo)
- ❌ Reflexão/eco estruturas
- ❌ Absorção temperatura-dependente

### **Casos Uso Ultrassônico**

**1. Comunicação Próxima (Sub-3m)**
- Smartphone sincronização com smart speaker
- Beamforming direcionado
- Taxa: 100-500 bps típico

**2. Invisível Localização**
- Trilateração ultrassônica indoor
- Acurácia: ±5 cm
- Aplicação: Museus, lojas (tracking sem GPS)

**3. Comunicação Subaquática (vs ar)**
- Frequência: 20-100 kHz (ar vs 50 Hz subaquático)
- Alcance: 1-100 km subaquático (ar impossível)

### **Exemplos Produção**

**Chirp / Google Nearby**
- Usa ultrasssom ~20 kHz para comunicação curta
- Status: ✅ Ativo (Google Pixel, Android apps)
- Caso uso: Ligar Chromecast, smart TV, WiFi connection

**Ultrassonic Modem**
- Frequência: 200 kHz tipicamente
- Taxa: 1-2 kbps
- Aplicação: Comunicação drones aquáticos

---

## 4. ACÚSTICA COMUNICAÇÃO SUBAQUÁTICA

### **Acústica Marinha**

**Propriedades Água**
- Velocidade som: 1.480-1.540 m/s (vs ar 343 m/s)
- Atenuação: Frequência-dependente (40 dB/km @100 kHz vs 2 dB/km @1 kHz)
- Reflexão: Fundo marinho, camada termoclina

**Implicação Comunicação**
- Frequências baixa penetram profundo (LFAS 3-250 Hz)
- Frequências alta alcance curto (ultrassônico kHz)
- Doppler shift significativo (submarines velocidade)

### **Protocolos Subaquáticos**

**ALOHA Subaquática**
- Random access (sem sincronismo)
- Colisão detectada timeout
- Taxa transmissão: 50-500 bps típico

**Frequency Shift Keying (FSK)**
- Modulação: Dois frequências representam bits
- Exemplo: 10 kHz = bit 0, 11 kHz = bit 1
- Robustez: Imunidade ruído melhor vs PSK

**Direct Sequence Spread Spectrum (DSSS)**
- Sequência pseudo-aleatória spread sinal
- Ganho processamento: Decodificador detecta pattern
- Vantagem: Multi-usuário compartilhando banda

### **Operadores Subaquática (Pesquisa)**

**Protótipos Universitários**
- MIT: Comunicação acoustic submarine 10 km alcance
- WHOI (Woods Hole): Deep sea telemetry
- NUS (Singapore): Multi-nó underwater networks

**Militar (EUA, Rússia, China)**
- LFAS (3-250 Hz): Detecção submarines estratégica
- Status: ❌ Controverso (mamífero marinho impacto)
- Alcance: 1.000+ km (vs 30 km ultrassônico)

**Comercial**
- Empresas: Water Linked (drones), Evologics (modems)
- Custo: $10k-100k por modem
- Taxa: 1-13 kbps

---

## 5. TECNOLOGIAS TTS (TEXT-TO-SPEECH)

### **Síntese Fala Tradição**

**Concatenativa**
- Método: Pre-gravado segmentos fala (difonemas)
- Stitching: Concatena segmentos com prosódia
- Qualidade: Naturalidade boa mas robótica
- Latência: <100ms típico

**Paramétrica (Formante)**
- Método: Sintetiza filtros vocais (formantes)
- Baixa overhead: Pode rodar firmware baixa potência
- Qualidade: Robótica óbvia
- Uso legado: Telefones, alarmes

### **Neural TTS (Redes Neurais)**

**2025 Tecnologias Dominante**

**Google Wavenet / Tacotron 2**
- Treinamento: Gravações humano real (centenas horas)
- Taxa bits: Ultra-baixa (eficiente)
- Qualidade: Praticamente indistinguível humano
- Latência: 100-500ms típico (computação neural)
- Uso: Google Assistant, smartphones

**Meta TTS (propriedário)**
- Speedup: Latência <200ms
- Linguagens: 200+ suporte
- Características: Prosódia natural, humor interpretação

**OpenAI Whisper TTS (beta 2025)**
- Baseado Diffusion Model
- Qualidade: Estado arte
- Custo: API comercial (similar Google)
- Características: Voice cloning limitado

**Bark (Suno AI - Open Source)**
- Modelo: Transformador generativo
- Características: Emoção + prozodia controle
- Consumo: GPU 8GB mínimo
- Status: ✅ Open source HuggingFace (Suno)

### **Operadores TTS Brasil (2025)**

**Gratuito**
- Google Tradutor: TTS integrado
- Microsoft Edge: TTS built-in
- OpenAI API: Pay-per-use (barato)
- Bark (local): Download modelo HuggingFace

**Telecom Integrado**
- Vivo, TIM, Claro: IVR (Interactive Voice Response) TTS
- Banco Central: Comunicações automáticas BACEN

---

## 6. RECONHECIMENTO FALA (ASR - AUTOMATED SPEECH RECOGNITION)

### **Tradicional Abordagem HMM**

**Hidden Markov Model**
- Componentes:
  1. **Extrator Acústica**: MFCC (Mel-Frequency Cepstral Coefficients)
  2. **Modelo Linguagem**: N-gramas (bigram, trigram)
  3. **Decodificador**: Viterbi algoritmo max-likelihood
- Taxa acurácia: 80-85% ambientes limpos
- Latência: <100ms CPU moderno

### **Redes Neurais Profundas (2015+)**

**Deep Neural Networks (DNN)**
- Arquitetura: LSTM (Long Short-Term Memory)
- Entrada: MFCC 39-dimensional vectors
- Saída: Probabilidades caractere/fonema
- Taxa acurácia: 95%+ ambiente limpo

**End-to-End (2017+)**
- Arquitetura: Transformer (BERT-based)
- Input: Espectrograma bruto
- Output: Transcrição direto
- Vantagem: Sem necessidade HMM, language model separado

### **Operadores ASR Comercial Brasil (2025)**

**Google Cloud Speech-to-Text**
- ✅ Melhor acurácia português
- ✅ Latência streaming <100ms
- 💰 Custo: $0.06 / 15 segundo (~US$1.44 / hora)
- 🌍 Modelos: Padrão + especializado (telefone, vídeo)

**Azure Speech Services (Microsoft)**
- ✅ Acurácia comparável
- 💰 Preço similar Google
- ✅ Integração Office 365

**AWS Transcribe**
- ✅ Suporte português
- 💰 $0.02 / minuto (mais barato Google 2-3x)
- ⚠️ Acurácia (estudos mostram Google melhor português)

**Open Source**
- **Whisper (OpenAI)**: Multilíngue, robustez ruído (rodar local)
- **Kaldi**: Pesquisa ASR (complexo setup)
- **DeepSpeech (Mozilla)**: Descontinuado 2022 (considerar Whisper)

### **Desafios ASR Português**

**Sotaque Diversos**
- Carioca: Pronúncia vela (~s → sh)
- Mineiro: Entonação sulista
- Nordestino: Paragoge (extra vogal final)
- Modelo padrão: Paulista/RJ urbano
- Acurácia redução: 5-10% vs português padrão

**Ruído Ambiente**
- Trânsito: Reduz acurácia ~20%
- Multi-falante: Diarização difícil
- Telefone: Compressão áudio (3.1 kHz banda)

---

## 7. SISTEMAS EM DESENVOLVIMENTO

### **Voice Activity Detection (VAD) Melhorado**

**Desafio**
- Distinguir fala válida vs respiração, ruído, silêncio
- Particularmente difícil música + fala

**2025 Avanços**
- Transformer-based VAD: >98% acurácia limpas
- On-device inference: Modelos <5MB
- Multi-linguagem: Treino simultâneo 50+ idiomas

### **Conversão Voz (Voice Conversion)**

**Conceito**
- Mudar timbre/voz falante A para falante B
- Mantém conteúdo semântico
- Aplicação: Ator dublagem automática, anonimização

**Status Pesquisa (2025)**
- 🔬 Pré-comercial (prototípos université)
- Desafio: Preservar voz natural (vs robótico)

### **Spatial Audio (3D Áudio)**

**Tecnologia**
- Codificação posição som em espaço 3D
- Formato: Ambisonics, object-based audio (Dolby Atmos)
- Rendering: Processamento real-time usando HRTF (Head-Related Transfer Function)

**Aplicação**
- VR/Metaverse comunicação imersiva
- Podcast 3D
- Gaming multiplayer áudio posicional

**Suporte Brasil (2025)**
- ✅ Suporte parcial: Spotify, Apple Music (Dolby Atmos)
- 🔄 Implementação: Requer hardware Hi-Fi suporte

---

## 8. TENDÊNCIAS 2025-2030

**Curto Prazo (2025)**
- ✅ Neural TTS padrão (abandonar concatenativa)
- ✅ ASR 97%+ acurácia português (Whisper, Google v5)
- 🔄 WebRTC ubíquo comunicação consumer
- 📈 VAD on-device (bateria smartphone)

**Médio Prazo (2026-2027)**
- 🔬 Voice conversion comercial início
- 🔄 Spatial audio streaming serviços
- 📈 VoIP PSTN integração completa operadoras
- ⚠️ Synthetic voice deepfake detecção urgência

**Longo Prazo (2028-2030)**
- 📡 Quantum audio encryption (pós-quantum criptografia)
- 🎯 ASR real-time simultânea 200+ idiomas
- 🔬 Brain-computer interface (BCI) áudio bypass

---

**Documento Versão: 2025-01**
**Próxima atualização: Março 2025**
