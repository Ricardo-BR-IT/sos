# Resgate SOS Monorepo

## Overview

Resgate SOS is an open‑source, offline‑first, privacy‑preserving, modular ecosystem for digital survival communication. It consists of a **Dart/Flutter** workspace managed by **Melos** and a **JavaScript** workspace managed by **Turborepo**.

- **Core packages** (`sos_kernel`, `sos_transports`, `sos_vault`, `sos_mapper`, `sos_ui`) provide cryptography, mesh networking, secure storage, offline maps, and a design system.
- **Apps** include:
  - `mobile_app` (Flutter Android/iOS)
  - `desktop_station` (Flutter Windows/Linux/macOS with USB/LoRa drivers)
  - `tv_router` (Flutter Android TV kiosk mode)
  - `web_portal` (Next.js 15 static export, PWA, Tor Onion service)
- **Config** contains Tor hidden‑service configuration.

The repository is ready for `melos bootstrap` and `npx turbo run build`.
