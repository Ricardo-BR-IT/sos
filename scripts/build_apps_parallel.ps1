param(
    [string[]]$Editions = @("mini", "standard", "server"),
    [string]$FlutterBin = "C:\Users\ricod\flutter\bin"
)

$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$apps = @("mobile_app", "desktop_station", "tv_router", "wearable_app")
$artifactRoot = Join-Path $root "build_artifacts"

if (Test-Path $FlutterBin) {
    $env:PATH = "$FlutterBin;$env:PATH"
}

function Clear-DesktopEphemeral {
    param([string]$AppDir)
    $ephemeral = Join-Path $AppDir "windows\flutter\ephemeral\.plugin_symlinks"
    if (Test-Path $ephemeral) {
        try {
            Remove-Item -Recurse -Force $ephemeral
        } catch {
            Write-Host "Aviso: nao foi possivel limpar $ephemeral" -ForegroundColor Yellow
        }
    }
}

function Copy-Artifact {
    param(
        [string]$App,
        [string]$Edition,
        [string]$RootDir
    )

    $dstDir = Join-Path $artifactRoot $Edition
    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

    switch ($App) {
        "mobile_app" {
            $src = Join-Path $RootDir "apps\mobile_app\build\app\outputs\flutter-apk\app-release.apk"
            $dst = Join-Path $dstDir "mobile-$Edition.apk"
        }
        "tv_router" {
            $src = Join-Path $RootDir "apps\tv_router\build\app\outputs\flutter-apk\app-release.apk"
            $dst = Join-Path $dstDir "tv-$Edition.apk"
        }
        "wearable_app" {
            $src = Join-Path $RootDir "apps\wearable_app\build\app\outputs\flutter-apk\app-release.apk"
            $dst = Join-Path $dstDir "wear-$Edition.apk"
        }
        "desktop_station" {
            $src = Join-Path $RootDir "apps\desktop_station\build\windows\x64\runner\Release\desktop_station.exe"
            $dst = Join-Path $dstDir "desktop-$Edition.exe"
        }
        default { return }
    }

    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "Artifact: $dst"
    } else {
        throw "Artifact not found: $src"
    }
}

Write-Host "Build paralelo por edicao (sem corrida de artefatos)" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null

foreach ($edition in $Editions) {
    Write-Host "`n=== EDICAO: $edition ===" -ForegroundColor Yellow
    $jobs = @()

    foreach ($app in $apps) {
        $jobs += Start-Job -Name "Build-$app-$edition" -ScriptBlock {
            param($a, $e, $cwd, $flutterBin)
            $env:PATH = "$flutterBin;$env:PATH"
            Set-Location "$cwd\apps\$a"

            if ($a -eq "desktop_station") {
                $ephemeral = Join-Path (Get-Location) "windows\flutter\ephemeral\.plugin_symlinks"
                if (Test-Path $ephemeral) {
                    Remove-Item -Recurse -Force $ephemeral -ErrorAction SilentlyContinue
                }
            }

            & flutter.bat pub get
            if ($LASTEXITCODE -ne 0) { throw "pub get failed for $a ($e)" }

            if ($a -eq "desktop_station") {
                & flutter.bat build windows --release --dart-define=EDITION=$e --no-pub
            } else {
                & flutter.bat build apk --release --dart-define=EDITION=$e --no-pub
            }
            if ($LASTEXITCODE -ne 0) { throw "build failed for $a ($e)" }
        } -ArgumentList $app, $edition, $root, $FlutterBin
    }

    $jobs | Wait-Job | Receive-Job
    $failed = $jobs | Where-Object { $_.State -eq "Failed" }
    if ($failed.Count -gt 0) {
        throw "Falha detectada na edicao $edition"
    }

    foreach ($app in $apps) {
        Copy-Artifact -App $app -Edition $edition -RootDir $root
    }
}

Write-Host "`nBuilds finalizados com sucesso. Artefatos em: $artifactRoot" -ForegroundColor Green
