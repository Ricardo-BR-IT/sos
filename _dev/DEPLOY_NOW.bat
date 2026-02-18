@echo off
setlocal
if "%FTP_USER%"=="" set "FTP_USER=mentales"
if "%FTP_PASS%"=="" set "FTP_PASS=4dSeA.3g0E6R(z"
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
echo Running remote backup ...
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\ftp_backup.ps1"
if %errorlevel% neq 0 (
    echo [ERROR] Remote backup failed.
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
