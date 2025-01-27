terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.0.2"
      configuration_aliases = [azurerm.source, azurerm.destination]
    }
  }
  backend "azurerm" {
    resource_group_name  = "az-dms-poc"
    storage_account_name = "azterraformpoc"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}
