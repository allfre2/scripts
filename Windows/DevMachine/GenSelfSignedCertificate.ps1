# Import tools

. "$PSScriptRoot\tools\Common.ps1"

$config = Get-Config

$cert = New-SelfSignedCertificate `
    -Subject "CN=localhost" `
    -DnsName "localhost" `
    -CertStoreLocation (Join-Path $HOME $config.Git.SourceDir) `
    -KeyExportPolicy Exportable `
    -NotAfter (Get-Date).AddYears(2)


# Move certificate to Trusted Root Authority store
$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
$rootStore.Open([System.Security.Cryptography.X509StoreOpenFlags]::ReadWrite)
$rootStore.Add($cert)
$rootStore.Close()
