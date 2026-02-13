
param(
    [string[]]$Editions = @("mini", "standard", "server")
)

Write-Host "🚀 [MODO AGENTES ATIVOS] INICIANDO BUILD PARALELO DE TODOS OS APPS" -ForegroundColor Cyan
Write-Host "---------------------------------------------------------------"

$apps = @("mobile_app", "desktop_station", "tv_router", "wearable_app")
$jobs = @()

foreach ($edition in $Editions) {
    Write-Host "`n📦 Compilando Edicao: $edition (Agentes em paralelo)" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------"
    
    foreach ($app in $apps) {
        $jobName = "Build-$app-$edition"
        $jobs += Start-Job -Name $jobName -ScriptBlock {
            param($a, $e, $cwd)
            $startTime = Get-Date
            Write-Host "[AGENTE-$a] Iniciando build de $a ($e)..." -ForegroundColor Cyan
            
            try {
                Set-Location "$cwd/apps/$a"
                
                if ($a -eq 'desktop_station') {
                     # Windows build
                     cmd /c "flutter build windows --release --dart-define=EDITION=$e --no-pub"
                } else {
                     # Android APK build
                     cmd /c "flutter build apk --release --dart-define=EDITION=$e --no-pub"
                }
                
                if ($LASTEXITCODE -ne 0) { throw "Build failed with exit code $LASTEXITCODE" }

                $duration = (Get-Date) - $startTime
                Write-Host "[AGENTE-$a] Concluido em $($duration.Seconds)s!" -ForegroundColor Green
            } catch {
                Write-Host "[AGENTE-$a] ERRO CRITICO: $_" -ForegroundColor Red
                throw $_
            }
        } -ArgumentList $app, $edition, $PWD
    }
}

Write-Host "Aguardando sincronizacao dos agentes..." -ForegroundColor Yellow
$jobs | Wait-Job | Receive-Job
$failed = $jobs | Where-Object { $_.State -eq 'Failed' }

if ($failed) {
    Write-Host "Falha detectada em um ou mais agentes!" -ForegroundColor Red
    exit 1
}

Write-Host "Sincronizacao concluida com sucesso!" -ForegroundColor Green

# Organize artifacts
Write-Host "`n📂 Organizando artefatos..."
New-Item -ItemType Directory -Force -Path "deploy_stage" | Out-Null

foreach ($edition in $Editions) {
    $targetDir = "deploy_stage/$edition"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    
    # Copy artifacts
    # Android
    if (Test-Path "apps/mobile_app/build/app/outputs/flutter-apk/app-release.apk") {
        Copy-Item "apps/mobile_app/build/app/outputs/flutter-apk/app-release.apk" "$targetDir/mobile-$edition.apk" -Force
    }
    # TV
    if (Test-Path "apps/tv_router/build/app/outputs/flutter-apk/app-release.apk") {
        Copy-Item "apps/tv_router/build/app/outputs/flutter-apk/app-release.apk" "$targetDir/tv-$edition.apk" -Force
    }
    # Wear
    if (Test-Path "apps/wearable_app/build/app/outputs/flutter-apk/app-release.apk") {
        Copy-Item "apps/wearable_app/build/app/outputs/flutter-apk/app-release.apk" "$targetDir/wear-$edition.apk" -Force
    }
    # Windows
    if (Test-Path "apps/desktop_station/build/windows/x64/runner/Release/desktop_station.exe") {
        Copy-Item "apps/desktop_station/build/windows/x64/runner/Release/desktop_station.exe" "$targetDir/desktop-$edition.exe" -Force
    }
}

Write-Host "`n🎉 OPERACAO CONCLUIDA!" -ForegroundColor Green
