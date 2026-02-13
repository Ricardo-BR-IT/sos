# AGENTS Instructions

## Deploy Info (Updated 2026-02-06)
- Plano: Linux Standard
- Dominio: www.mentalesaude.com.br
- Pasta web: https://mentalesaude.com.br/ricardo/sos
- cPanel: www.mentalesaude.com.br/cpanel ou www.clubehost.com.br/cpanel
- FTP host: mentalesaude.com.br (alternativo: clubehost.com.br)
- FTP porta: 21
- FTP usuario: mentales
- FTP senha: 4dSeA.3g0E6R(z

## Paths
- Repo root: C:\site\mentalesaude\www\ricardo\sos
- Deploy stage: C:\site\mentalesaude\www\ricardo\sos\deploy_stage

## Notas
- **Deploy**: Preferir `scripts/ftp_upload.ps1` para deploy web (recursivo).
- **CI/CD**: GitHub Actions configurado para builds automáticos de apps (Android, iOS, Windows, Linux, Java).
