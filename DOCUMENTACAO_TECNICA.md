# Resgate SOS - Documentacao Tecnica (Detalhada)

Este documento descreve o projeto Resgate SOS conforme o estado atual do repositorio em `C:/site/mentalesaude/www/ricardo/sos`.

**Resumo rapido**
- Monorepo offline-first para comunicacao critica em cenarios sem Internet.
- Apps em Flutter (mobile, desktop, TV, wearables).
- Portal web em Next.js com export estatico.
- Pacotes core para identidade criptografica, transporte local, armazenamento e UI.

**Mapa de modulos (alto nivel)**
```
Apps (Flutter)
  mobile_app -----> sos_kernel
  desktop_station -> sos_kernel
  tv_router ------> sos_kernel
  wearable_app ---> sos_kernel
  mobile_app -----> sos_ui
  desktop_station -> sos_ui
  tv_router ------> sos_ui
  wearable_app ---> sos_ui
  mobile_app -----> sos_transports
  mobile_app -----> sos_calls

Core Packages
  sos_kernel -----> CryptoManager (libsodium + secure storage)
  sos_kernel -----> MeshService (envelopes assinados + peers)
  sos_kernel -----> TechRegistry (todas tecnologias/protocolos listados)
  sos_transports -> BLE (flutter_blue_plus)
  sos_transports -> WiFi mDNS + TCP (bonsoir + sockets)
  sos_vault ------> Drift + SQLite
  sos_mapper -----> utilitarios offline (Haversine)
  sos_calls ------> sinalizacao de chamadas via mesh

Web
  web_portal (Next.js) -> downloads estaticos
  legacy_terminal (HTML PWA)

Java
  java/core ----> Mesh + Crypto + mDNS/TCP
  java/mini ----> Edicao leve (CLI)
  java/standard -> Edicao normal (CLI interativo)
  java/server --> Edicao completa (HTTP API + portal local)
```

**Estrutura do repositorio**
- `apps/` contem todos os aplicativos finais.
- `packages/` contem os modulos compartilhados (kernel, transports, vault, ui, calls, mapper).
- `melos.yaml` registra `packages/*` e `apps/*` como workspace.
- `turbo.json` define pipeline JS para o portal web.

**Pacotes core**

**sos_kernel**
- Responsavel por identidade e bootstrap criptografico.
- Classe principal: `SosCore` em `packages/sos_kernel/lib/sos_kernel.dart`.
- Criptografia: `CryptoManager` em `packages/sos_kernel/lib/identity/crypto_manager.dart`.
- Identidade persistida via `FlutterSecureStorage` com seed de Ed25519 (libsodium).
- Fluxo: `SosCore.initialize()` -> `CryptoManager.initialize()` -> carrega seed ou gera nova -> publica chave publica.
- Mesh promiscuo: `SosFrame` (TTL/hops) + `MeshService` encaminham pacotes verificados sem depender de IP.
- Registro de tecnologias: `TechRegistry` e `TECNOLOGIAS_MAPEAMENTO.md`.
- Cobertura por plataforma: `TechCoverageService` (binding nativo/gateway/indisponivel).
- Diagnostico de campo: `MeshDiagnostics` (ping/pong por transporte).

**sos_transports**
- Define a abstracao `TransportLayer` em `packages/sos_transports/lib/transport/transport_layer.dart`.
- Implementacoes atuais:
  - BLE com `flutter_blue_plus`: `packages/sos_transports/lib/transport/ble_transport.dart`.
  - WiFi mDNS com `bonsoir` + TCP: `packages/sos_transports/lib/transport/wifi_direct_transport.dart`.
  - UDP broadcast LAN: `packages/sos_transports/lib/transport/udp_transport.dart`.
  - MQTT brokered transport: `packages/sos_transports/lib/transport/mqtt_transport.dart`.
  - Orquestrador com fallback + merge de streams: `packages/sos_transports/lib/transport/hybrid_transport.dart`.
  - Stubs (planejados) para cobertura maxima: LoRaWAN, Sat D2D, Optical, Acoustic, Bluetooth Classic/Mesh, Ethernet.
