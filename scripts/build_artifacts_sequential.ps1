$ErrorActionPreference = 'Stop'
$env:PATH = 'C:\Users\ricod\flutter\bin;' + $env:PATH
$root = 'c:\site\mentalesaude\www\ricardo\sos'
$artifactRoot = Join-Path $root 'build_artifacts'

if (Test-Path $artifactRoot) {
  Remove-Item -Recurse -Force $artifactRoot
}
New-Item -ItemType Directory -Path $artifactRoot | Out-Null

$editions = @('mini', 'standard', 'server')
$apps = @('mobile_app', 'tv_router', 'wearable_app', 'desktop_station')

foreach ($ed in $editions) {
  $edDir = Join-Path $artifactRoot $ed
  New-Item -ItemType Directory -Path $edDir | Out-Null
  Write-Host "`n=== EDITION $ed ===" -ForegroundColor Yellow

  foreach ($app in $apps) {
    $appDir = Join-Path $root "apps\$app"
    Set-Location $appDir
    Write-Host "Building $app ($ed)" -ForegroundColor Cyan

    # Clean transient outputs to avoid Windows file locks in Gradle/MSBuild.
    Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    if (Test-Path 'build') { cmd /c rmdir /s /q build }
    if (Test-Path '.dart_tool\\flutter_build') { cmd /c rmdir /s /q .dart_tool\\flutter_build }

    flutter pub get | Out-Host

    if ($app -eq 'desktop_station') {
      if (Test-Path 'windows\flutter\ephemeral\.plugin_symlinks') {
        cmd /c rmdir /s /q windows\flutter\ephemeral\.plugin_symlinks
      }

      flutter build windows --release --dart-define=EDITION=$ed
      if ($LASTEXITCODE -ne 0) { throw "Build failed: $app/$ed" }

      Copy-Item 'build\windows\x64\runner\Release\desktop_station.exe' (Join-Path $edDir "desktop-$ed.exe") -Force
    } else {
      flutter build apk --release --dart-define=EDITION=$ed
      if ($LASTEXITCODE -ne 0) { throw "Build failed: $app/$ed" }

      $name = switch ($app) {
        'mobile_app' { "mobile-$ed.apk" }
        'tv_router' { "tv-$ed.apk" }
        'wearable_app' { "wear-$ed.apk" }
      }
      Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' (Join-Path $edDir $name) -Force
    }
  }
}

Write-Host "Artifacts ready at $artifactRoot" -ForegroundColor Green
