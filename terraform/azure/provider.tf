terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }

  # backend is auto generated in .github\workflows\04_Prepare_Infra.yml 
  /*
  backend "azurerm" {
    resource_group_name  = "rg-mikrotik-chr"
    storage_account_name = "mikrotikchrstorage01"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
  */
}

provider "azurerm" {
  features {}
}