- Metadados de transporte: `TransportDescriptor`, `TransportHealth`, `TransportPacket`.
- Registro e cobertura: `TransportRegistry` + `HybridTransport.maxCoverage()` para expansao total.

**sos_vault**
- Armazenamento local por chunks e banco Drift.
- Chunking: `packages/sos_vault/lib/chunked_storage.dart`.
- Banco: `packages/sos_vault/lib/db/vault_database.dart`.
- Validacao criptografica real (libsodium) em `packages/sos_vault/lib/validation.dart`.

**sos_ui**
- UI compartilhada.
- Botao principal: `packages/sos_ui/lib/widgets/big_red_button.dart`.

**sos_calls**
- Sinalizacao de chamadas via mesh (invite/accept/reject/end).
- `CallSignaling` e `CallScreen` em `packages/sos_calls/lib/sos_calls.dart`.
- Negociacao de midia (webrtc/low_bitrate/signaling) adicionada; midia real ainda nao integrada.

**sos_mapper**
- Utilitarios offline (Haversine + formatacao) em `packages/sos_mapper/lib/mapper/offline_map.dart`.
- Cache de tiles offline e manifesto: `packages/sos_mapper/lib/mapper/offline_tile_cache.dart`.

**Aplicativos**

**mobile_app**
- Arquivo principal: `apps/mobile_app/lib/main.dart`.
- Inicializa `SosCore` e mostra status.
- Exibe `BigRedButton`.
- Inicia `HybridTransport` e abre `CallScreen` como demo.
- Internacionalizacao: `apps/mobile_app/lib/l10n/`.

**desktop_station**
- Arquivo principal: `apps/desktop_station/lib/main.dart`.
- UI semelhante ao mobile para uso como estacao central.
- Internacionalizacao ampliada.

**tv_router**
- Arquivo principal: `apps/tv_router/lib/main.dart`.
- UI simples para uso em Android TV/kiosk.

**wearable_app**
- Arquivo principal: `apps/wearable_app/lib/main.dart`.
- UI minimalista com botao SOS.

**web_portal**
- `apps/web_portal/pages/index.js`.
- Next.js 15 com `output: 'export'`.
- Downloads estaticos em `apps/web_portal/public/downloads/`.
- Export estatico em `apps/web_portal/out/`.
- Portal local detalhado com assistente offline e playbooks.
- Inclui codigos foneticos, protocolos de comunicacao e preparacao para crises.

**legacy_terminal**
- PWA simples em `apps/legacy_terminal/index.html`.
- Usa geolocalizacao e service worker.

**Fluxos principais (detalhe)**

**1) Boot da identidade**
- App chama `SosCore.initialize()`.
- `CryptoManager` inicializa libsodium.
- Se existir seed em secure storage, reconstroi a chave.
- Se nao existir, gera seed, salva e cria `KeyPair`.

**2) SOS local (UI)**
- `BigRedButton` dispara broadcast SOS assinado.
- `MeshService` cria envelope, assina e envia via transportes.

**3) Descoberta e transporte**
- BLE: scan por `MESH_SERVICE_UUID`.
- WiFi: publica e descobre servico `_sos-mesh._tcp` com `bonsoir` e abre TCP na porta 4000.
- Hybrid: faz broadcast por todas as camadas disponiveis e mescla streams.
- Mesh: encaminhamento promiscuo (flooding) com TTL e deduplicacao.
- Diagnostico: `MeshDiagnostics` envia `diag_ping` por transporte para medir RTT.

**4) Armazenamento offline**
- Arquivos sao quebrados em chunks com hash SHA-256.
- Metadados e chunks entram no SQLite via Drift.
- Validacao de assinatura usa libsodium (Ed25519).

