@echo off
rem SOS V21 WINDOWS INSTALLER (BAT)
rem Works on Win7/8/10/11
rem Requires: PHP (Manual unzip)

echo ==================================================
echo   SOS PLATFORM V21 - WINDOWS DEPLOYMENT
echo ==================================================

rem Check PHP
where php >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] PHP IS NOT INSTALLED or NOT IN PATH!
    echo Please download PHP 8.2+ and add to PATH.
    echo Exiting...
    pause
    exit /b
)

echo [OK] PHP found.
echo.

rem Install/Copy Files
set "INSTALL_DIR=%USERPROFILE%\sos"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo Copying SOS Core to %INSTALL_DIR%...
robocopy . "%INSTALL_DIR%" /E /XO

rem Setup Database
echo.
echo Initializing Database...
php "%INSTALL_DIR%\setup_database.php"

rem Start Server
echo.
echo ==================================================
echo   SERVER STARTING ON PORT 8080...
echo   Minimize this window to keep running.
echo   Access: http://localhost:8080
echo ==================================================
cd /d "%INSTALL_DIR%"
php -S 0.0.0.0:8080 -t .

pause
