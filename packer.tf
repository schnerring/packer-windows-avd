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

# Export Variables For Packer

locals {
  packer_var_file = "default.auto.pkrvars.hcl"
}

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

# Packer Location

resource "github_actions_secret" "packer_location" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_LOCATION"
  plaintext_value = azurerm_resource_group.packer.location

  provisioner "local-exec" {
    command     = <<-EOT
      echo "location = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

# Packer Resource Group

resource "github_actions_secret" "packer_resource_group" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer.name

  provisioner "local-exec" {
    command     = <<-EOT
      echo "resource_group = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

# Packer Authentication

resource "github_actions_secret" "packer_client_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_CLIENT_ID"
  plaintext_value = azuread_application.packer.application_id

  provisioner "local-exec" {
    command     = <<-EOT
      echo "client_id = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

resource "github_actions_secret" "packer_client_secret" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.packer.value

  provisioner "local-exec" {
    command     = <<-EOT
      echo "client_secret = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

resource "github_actions_secret" "packer_subscription_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.subscription.subscription_id

  provisioner "local-exec" {
    command     = <<-EOT
      echo "subscription_id = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

resource "github_actions_secret" "packer_tenant_id" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_TENANT_ID"
  plaintext_value = data.azurerm_subscription.subscription.tenant_id

  provisioner "local-exec" {
    command     = <<-EOT
      echo "tenant_id = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}
