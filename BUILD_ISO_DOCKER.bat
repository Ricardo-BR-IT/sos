@echo off
REM ==============================================================================
REM SOS ISO BUILDER — Windows Docker Wrapper
REM ==============================================================================
REM Usage: BUILD_ISO_DOCKER.bat [scout|ranger|omega]
REM
REM Requires: Docker Desktop for Windows
REM Output:   output\sos_<edition>_v0.3.0.iso
REM ==============================================================================

setlocal enabledelayedexpansion

set EDITION=%1
if "%EDITION%"=="" set EDITION=scout

echo.
echo ================================================================
echo   SOS LIVE ISO BUILDER - Docker Mode
echo   Edition: %EDITION%
echo ================================================================
echo.

REM Check Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Create output directory
if not exist "output" mkdir output

REM Build the ISO builder image
echo [1/3] Building Docker image...
docker build -f iso_builder\Dockerfile.iso -t sos-iso-builder . || (
    echo ERROR: Docker image build failed.
    pause
    exit /b 1
)

echo.
echo [2/3] Building SOS %EDITION% ISO inside Docker...
echo This may take 30-60 minutes depending on the edition.
echo.

REM Run the build (--privileged is required for debootstrap/chroot)
docker run --rm --privileged ^
    -v "%cd%":/workspace ^
    -v "%cd%\output":/workspace/output ^
    sos-iso-builder %EDITION%

if errorlevel 1 (
    echo.
    echo ERROR: ISO build failed. Check the output above for details.
    pause
    exit /b 1
)

echo.
echo ================================================================
echo   BUILD COMPLETE
echo   ISO: output\sos_%EDITION%_v0.3.0.iso
echo ================================================================
echo.
echo Flash to USB with:
echo   - Rufus:        https://rufus.ie
echo   - balenaEtcher: https://etcher.balena.io
echo   - Ventoy:       https://ventoy.net
echo.

pause
