@echo off
setlocal
echo ===================================================
echo     RESGATE SOS - AUTOMATED DEPLOYMENT TOOL
echo ===================================================
echo.
echo Preparing deploy_stage ...
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\prepare_deploy.ps1"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to prepare deploy_stage.
    pause
    exit /b
)
echo.
echo Uploading deploy_stage to mentalesaude.com.br/public_html/ricardo/sos ...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\ftp_upload.ps1"

if %errorlevel% neq 0 (
    echo [ERROR] Deployment failed.
) else (
    echo [SUCCESS] Deployment completed.
)

echo.
echo ===================================================
echo     DEPLOYMENT COMPLETED
echo ===================================================
echo.
pause
