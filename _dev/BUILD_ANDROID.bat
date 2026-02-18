@echo off
setlocal
echo ==========================================
echo RESGATE SOS - ANDROID BUILDER
echo ==========================================

:: FIX PATHS (Adjust if your install location differs)
set "FLUTTER_PATH=C:\Users\ricod\flutter\bin"
set "PUB_CACHE=C:\Users\ricod\AppData\Local\Pub\Cache\bin"
set "PATH=%FLUTTER_PATH%;%PUB_CACHE%;%PATH%"

echo [1/3] Check Environment...
call flutter doctor
if %errorlevel% neq 0 (
    echo [WARNING] Issues detected. If related to licenses, run: flutter doctor --android-licenses
)

echo.
echo [2/3] Fetch dependencies...
cd apps\mobile_app
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] flutter pub get failed.
    pause
    exit /b
)

echo.
echo [3/3] Building APK...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo [ERROR] Build Failed! Ensure Android Studio is installed and configured.
) else (
    echo [SUCCESS] APK created: apps\mobile_app\build\app\outputs\flutter-apk\app-release.apk
)
cd ..\..

pause
