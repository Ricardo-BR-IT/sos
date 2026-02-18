param(
  [string]$LocalRoot = "C:\site\mentalesaude\www\ricardo\sos\deploy_stage",
  [string]$RemoteRoot = "ftp://mentalesaude.com.br/public_html/ricardo/sos/"
)

$ErrorActionPreference = 'Stop'

$ftpUser = $env:FTP_USER
$ftpPass = $env:FTP_PASS

if ([string]::IsNullOrWhiteSpace($ftpUser) -or [string]::IsNullOrWhiteSpace($ftpPass)) {
  throw "FTP_USER/FTP_PASS not set in environment."
}

$script:FailedUploads = New-Object System.Collections.Generic.List[string]

function New-FtpDirectory {
  param([string]$url)
  try {
    $request = [System.Net.FtpWebRequest]::Create($url)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.UseBinary = $true
    $request.UsePassive = $true
    $response = $request.GetResponse()
    $response.Close()
  } catch {
    # directory may already exist
  }
}

function Remove-FtpFile {
  param([string]$remoteUrl)
  try {
    $request = [System.Net.FtpWebRequest]::Create($remoteUrl)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.UseBinary = $true
    $request.UsePassive = $true
    $request.KeepAlive = $false
    $response = $request.GetResponse()
    $response.Close()
  } catch {
    # ignore delete failure before upload
  }
}

function Upload-FtpFile {
  param([string]$localPath, [string]$remoteUrl)
  $maxRetries = 4
  for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
      if ($attempt -eq 1) {
        Remove-FtpFile -remoteUrl $remoteUrl
      }

      $request = [System.Net.FtpWebRequest]::Create($remoteUrl)
      $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
      $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
      $request.UseBinary = $true
      $request.UsePassive = $true
      $request.KeepAlive = $false
      $request.Timeout = 120000
      $request.ReadWriteTimeout = 120000
      $request.ContentLength = (Get-Item $localPath).Length
      $fileStream = [System.IO.File]::OpenRead($localPath)
      $reqStream = $request.GetRequestStream()
      $fileStream.CopyTo($reqStream)
      $reqStream.Close()
      $fileStream.Close()
      $response = $request.GetResponse()
      $response.Close()
      return $true
    } catch {
      if ($attempt -ge $maxRetries) { return $false }
      Start-Sleep -Seconds (2 * $attempt)
    }
  }
  return $false
}

function Sync-Dir {
  param([string]$localDir, [string]$remoteUrl)
  New-FtpDirectory -url $remoteUrl
  Get-ChildItem -Force $localDir | ForEach-Object {
    try {
      if ($_.PSIsContainer) {
        Sync-Dir -localDir $_.FullName -remoteUrl ($remoteUrl + $_.Name + '/')
      } else {
        $ok = Upload-FtpFile -localPath $_.FullName -remoteUrl ($remoteUrl + $_.Name)
        if (-not $ok) {
          $script:FailedUploads.Add($_.FullName)
        }
      }
      Start-Sleep -Milliseconds 100
    } catch {
      $script:FailedUploads.Add($_.FullName)
    }
  }
}

if (-not (Test-Path $LocalRoot)) {
  throw "LocalRoot not found: $LocalRoot"
}

Sync-Dir -localDir $LocalRoot -remoteUrl $RemoteRoot

if ($script:FailedUploads.Count -gt 0) {
  Write-Host "Failed uploads:" -ForegroundColor Yellow
  $script:FailedUploads | ForEach-Object { Write-Host $_ }
  exit 1
}

Write-Host "Upload completed: $RemoteRoot"
