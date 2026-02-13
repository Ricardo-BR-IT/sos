@echo off
setlocal
echo ==========================================
echo RESGATE SOS - INSTALL ON IPHONE (INFO)
echo ==========================================

echo This app requires a signed .ipa generated on macOS or GitHub Actions.
echo Recommended options:
echo   1. AltStore (Windows/Mac)
echo   2. Sideloadly (Windows/Mac)
echo.
echo After installing:
echo   Ajustes > Geral > VPN e Gerenciamento de Dispositivos > Confiar

echo Press any key to open AltStore site...
pause >nul
start "" "https://altstore.io/"
