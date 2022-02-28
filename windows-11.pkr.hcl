variable "location" {
  type        = string
  description = "Azure region for Packer resources."
  default     = "Switzerland North"
}

variable "client_id" {
  type        = string
  description = "Azure Service Principal App ID."
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principal Secret."
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID."
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID."
  sensitive   = true
}

variable "shared_image_gallery_destination_resource_group" {
  type        = string
  description = "Shared Image Gallery Destination Gallery Name."
  sensitive   = true
}

variable "shared_image_gallery_destination_resource_group" {
  type        = string
  description = "Shared Image Gallery Destination Gallery Name."
  sensitive   = true
}

source "azure-arm" "avd" {
  # WinRM Communicator

  communicator = "winrm"
  winrm_use_ssl = true
  #winrm_insecure = true
  #winrm_timeout = "5m"
  #winrm_username = "packer"

  # Service Principal Authentication

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  # Source Image

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "office-365"
  image_sku       = "win11-21h2-avd-m365"
  # Windows 11 without Office
  #image_offer     = "windows-11"
  #image_sku       = "win11-21h2-avd"

  # Packer Computing Resources

  location                  = var.location
  build_resource_group_name = "packer-rg"
  vm_size                   = "Standard_D4ds_v4"
}
