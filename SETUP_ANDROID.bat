@echo off
echo ==========================================
echo RESGATE SOS - ANDROID SETUP
echo ==========================================

set "FLUTTER_PATH=C:\Users\ricod\flutter\bin"
set "PATH=%FLUTTER_PATH%;%PATH%"

call flutter doctor
call flutter doctor --android-licenses

echo.
echo Setup completed.
pause
