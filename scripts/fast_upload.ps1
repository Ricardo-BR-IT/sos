$wc = New-Object System.Net.WebClient
$wc.Credentials = New-Object System.Net.NetworkCredential('mentales', '4dSeA.3g0E6R(z')
$localFile = "C:\site\mentalesaude\www\ricardo\sos\mesh_relay.php"
$remoteUrl = "ftp://mentalesaude.com.br/public_html/ricardo/sos/mesh_relay.php"
$wc.UploadFile($remoteUrl, $localFile)
Write-Host "Upload complete."
