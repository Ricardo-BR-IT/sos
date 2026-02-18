param(
  [string]$RemoteRoot = "ftp://mentalesaude.com.br/public_html/ricardo/sos/",
  [string]$BackupRoot = "C:\site\mentalesaude\www\ricardo\sos\_backup_remote"
)

$ErrorActionPreference = "Stop"

$ftpUser = $env:FTP_USER
$ftpPass = $env:FTP_PASS
if ([string]::IsNullOrWhiteSpace($ftpUser) -or [string]::IsNullOrWhiteSpace($ftpPass)) {
  throw "FTP_USER/FTP_PASS not set in environment."
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$target = Join-Path $BackupRoot "sos_remote_$stamp"
New-Item -ItemType Directory -Force -Path $target | Out-Null

function New-FtpRequest {
  param(
    [string]$Url,
    [string]$Method
  )
  $request = [System.Net.FtpWebRequest]::Create($Url)
  $request.Method = $Method
  $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
  $request.UseBinary = $true
  $request.UsePassive = $true
  $request.KeepAlive = $false
  $request.Timeout = 120000
  return $request
}

function Get-RemoteNames {
  param([string]$Url)
  $request = New-FtpRequest -Url $Url -Method ([System.Net.WebRequestMethods+Ftp]::ListDirectory)
  $response = $request.GetResponse()
  $stream = New-Object IO.StreamReader($response.GetResponseStream())
  $content = $stream.ReadToEnd()
  $stream.Close()
  $response.Close()
  return $content -split "`r?`n" | Where-Object { $_ -and $_ -ne "." -and $_ -ne ".." }
}

function Test-RemoteDir {
  param([string]$Url)
  try {
    $request = New-FtpRequest -Url ($Url.TrimEnd('/') + '/') -Method ([System.Net.WebRequestMethods+Ftp]::ListDirectory)
    $response = $request.GetResponse()
    $response.Close()
    return $true
  } catch {
    return $false
  }
}

function Download-RemoteFile {
  param(
    [string]$RemoteUrl,
    [string]$LocalPath
  )
  $request = New-FtpRequest -Url $RemoteUrl -Method ([System.Net.WebRequestMethods+Ftp]::DownloadFile)
  $response = $request.GetResponse()
  $stream = $response.GetResponseStream()
  $dir = Split-Path -Parent $LocalPath
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $file = [System.IO.File]::Create($LocalPath)
  $stream.CopyTo($file)
  $file.Close()
  $stream.Close()
  $response.Close()
}

function Backup-Recursive {
  param(
    [string]$RemoteUrl,
    [string]$RelativePath
  )

  $names = Get-RemoteNames -Url $RemoteUrl
  foreach ($name in $names) {
    $childRemote = $RemoteUrl.TrimEnd('/') + '/' + $name
    $childRelative = if ([string]::IsNullOrWhiteSpace($RelativePath)) { $name } else { "$RelativePath/$name" }

    if (Test-RemoteDir -Url $childRemote) {
      Backup-Recursive -RemoteUrl ($childRemote + '/') -RelativePath $childRelative
    } else {
      $localPath = Join-Path $target ($childRelative -replace '/', '\')
      Download-RemoteFile -RemoteUrl $childRemote -LocalPath $localPath
    }
  }
}

Backup-Recursive -RemoteUrl $RemoteRoot -RelativePath ""
Write-Host "Backup concluido em: $target"