**5) Assistente offline (IA minima)**
- Disponivel no Java Server em `/assistant` e `/assistant/catalog`.
- Baseado em regras e playbooks locais (sem nuvem).
- Entrega prioridades, seguranca, coordenacao e primeiros socorros.

**6) Telemetria offline**
- Telemetria local por app (JSONL em `sos_telemetry/`), retencao padrao 7 dias.
- Endpoints no Java Server: `/telemetry` (GET/POST), `/telemetry/summary`, `/telemetry/export`.
- Configuracao: `SOS_TELEMETRY_ENDPOINT` (apps), `SOS_TELEMETRY_RETENTION_DAYS` e `SOS_DATA_DIR` (server).

**7) Perfil de hardware e auto-deteccao**
- `HardwareProfile.detect()` consolida interfaces, variaveis de ambiente e arquivo local.
- Variaveis: `SOS_HARDWARE_FLAGS` (lista simples) e `SOS_HARDWARE_PROFILE` (caminho JSON).
- Exemplo: `config/hardware_profile.sample.json`.
- Java Server expõe `/hardware` com o perfil detectado.

**8) Camada de protocolos**
- `ProtocolRegistry` lista adaptadores para protocolos (CAP, HTTP/JSON e stubs para demais).
- CAP implementado com `CapProtocolAdapter` (XML).
- Protocolos restantes seguem como stubs aguardando integrações reais.

**9) MQTT & CoAP**
- Java Server inicia broker MQTT embutido (Moquette) em `SOS_MQTT_PORT` (padrao 1883).
- CoAP server local em `SOS_COAP_PORT` (padrao 5683) com recursos `status` e `broadcast`.
- Transporte MQTT nos apps usa `SOS_MQTT_HOST`, `SOS_MQTT_PORT` e `SOS_MQTT_TOPIC`.

**Seguranca e privacidade**
- Identidade baseada em Ed25519 com `libsodium`.
- Seeds sao persistidos localmente no secure storage.
- Validacao criptografica de dados ainda precisa ser implementada no `sos_vault/validation`.

**Build e deploy**
- Scripts utilitarios na raiz: `BUILD_APPS.bat`, `BUILD_WEB.bat`, `BUILD_WINDOWS.bat`, etc.
- Builds agora suportam 3 edicoes: `mini`, `standard`, `server` via `--dart-define=EDITION=...`.
- Deploy FTP via `scripts/ftp_upload.ps1`, chamado por `DEPLOY_NOW.bat`.
- Portal web exportado para `apps/web_portal/out/`.
- Java Server pode servir o portal local via `--web-root` ou `SOS_WEB_ROOT`.

**Artefatos gerados (padrao)**
- Mobile APK: `apps/mobile_app/build/app/outputs/flutter-apk/app-release.apk`.
- TV APK: `apps/tv_router/build/app/outputs/flutter-apk/app-release.apk`.
- Wear APK: `apps/wearable_app/build/app/outputs/flutter-apk/app-release.apk`.
- Windows EXE: `apps/desktop_station/build/windows/x64/runner/Release/desktop_station.exe`.

**Limitacoes atuais**
- Chamada segura ainda e apenas sinalizacao (sem audio/video real).
- Suporte a LoRa/Acoustic/LED ainda nao implementado.
- Mapa offline ainda nao renderiza tiles (apenas utilitarios).
- Diagnosticos de alcance/throughput dependem de sensores/hardware externo.
- Assistente offline e baseado em regras, nao substitui socorristas.

**Mapa completo de tecnologias**
- Consulte `TECNOLOGIAS_MAPEAMENTO.md` para a lista completa (status por tecnologia).

**Proximos passos tecnicos sugeridos**
- Implementar protocolo real de broadcast e handshake em `sos_transports`.
- Integrar WebRTC em `sos_calls` (sinalizacao via mesh).
- Implementar validacao criptografica real no `sos_vault`.
- Substituir placeholders em `sos_mapper` por engine de mapas offline real.
