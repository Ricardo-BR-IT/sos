@echo off
setlocal
echo ==========================================
echo RESGATE SOS - iOS SETUP TOOL
echo ==========================================

set "FLUTTER_PATH=C:\Users\ricod\flutter\bin"
set "PATH=%FLUTTER_PATH%;%PATH%"

for %%A in (mobile_app tv_router wearable_app) do (
    if not exist "apps\%%A\ios" (
        echo Creating iOS structure for %%A...
        pushd "apps\%%A"
        call flutter create --platforms=ios .
        popd
    ) else (
        echo iOS structure already exists for %%A.
    )
)

echo.
echo ==========================================
echo iOS SETUP COMPLETED
echo ==========================================

pause
