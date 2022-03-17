# packer-windows-11-avd

Custom Windows 11 Packer Images for Azure Virtual Desktop (AVD).

## Authenticate With Terraform

- [Authenticate to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [Authenticate to GitHub](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication)

## Create Terraform Resources

The `packer.tf` file contains the Terraform resources that Packer requires:

- Two resource groups
  - `packer-artifacts-rg`: managed images produced by Packer
  - `packer-build-rg`: build-time Packer resources. It should be empty when Packer isn't running
- Service Principal with scoped access to Packer resource groups
- Exported GitHub secrets used for CI

Run `terraform apply` to deploy the required resources.

## Create Packer Image

After deploying with Terraform, run the `init-packer-vars.ps1` PowerShell script. It reads the Terraform outputs and writes them to the `default.auto.pkrvars.hcl` Packer variables file.

Then run `packer build .`.

## Discover Windows 11 Versions

Use the Azure CLI to discover what versions are available.

## With Office

List SKUs:

```bash
az vm image list-skus \
  --offer office-365 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].name" \
  --out tsv
```

List versions:

```bash
az vm image list \
  --sku win11-21h2-avd-m365 \
  --offer office-365 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].version" \
  --out tsv \
  --all
```

## Without Office

List SKUs:

```bash
az vm image list-skus \
  --offer windows-11 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].name" \
  --out tsv
```

List versions:

```bash
az vm image list \
  --sku win11-21h2-avd \
  --offer windows-11 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].version" \
  --out tsv \
  --all
```
