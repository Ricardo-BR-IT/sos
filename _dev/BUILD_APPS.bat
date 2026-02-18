@echo off
echo 🚀 [MODO AGENTES ATIVOS] INICIANDO BUILD PARALELO
set "FLUTTER_PATH=C:\Users\ricod\flutter\bin"
set "PUB_CACHE=C:\Users\ricod\AppData\Local\Pub\Cache\bin"
set "PATH=%FLUTTER_PATH%;%PUB_CACHE%;%PATH%"
python -u scripts\build_apps.py
if %errorlevel% neq 0 (
    echo ❌ Falha no build.
    exit /b 1
)
echo 🎉 Build concluido!
pause