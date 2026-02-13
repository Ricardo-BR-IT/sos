# 📱 Build iOS (Resumo)

Este projeto pode gerar `.ipa` apenas em macOS com Xcode.

## Passos (macOS)
1. Instale Flutter + Xcode.
2. Rode `SETUP_IOS.bat` (ou `flutter create --platforms=ios .` em cada app).
3. `flutter build ipa` em `apps/mobile_app`.

## Instalação no iPhone
- AltStore ou Sideloadly.
- Em seguida: Ajustes > Geral > VPN e Gerenciamento de Dispositivos > Confiar.

---

Se quiser, posso preparar um workflow de GitHub Actions para gerar o `.ipa`.
