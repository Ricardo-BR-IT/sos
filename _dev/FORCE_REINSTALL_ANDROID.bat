@echo off
echo ==========================================
echo RESGATE SOS - FORCE REINSTALL ANDROID

echo Cleaning build artifacts...
for %%A in (mobile_app tv_router wearable_app) do (
    if exist "apps\%%A" (
        pushd "apps\%%A"
        call flutter clean
        popd
    )
)

echo Done.
pause
