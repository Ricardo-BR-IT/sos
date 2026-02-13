param(
  [string]$Root = "C:\site\mentalesaude\www\ricardo\sos"
)

$javaRoot = Join-Path $Root "java"
$libPath = Join-Path $javaRoot "lib\*"
$dist = Join-Path $javaRoot "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

function Compile-Sources {
  param(
    [string]$SourceDir,
    [string]$OutDir,
    [string[]]$ClassPath
  )
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  $sources = Get-ChildItem -Recurse -Path $SourceDir -Filter *.java | Select-Object -ExpandProperty FullName
  if ($sources.Count -eq 0) { return }
  $listFile = Join-Path $env:TEMP "javac_sources.txt"
  $sources | Set-Content -Path $listFile -Encoding ASCII
  $cp = ($ClassPath -join ';')
  & javac -cp $cp -d $OutDir "@$listFile"
}

$coreOut = Join-Path $javaRoot "core\build\classes"
Compile-Sources -SourceDir (Join-Path $javaRoot "core\src\main\java") -OutDir $coreOut -ClassPath @($libPath)

$miniOut = Join-Path $javaRoot "mini\build\classes"
Compile-Sources -SourceDir (Join-Path $javaRoot "mini\src\main\java") -OutDir $miniOut -ClassPath @($libPath, $coreOut)

$standardOut = Join-Path $javaRoot "standard\build\classes"
Compile-Sources -SourceDir (Join-Path $javaRoot "standard\src\main\java") -OutDir $standardOut -ClassPath @($libPath, $coreOut)

$serverOut = Join-Path $javaRoot "server\build\classes"
Compile-Sources -SourceDir (Join-Path $javaRoot "server\src\main\java") -OutDir $serverOut -ClassPath @($libPath, $coreOut)

& jar cfe (Join-Path $dist "resgatesos-mini.jar") com.resgatesos.mini.MiniMain -C $coreOut . -C $miniOut .
& jar cfe (Join-Path $dist "resgatesos-standard.jar") com.resgatesos.standard.StandardMain -C $coreOut . -C $standardOut .
& jar cfe (Join-Path $dist "resgatesos-server.jar") com.resgatesos.server.ServerMain -C $coreOut . -C $serverOut .

$webOut = Join-Path $Root "apps\web_portal\out-server"
$webDest = Join-Path $dist "web"
if (Test-Path $webDest) { Remove-Item -Recurse -Force $webDest }
if (Test-Path $webOut) {
  New-Item -ItemType Directory -Force -Path $webDest | Out-Null
  Copy-Item -Recurse -Force (Join-Path $webOut '*') $webDest
}

"ok"
