@echo off
echo ==========================================
echo RESGATE SOS - NUKE ANDROID ARTIFACTS

echo Removing build and .gradle folders...
for %%A in (mobile_app tv_router wearable_app) do (
    if exist "apps\%%A\build" rmdir /s /q "apps\%%A\build"
    if exist "apps\%%A\android\.gradle" rmdir /s /q "apps\%%A\android\.gradle"
)

echo Done.
pause
