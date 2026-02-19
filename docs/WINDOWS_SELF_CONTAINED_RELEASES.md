# Windows Self-Contained Releases

## Objetivo
Garantir que os binarios Windows nao sejam distribuidos como `.exe` isolado.
O artefato oficial passa a ser o pacote portatil completo:

- `desktop-<edition>-windows-portable/`
- `desktop-<edition>-windows-portable.zip`

## O que vai no pacote
- `desktop_station.exe`
- `flutter_windows.dll`
- DLLs de plugins
- pasta `data/`
- (quando disponivel) runtime Visual C++ x64:
  `vcruntime140*.dll`, `msvcp140*.dll`, `concrt140.dll`, `vccorlib140.dll`

## Scripts atualizados
- `scripts/build_apps_parallel.ps1`
- `scripts/build_artifacts_sequential.ps1`
- `scripts/build_apps.py`

Todos os scripts acima agora:
1. Copiam a pasta `build/windows/x64/runner/Release` inteira.
2. Geram pasta portatil por edicao.
3. Geram zip portatil por edicao.
4. Evitam manter `desktop-<edition>.exe` na raiz dos artefatos.

## Comandos recomendados

Build completo sequencial (APK + desktop):

```powershell
& scripts/build_artifacts_sequential.ps1
```

Build desktop-only (todas edicoes):

```powershell
& scripts/build_apps_parallel.ps1 -Apps @('desktop_station') -Editions @('mini','standard','server')
```

## Publicacao
Depois do build:

```powershell
& scripts/prepare_deploy.ps1
$env:FTP_USER='...'
$env:FTP_PASS='...'
& scripts/ftp_upload.ps1
```

## Autocompilacao (CI)
Workflow configurado para build automatico em GitHub Actions:

- `.github/workflows/build-apps-autocompiled.yml`

Escopo:
- Android APK (mobile/tv/wear) para `mini`, `standard`, `server`
- Windows desktop portatil em ZIP para `mini`, `standard`, `server`

Gatilhos:
- `push` na branch `main` (paths de apps/workflow/scripts)
- `workflow_dispatch`
- `schedule` diario (`03:00 UTC`)
