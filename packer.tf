variable "location" {
  type        = string
  description = "Azure region for Packer resources."
  default     = "Switzerland North"
}

data "azurerm_subscription" "subscription" {}

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
# Grant `Reader` role to SP for subscription allowing Packer to read resource groups
# Grant `Contributor` role to SP for Packer resource groups allowing Packer to manage their resources

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

# Packer Resource Groups

resource "github_actions_secret" "packer_artifacts_resource_group" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_ARTIFACTS_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer_artifacts.name

  provisioner "local-exec" {
    command     = <<-EOT
      echo "artifacts_resource_group = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

resource "github_actions_secret" "packer_build_resource_group" {
  repository      = data.github_repository.packer_windows_11_avd.name
  secret_name     = "PACKER_BUILD_RESOURCE_GROUP"
  plaintext_value = azurerm_resource_group.packer_build.name

  provisioner "local-exec" {
    command     = <<-EOT
      echo "build_resource_group = `"${self.plaintext_value}`"" >> ${local.packer_var_file}
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
