# SOS Live USB - 3 Edições

**Objetivo**: Transformar qualquer PC antigo em um nó de gateway SOS completo.

---

## Edição MINI (512MB - 1GB)
*"O Essencial para Emergências"*

### Especificações
- **Base**: Alpine Linux (Live)
- **Tamanho**: < 500MB (cabe em pendrives antigos)
- **Requisitos**: PC com 256MB RAM, Pentium III ou superior

### Componentes
```
├── Kernel Linux 6.1 LTS (mínimo)
├── JRE Headless (OpenJ9 - menor footprint)
├── SOS JVM Node (Lite Mode)
│   └── Apenas LoRa + LAN Transport
├── dnsmasq (DHCP local)
└── hostapd (Access Point Wi-Fi)
```

### Funcionalidades
- [x] Receber e retransmitir pacotes SOS LoRa
- [x] Criar hotspot Wi-Fi para dispositivos móveis
- [x] Interface CLI mínima
- [ ] Web Dashboard (removido para economia)

### Boot
```bash
# USB detectado automaticamente
# Auto-configura rede e inicia mesh em 30 segundos
```

---

## Edição MEDIA (2GB - 4GB)
*"O Gateway Completo"*

### Especificações
- **Base**: Debian 12 Live (headless)
- **Tamanho**: ~2GB
- **Requisitos**: PC com 1GB RAM, Core 2 Duo ou superior

### Componentes
```
├── Kernel Linux 6.6 LTS (completo)
├── JRE 21 (Oracle GraalVM - performance)
├── SOS JVM Node (Full Mode)
│   ├── LoRa Transport
│   ├── LAN Transport (mDNS Discovery)
│   ├── Serial Transport (USB LoRa bridges)
│   └── Acoustic Modem (experimental)
├── Nginx (Reverse Proxy)
├── Web Dashboard (React SPA)
├── TelemetryDB (SQLite)
└── Watchdog + Auto-recovery
```

### Funcionalidades
- [x] Tudo do MINI
- [x] Web Dashboard completo (porta 80)
- [x] Mapa de calor de alertas
- [x] Log de incidentes com exportação
- [x] Auto-update via mesh (OTA)

---

## Edição SUPER (8GB+)
*"Centro de Comando de Desastres"*

### Especificações
- **Base**: Ubuntu Server 24.04 LTS
- **Tamanho**: ~6GB
- **Requisitos**: PC com 4GB+ RAM, i5 ou superior, SSD recomendado

### Componentes
```
├── Kernel Linux 6.8 (optimizado para rede)
├── Docker + Compose
│   ├── sos-gateway (JVM Node Full)
│   ├── sos-dashboard (React + Vite)
│   ├── sos-telemetry (TimescaleDB)
│   ├── sos-map (Leaflet + OpenStreetMap offline)
│   ├── sos-radio-bridge (SDR Controller)
│   └── sos-iridium-gateway (Satellite Fallback)
├── Grafana (Monitoramento)
├── MQTT Broker (Mosquitto)
├── HAM/APRS Bridge (Dire Wolf)
└── VPN Mesh (WireGuard)
```

### Funcionalidades
- [x] Tudo do MEDIA
- [x] Multi-transporte simultâneo (LoRa + SDR + Satélite)
- [x] Bridge para rádios amadores (APRS)
- [x] Mapas offline de toda a região
- [x] Integração com WhatsApp Business API
- [x] Backup automático para nuvem (quando disponível)
- [x] Suporte para múltiplos operadores simultâneos

---

## Scripts de Build

### build_mini.sh
```bash
#!/bin/bash
# Alpine Linux base
docker build -t sos-usb-mini -f Dockerfile.mini .
dd if=/dev/zero of=sos_mini.img bs=1M count=512
# ... partitioning e syslinux
```

### build_media.sh
```bash
#!/bin/bash
# Debian 12 base with live-build
lb config --distribution bookworm --archive-areas "main contrib"
lb build
```

### build_super.sh
```bash
#!/bin/bash
# Ubuntu 24.04 + Docker preload
# Inclui imagens Docker pré-baixadas no ISO
```

---

## Arquivos para Download (Futuro)

| Edição | Tamanho | Download | Checksum |
|--------|---------|----------|----------|
| MINI   | ~450MB  | [sos_live_mini.iso](#) | SHA256: ... |
| MEDIA  | ~2.1GB  | [sos_live_media.iso](#) | SHA256: ... |
| SUPER  | ~5.8GB  | [sos_live_super.iso](#) | SHA256: ... |

---

## Próximos Passos
1. [ ] Criar Dockerfiles para cada edição
2. [ ] Implementar script de auto-configuração de rede
3. [ ] Testar em hardware real (PC antigo, Raspberry Pi)
4. [ ] Publicar ISOs no GitHub Releases
