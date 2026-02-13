# Plano de Implementacao Global - Resgate SOS

## Objetivo
Entregar uma plataforma offline-first resiliente para comunicacao, coordenacao, assistencia e preparacao comunitaria em crises. O plano cobre todas as tecnologias listadas (atuais + novas), novos recursos do sistema e novas informacoes de preparo.

## Principios
- **Confiabilidade primeiro**: funcionamento local mesmo sem Internet.
- **Seguranca por padrao**: criptografia end-to-end e privacidade minima.
- **Operacao simples**: ativacao rapida, interfaces claras e baixa dependencia.
- **Modularidade**: camadas de transporte e protocolos intercambiaveis.
- **Evolucao continua**: ciclos curtos, testes de campo e melhoria incremental.

## Escopo de Hardware Atual
- **Alvo prioritario**: notebooks e celulares.
- **Possiveis sem hardware extra**: Wi-Fi/LAN, TCP/UDP, BLE discovery, CAP, telemetria local.

## Macro-Fases (roadmap)
### Fase 0 — Fundacao e Qualidade (0-3 meses)
- Estabilizar core mesh, identidade e armazenamentos.
- Padronizar logs, telemetria e diagnosticos offline (telemetria local + API /telemetry implementada).
- **Automação de Build e CI/CD**: GitHub Actions para Android, iOS, Windows, Linux, Web e Java [IMPLEMENTADO].
- **Suporte Multiplataforma**: Estrutura iOS e scripts de build unificados [IMPLEMENTADO].
- Auto-deteccao de hardware via perfil local/ambiente e ativacao automatica de transportes (implementado).
- Definir contratos de transporte (API) com testes automatizados.
- Revisar seguranca basica (seeds, assinaturas, storage) e implementar validação criptográfica real (libsodium).
- Consolidar portal web e assistente offline (dados locais).

### Fase 1 — Resiliencia Basica (3-6 meses)
- Fortalecer Wi-Fi LAN + mDNS/TCP e BLE (implementar handshake e broadcast robusto).
- Implementar cache local robusto para downloads e conteudos.
- Offline-first sync (deduplicacao, TTL, filas).
- **Mapas Offline**: Substituir placeholders por engine de renderização de tiles locais.
- Assistente com playbooks completos (agua, abrigo, energia, saneamento).
- API local e exportacao de incidentes (CSV/JSON).

### Fase 2 — Expansao de Transporte (6-12 meses)
- Bluetooth Classic e Mesh.
- LoRa/LoRaWAN (gateway + node).
- LoRa/LoRaWAN (gateway + node) **[IMPLEMENTADO - TRANSPORTE SERIAL]**.
- Ethernet/PoE e redundancias.
- Gateway radio VHF/UHF (bridging com mesh).
- Ferramentas de configuracao rapida (CLI/GUI).

### Fase 3 — Interoperabilidade e Protocolos (12-18 meses)
- DTN (Bundle Protocol v7 + LTP) para redes intermitentes.
- CAP (Common Alerting Protocol) para alertas estruturados.
- CAP (Common Alerting Protocol) para alertas estruturados **[IMPLEMENTADO - PROTOCOLO]**.
- OSCORE/EDHOC/COSE/CBOR para mensagens leves e seguras.
- WebRTC (audio/dados) quando houver conectividade.
- Integração com plataformas P2P (libp2p/IPFS).

### Fase 4 — Tecnologias Avancadas (18-30 meses)
- 3GPP Sidelink/ProSe (D2D), NTN satelital.
- 6TiSCH / Wi-SUN FAN / HaLow para IoT de longo alcance.
- PLC e enlaces ópticos experimentais.
- Pilotos com radios digitais (TETRA e modos digitais de radioamador).

### Fase 5 — Experimentais & Pesquisa (30+ meses)
- Protocolos e meios experimentais (opticos, acusticos, sat/quantum).
- Sensoriamento e microgrids comunitarias.
- Integração com sistemas de defesa civil e centros de controle.

## Trilhas de Trabalho (detalhe)
### 1) Mesh Core e Segurança
- Verificacao de assinatura e integridade em todos os pacotes.
- Rotas e TTL configuraveis.
- Registro de tecnologias e compatibilidade por plataforma.

### 2) Transportes & Hardware
- Camadas BLE, Wi-Fi LAN, Ethernet e LoRa.
- Drivers e adaptadores por plataforma (Windows, Android, Java node).
- Auto-deteccao de hardware e fallback.

### 3) Protocolos & Interop
- CAP, DTN, libp2p/IPFS, WebRTC.
- Exportacao/importacao em formatos abertos.
- Pontes para radios locais e redes legadas.

### 4) Portal Web Offline
- Conteudos locais de preparacao (playbooks, checklists, guias).
- Downloads organizados por edicao e dispositivo.
- Creditos e fontes oficiais com carimbo de data.

### 5) Assistente Offline (IA minima)
- Playbooks por cenario, recursos e ferimentos.
- Modulo “construcao rapida” (abrigo, agua, saneamento).
- Respostas em linguagem simples com acoes priorizadas.
- Suporte a perguntas (FAQs) por contexto local.

### 6) Operacao, Testes e Qualidade
- Testes de campo (latencia, perda, alcance).
- Testes automatizados por pacote e app.
- **Pipeline de CI/CD**: 7 jobs paralelos e artifacts automáticos [IMPLEMENTADO].
- Metricas de confiabilidade e tempo de resposta.

## Novas Solucoes e Recursos (sugeridos)
- **CAP Local**: emissor/validador de alertas com assinaturas.
- **Registro de recursos**: inventario comunitario (agua, energia, equipamentos).
- **Triage rápido**: formulários simples e exportacao.
- **Plano de evacuacao**: mapa de rotas e pontos de encontro.
- **Microgrid assistida**: calculadora de carga e uso de baterias.
- **Modulo de radio**: configuracao de canais e mensagens padrao.

## Novas Informacoes de Preparacao (sugeridas)
- Rotina de treino comunitario (mensal).
- Lista de contatos externos e pontos de apoio.
- Checklist de saneamento e residuos.
- Plano de suporte a pessoas vulneraveis.
- Documentos e finanças para emergencias.

## Entregaveis Prioritarios
- Portal com conteudo FEMA offline e creditos.
- Assistente com novos playbooks e preparacao ampliada.
- Plano de transporte: BLE + Wi-Fi + Ethernet + LoRa.
- Roadmap tecnico por tecnologia e custos estimados.

## Indicadores de Sucesso
- Tempo de ativacao do no servidor < 5 min.
- 95% de entrega de mensagens em rede local.
- Operacao offline completa com portal e assistente.
- Atualizacao de conteudos em 1 clique (deploy).

## Governanca e Creditos
Conteudos oficiais devem manter data de origem e creditos. Materiais governamentais geralmente sao de dominio publico, mas pode haver excecoes com creditos especificos.
