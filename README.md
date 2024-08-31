# packer-windows-avd

Custom Windows 11 "golden" image for Azure Virtual Desktop (AVD) built with Packer.

It [bundles apps](./packages.config) that make the image suitable for software development workstations using [Chocolatey](https://chocolatey.org/) and a [PowerShell provisioning script](./install-azure-powershell.ps1).

A [GitHub Actions workflow](./.github/workflows/packer.yml) checks daily for a new Windows release and runs Packer if required (typically on [Patch Tuesday](https://docs.microsoft.com/en-us/windows/deployment/update/quality-updates#quality-updates)).

[Read more about my thoughts going into this on my blog.](https://schnerring.net/blog/automate-building-custom-windows-images-for-azure-virtual-desktop-with-packer-and-github-actions/)

## Deploy Terraform Resources

I like using Terraform to pre-provision the resources required by Packer. However, you can use the Azure Portal or similar alternatively.

Authenticate with Terraform:

- [Authenticate to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [Authenticate to GitHub](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication)

The `packer.tf` file contains the following resources:

- Two resource groups
  - `packer-artifacts-rg`: managed images produced by Packer
  - `packer-build-rg`: build-time Packer resources. It should be empty when Packer isn't running
- Service Principal with scoped `Contributor` access to Packer resource groups, and `Reader` access to subscription
- GitHub secrets required for GitHub Actions workflow

Run `terraform apply` to deploy the required resources.

## Run Packer Locally

After deploying the resources with Terraform, run the following command to run Packer (note the `.` at the very end):

```bash
packer build \
  -var "artifacts_resource_group=$(terraform output -raw packer_artifacts_resource_group)" \
  -var "build_resource_group=$(terraform output -raw packer_build_resource_group)" \
  -var "client_id=$(terraform output -raw packer_client_id)" \
  -var "client_secret=$(terraform output -raw packer_client_secret)" \
  -var "subscription_id=$(terraform output -raw packer_subscription_id)" \
  -var "tenant_id=$(terraform output -raw packer_tenant_id)" \
  -var "source_image_publisher=MicrosoftWindowsDesktop" \
  -var "source_image_offer=office-365" \
  -var "source_image_sku=win11-21h2-avd-m365" \
  -var "source_image_version=22000.556.220308" \
  .
```

## Discover Windows 11 Versions

Use the Azure CLI to discover what versions are available.

### With Office

List SKUs:

```bash
az vm image list-skus \
  --offer office-365 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].name" \
  --location switzerlandnorth \
  --out tsv
```

List versions:

```bash
az vm image list \
  --sku win11-23h2-avd-m365 \
  --offer office-365 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].version" \
  --out tsv \
  --all
```

### Without Office

List SKUs:

```bash
az vm image list-skus \
  --offer windows-11 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].name" \
  --location switzerlandnorth \
  --out tsv
```

List versions:

```bash
az vm image list \
  --sku win11-23h2-avd \
  --offer windows-11 \
  --publisher MicrosoftWindowsDesktop \
  --query "[*].version" \
  --out tsv \
  --all
```
