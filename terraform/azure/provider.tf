terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-hub-net-shared-001"
    storage_account_name = "mikrotikchrstorage01"
    container_name       = "terraform"
    key                  = "terraform-chr.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
