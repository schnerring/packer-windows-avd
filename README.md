# packer-windows-11-avd

Custom Windows 11 Packer Images for Azure Virtual Desktop (AVD).

## Create Terraform Resources

The `packer.tf` file contains the Terraform resources that Packer requires:

- Two resource groups
  - `packer-artifacts-rg`: managed images produced by Packer
  - `packer-build-rg`: build-time Packer resources. It should be empty when Packer isn't running
- Service Principal with scoped access to Packer resource groups
- Exported GitHub secrets used for CI

After [authenticating to Azure with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure), run `terraform apply` to deploy the required resources.

Running Terraform will create the `default.auto.pkrvars.hcl` file using the [`local-exec` provisioner](https://www.terraform.io/language/resources/provisioners/local-exec). Note that it uses the `pwsh` interpreter, so make sure to install [PowerShell Core](https://docs.microsoft.com/en-us/powershell/) or change to another interpreter supported by your OS.

## Create Packer Image

After deploying the Terraform resources, run `packer build .`.
