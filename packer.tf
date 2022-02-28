data "azurerm_subscription" "subscription" {}

# Packer Resource Group

resource "azurerm_resource_group" "packer" {
  name     = "packer-rg"
  location = var.location
}
