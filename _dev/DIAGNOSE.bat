@echo off
echo ==========================================
echo FLUTTER ENVIRONMENT DIAGNOSIS
echo ==========================================

set "PATH=C:\Users\ricod\flutter\bin;%PATH%"

echo Running 'flutter doctor'...
echo This will check for Android SDK, Visual Studio, and other tools.
echo.

call flutter doctor

echo.
echo ==========================================
echo DIAGNOSIS COMPLETED
echo ==========================================
echo Please share the output above with the assistant (Screenshot or Copy/Paste).
pause
