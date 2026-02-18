param(
  [string]$Root = "C:\site\mentalesaude\www\ricardo\sos"
)

$deploy = Join-Path $Root "deploy_stage"
$outMini = Join-Path $Root "apps\web_portal\out-mini"
$outStandard = Join-Path $Root "apps\web_portal\out-standard"
$outServer = Join-Path $Root "apps\web_portal\out-server"

if (Test-Path $deploy) { Remove-Item -Recurse -Force $deploy }

if (Test-Path $outStandard) {
  Copy-Item -Recurse -Force $outStandard $deploy
}
elseif (Test-Path (Join-Path $Root "apps\web_portal\out")) {
  Copy-Item -Recurse -Force (Join-Path $Root "apps\web_portal\out") $deploy
}

if (Test-Path $outMini) {
  Copy-Item -Recurse -Force $outMini (Join-Path $deploy "app")
}

if (Test-Path $outServer) {
  Copy-Item -Recurse -Force $outServer (Join-Path $deploy "server")
}
if (Test-Path (Join-Path $Root "mesh_relay.php")) {
  Copy-Item -Force (Join-Path $Root "mesh_relay.php") $deploy
}
