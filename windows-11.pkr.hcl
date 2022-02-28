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
}
