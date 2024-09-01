# See https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.2.0&tabs=powershell&pivots=windows-msi

$ErrorActionPreference = "Stop"

$downloadUrl = "https://github.com/Azure/azure-powershell/releases/download/v12.2.0-August2024/Az-Cmdlets-12.2.0.38863-x64.msi"
$outFile = "D:\az_pwsh.msi" # temporary disk

Write-Host "Downloading $downloadUrl ..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $downloadUrl -OutFile $outFile

Write-Host "Installing ..."
Start-Process "msiexec.exe" -Wait -ArgumentList "/package $outFile"

Write-Host "Done."
