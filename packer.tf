variable "location" {
  type        = string
  description = "Azure region for Packer resources."
  default     = "Switzerland North"
}

data "azurerm_subscription" "subscription" {}

# Packer Resource Group

resource "azurerm_resource_group" "packer" {
  name     = "packer-rg"
  location = var.location
}

# Service Principal Used By Packer

resource "azuread_application" "packer" {
  display_name = "packer-sp-app"
}

resource "azuread_service_principal" "packer" {
  application_id = azuread_application.packer.application_id
}

resource "azuread_service_principal_password" "packer" {
  service_principal_id = azuread_service_principal.packer.id
}

# RBAC

resource "azurerm_role_assignment" "packer_contributor" {
  scope                = azurerm_resource_group.packer.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.packer.id
}

# Shared Image Gallery Containing Custom Windows 11 Images

resource "azurerm_shared_image_gallery" "packer" {
  name                = "packer_windows_11_gal"
  resource_group_name = azurerm_resource_group.packer.name
  location            = azurerm_resource_group.packer.location
}

# Export GitHub Secrets

data "github_repository" "packer_windows_11_avd" {
  full_name = "schnerring/packer-windows-11-avd"
}

# Azure CLI Credentials

resource "github_actions_secret" "github_actions_azure_credentials" {
  repository  = data.github_repository.packer_windows_11_avd.name
  secret_name = "AZURE_CREDENTIALS"

  plaintext_value = jsonencode(
    {
      clientId       = azuread_application.packer.application_id
      clientSecret   = azuread_service_principal_password.packer.value
      subscriptionId = data.azurerm_subscription.subscription.subscription_id
      tenantId       = data.azurerm_subscription.subscription.tenant_id
    }
  )
}

# Packer Authentication

resource "github_actions_secret" "packer_client_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_CLIENT_ID"
  plaintext_value = azuread_application.packer.application_id
}

resource "github_actions_secret" "packer_client_secret" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.packer.value
}

resource "github_actions_secret" "packer_subscription_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.subscription.subscription_id
}

resource "github_actions_secret" "packer_tenant_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_TENANT_ID"
  plaintext_value = data.azurerm_subscription.subscription.tenant_id
}

# Packer Shared Image Gallery Destination

resource "github_actions_secret" "packer_shared_image_gallery_destination_resource_group" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_SHARED_IMAGE_GALLERY_DESTINATION_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer.name
}

resource "github_actions_secret" "packer_shared_image_gallery_destination_gallery_name" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_SHARED_IMAGE_GALLERY_DESTINATION_GALLERY_NAME"
  plaintext_value = azurerm_shared_image_gallery.packer.name
}
