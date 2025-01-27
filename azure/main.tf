# ---
# RG DEPLOYMENT
# ---
module "rg" {
  source   = "./modules/rg"
  rg_name  = "rg-${var.project}-${var.environment}-${var.az_region}"
  location = var.location
}

# ---
# VNET DEPLOYMENT
# ---
module "vnet_hub" {
  source         = "./modules/vnet"
  vnet_name      = "vnet-hub-${var.az_region}"
  vnet_location  = var.location
  resource_group = module.rg.resource_group_name
  address_space  = ["172.17.0.0/16"]
}

# ---
# SUBNET DEPLOYMENT
# ---
module "subnet_example" {
  source               = "./modules/subnet"
  subnet_name          = "snet-chr-${var.az_region}"
  resource_group       = module.rg.resource_group_name
  virtual_network_name = module.vnet_hub.vnet_name
  subnet_prefixes      = ["172.17.1.0/24"]
}

# ---
# Mikrotik
# ---
module "vm_mikrotik" {
  source         = "./modules/mikrotik"
  resource_group = module.rg.resource_group_name
  location       = var.location
  project        = var.project
  environment    = var.environment
  az_region      = var.az_region
  az_subnet_id   = module.subnet_example.subnet_id
}

resource "azurerm_image" "example" {
  hyper_v_generation  = "V2"
  location            = "westeurope"
  name                = "test-mikrotik"
  resource_group_name = "rg-dms-poc-westeu"
  tags                = {}
  zone_resilient      = false

  os_disk {
    blob_uri = "https://***mikrotik-image.vhd"
    caching  = "ReadWrite"
    os_state = "Generalized"
    os_type  = "Linux"
    size_gb  = 1
  }
}


