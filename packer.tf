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
