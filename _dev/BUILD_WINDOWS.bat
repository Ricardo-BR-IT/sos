@echo off
setlocal
echo ==========================================
echo RESGATE SOS - WINDOWS BUILDER
echo ==========================================

set "FLUTTER_PATH=C:\Users\ricod\flutter\bin"
set "PUB_CACHE=C:\Users\ricod\AppData\Local\Pub\Cache\bin"
set "PATH=%FLUTTER_PATH%;%PUB_CACHE%;%PATH%"

echo [1/3] Verifying Flutter...
call flutter --version
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found in %FLUTTER_PATH%
    pause
    exit /b
)

echo.
echo [2/3] Fetching dependencies...
cd apps\desktop_station
call flutter pub get

echo.
echo [3/3] Building Windows Release...
call flutter config --enable-windows-desktop
call flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERROR] Windows build failed.
) else (
    echo [SUCCESS] EXE created at: apps\desktop_station\build\windows\x64\runner\Release\desktop_station.exe
)
cd ..\..

pause
