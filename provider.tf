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
