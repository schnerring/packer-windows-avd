$outFile = "default.auto.pkrvars.hcl"

if (Test-Path $outFile) {
  Remove-Item $outFile
}

$vars = @(
  "artifacts_resource_group",
  "build_resource_group",
  "client_id",
  "client_secret",
  "subscription_id",
  "tenant_id"
)

foreach ($var in $vars) {
  Write-Output "$var = ""$(terraform output -raw packer_$var)""" >> $outFile
}
