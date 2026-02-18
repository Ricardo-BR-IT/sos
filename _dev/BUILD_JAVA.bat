@echo off
echo ==========================================
echo RESGATE SOS - JAVA BUILDER (MINI/STANDARD/SERVER)
echo ==========================================

if not exist "java\settings.gradle" (
    echo [ERRO] pasta java nao encontrada.
    pause
    exit /b
)

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Java nao encontrado!
    echo Instale JDK 17+: https://adoptium.net/
    pause
    exit /b
)

echo [1/3] Verificando ambiente...
java -version

echo.
echo [2/3] Compilando com Gradle...
cd java

if exist "gradlew.bat" (
    call gradlew.bat :mini:build :standard:build :server:build
) else if exist "%JAVA_HOME%\\bin\\javac.exe" (
    echo [AVISO] Gradle nao encontrado, usando javac direto
    powershell -NoProfile -ExecutionPolicy Bypass -File "..\\scripts\\build_java.ps1"
) else (
    echo [AVISO] Gradle wrapper nao encontrado, usando Gradle global
    call gradle :mini:build :standard:build :server:build
)

if %errorlevel% neq 0 (
    echo [ERRO] Build falhou!
    pause
    exit /b
)

echo.
echo [3/3] JARs gerados:
dir mini\build\libs\*.jar
dir standard\build\libs\*.jar
dir server\build\libs\*.jar

cd ..\..

echo.
echo ==========================================
echo [SUCCESS] Build Java Completo!
echo ==========================================
pause
