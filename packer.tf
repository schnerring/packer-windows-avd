terraform {
  required_version = ">= 1.1.6"

  required_providers {
    azuread = {
      source  = "azuread"
      version = ">= 2.18.0"
    }

    azurerm = {
      source  = "azurerm"
      version = ">= 2.98.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 4.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type        = string
  description = "Azure region for Packer resources."
  default     = "Switzerland North"
}

# Packer Resource Groups

resource "azurerm_resource_group" "packer_artifacts" {
  name     = "packer-artifacts-rg"
  location = var.location
}

resource "azurerm_resource_group" "packer_build" {
  name     = "packer-build-rg"
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
# Grant service principal `Reader` role scoped to subscription
# Grant service principal `Contributor` role scoped to Packer resource groups

data "azurerm_subscription" "subscription" {}

resource "azurerm_role_assignment" "subscription_reader" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.packer.id
}

resource "azurerm_role_assignment" "packer_build_contributor" {
  scope                = azurerm_resource_group.packer_build.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.packer.id
}

resource "azurerm_role_assignment" "packer_artifacts_contributor" {
  scope                = azurerm_resource_group.packer_artifacts.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.packer.id
}

# Export Variables For Packer

data "github_repository" "packer_windows_avd" {
  full_name = "schnerring/packer-windows-avd"
}

# Azure CLI Authentication

resource "github_actions_secret" "github_actions_azure_credentials" {
  repository  = data.github_repository.packer_windows_avd.name
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
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_CLIENT_ID"
  plaintext_value = azuread_application.packer.application_id
}

resource "github_actions_secret" "packer_client_secret" {
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.packer.value
}

resource "github_actions_secret" "packer_subscription_id" {
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.subscription.subscription_id
}

resource "github_actions_secret" "packer_tenant_id" {
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_TENANT_ID"
  plaintext_value = data.azurerm_subscription.subscription.tenant_id
}

# Packer Resource Groups

resource "github_actions_secret" "packer_artifacts_resource_group" {
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_ARTIFACTS_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer_artifacts.name
}

resource "github_actions_secret" "packer_build_resource_group" {
  repository      = data.github_repository.packer_windows_avd.name
  secret_name     = "PACKER_BUILD_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer_build.name
}

# Outputs to run Packer locally

output "packer_artifacts_resource_group" {
  value = azurerm_resource_group.packer_artifacts.name
}

output "packer_build_resource_group" {
  value = azurerm_resource_group.packer_build.name
}

output "packer_client_id" {
  value     = azuread_application.packer.application_id
  sensitive = true
}

output "packer_client_secret" {
  value     = azuread_service_principal_password.packer.value
  sensitive = true
}

output "packer_subscription_id" {
  value     = data.azurerm_subscription.subscription.subscription_id
  sensitive = true
}

output "packer_tenant_id" {
  value     = data.azurerm_subscription.subscription.tenant_id
  sensitive = true
}
