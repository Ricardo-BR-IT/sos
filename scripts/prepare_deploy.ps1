param(
  [string]$Root = "C:\site\mentalesaude\www\ricardo\sos"
)

$ErrorActionPreference = "Stop"

$deploy = Join-Path $Root "deploy_stage"
$artifactRoot = Join-Path $Root "build_artifacts"
$downloadsRoot = Join-Path $deploy "downloads"

function Ensure-Dir([string]$path) {
  New-Item -ItemType Directory -Force -Path $path | Out-Null
}

function Copy-IfExists([string]$source, [string]$destination) {
  if (Test-Path $source) {
    Copy-Item -Recurse -Force $source $destination
  }
}

function Build-Manifest([string]$downloadsPath) {
  $items = @()
  if (Test-Path $downloadsPath) {
    Get-ChildItem -Path $downloadsPath -File -Recurse | ForEach-Object {
      $hash = Get-FileHash -Path $_.FullName -Algorithm SHA256
      $relative = $_.FullName.Substring($downloadsPath.Length).TrimStart('\')
      $items += [PSCustomObject]@{
        path = $relative.Replace('\', '/')
        size = $_.Length
        sha256 = $hash.Hash.ToLowerInvariant()
        updatedAt = $_.LastWriteTimeUtc.ToString("o")
      }
    }
  }

  $manifest = [PSCustomObject]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    source = "prepare_deploy.ps1"
    artifactCount = $items.Count
    artifacts = $items
  }

  $manifestPath = Join-Path $downloadsPath "manifest.json"
  $manifest | ConvertTo-Json -Depth 8 | Set-Content -Path $manifestPath -Encoding UTF8
}

if (Test-Path $deploy) {
  Remove-Item -Recurse -Force $deploy
}
Ensure-Dir $deploy

$rootFiles = @(
  "index.php",
  "prep.php",
  "monitor.php",
  "matrix.php",
  "profile.php",
  "firmware.php",
  "versions.php",
  "upgrade.php",
  "setup_v7.php",
  "setup_tracking.php",
  "manifest.json",
  "sw.js",
  "check.html",
  "test.txt"
)

foreach ($file in $rootFiles) {
  $src = Join-Path $Root $file
  if (Test-Path $src) {
    Copy-Item -Force $src $deploy
  }
}

$rootDirs = @("api", "assets", "includes", "builds", "scripts", "docs")
foreach ($dir in $rootDirs) {
  $srcDir = Join-Path $Root $dir
  $dstDir = Join-Path $deploy $dir
  Copy-IfExists $srcDir $dstDir
}

Ensure-Dir $downloadsRoot

# App artifacts by edition
if (Test-Path $artifactRoot) {
  Get-ChildItem -Path $artifactRoot -Directory | ForEach-Object {
    $edition = $_.Name
    $dstEdition = Join-Path $downloadsRoot $edition
    Ensure-Dir $dstEdition
    Copy-Item -Recurse -Force (Join-Path $_.FullName "*") $dstEdition
  }
}

# Java artifacts
$javaDist = Join-Path $Root "java\dist"
if (Test-Path $javaDist) {
  $javaDst = Join-Path $downloadsRoot "java"
  Ensure-Dir $javaDst
  Get-ChildItem -Path $javaDist -File -Filter *.jar | ForEach-Object {
    Copy-Item -Force $_.FullName (Join-Path $javaDst $_.Name)
  }
}

Build-Manifest -downloadsPath $downloadsRoot
Write-Host "deploy_stage prepared at $deploy"
