# See https://docs.microsoft.com/en-us/powershell/azure/install-az-ps-msi?view=azps-7.2.0#install-or-update-on-windows-using-the-msi-package

$ErrorActionPreference = "Stop"

$downloadUrl = "https://github.com/Azure/azure-powershell/releases/download/v7.2.0-February2022/Az-Cmdlets-7.2.0.35201-x64.msi"
$outFile = "D:\az_pwsh.msi" # ephemeral disk

Write-Host "Installing Azure PowerShell ..."
Write-Host "Downloading $downloadUrl ..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $downloadUrl -OutFile $outFile

Write-Host "Installing ..."
Start-Process "msiexec.exe" -Wait -ArgumentList "/package $outFile"

Write-Host "Done."
