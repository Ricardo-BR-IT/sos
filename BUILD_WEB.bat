@echo off
echo ==========================================
echo RESGATE SOS - WEB BUILDER (3 EDICOES)
echo ==========================================

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org/
    pause
    exit /b
)

echo [1/3] Verificando ambiente...
node --version
npm --version

echo.
echo [2/3] Instalando dependencias...
cd apps\web_portal
call npm install
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao instalar dependencias!
    pause
    exit /b
)

set "EDITIONS=mini standard server"

for %%E in (%EDITIONS%) do (
    echo.
    echo [3/3] Compilando Next.js - Edicao %%E...
    set "NEXT_PUBLIC_EDITION=%%E"
    call npm run build
    if %errorlevel% neq 0 (
        echo [ERRO] Build falhou!
        pause
        exit /b
    )
    if exist "out-%%E" rmdir /S /Q "out-%%E"
    xcopy /E /I /Y "out" "out-%%E" >nul
)

cd ..\..

echo.
echo ==========================================
echo [SUCCESS] Build Web Completo!
echo ==========================================
echo Arquivos gerados em apps\web_portal\out-*
pause
