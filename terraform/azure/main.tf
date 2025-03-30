# get parameters from deploy-params.json
locals {
  params = jsondecode(file("${path.module}/deploy-params.json"))
}

module "vnet_hub" {
  source         = "./modules/vnet"
  vnet_name      = local.params.vnet_name
  vnet_location  = local.params.location
  resource_group = local.params.resource_group
  address_space  = ["172.30.0.0/16"] # TODO: not yet in parameters
}

module "subnet_chr" {
  source               = "./modules/subnet"
  subnet_name          = local.params.subnet_name
  resource_group       = local.params.resource_group
  virtual_network_name = module.vnet_hub.vnet_name
  subnet_prefixes      = ["172.30.1.0/24"] # TODO: not yet in parameters
}

module "vm_mikrotik" {
  source         = "./modules/mikrotik"
  az_subnet_id   = module.subnet_chr.subnet_id

  resource_group = local.params.resource_group
  location       = local.params.location
  azurerm_image_name = local.params.azurerm_image_name
  azurerm_network_interface_name = local.params.azurerm_network_interface_name
  ip_configuration_name = local.params.ip_configuration_name
  azurerm_virtual_machine_name = local.params.azurerm_virtual_machine_name
  azurerm_virtual_machine_vm_size = local.params.azurerm_virtual_machine_vm_size
  storage_os_disk_name = local.params.storage_os_disk_name
  storage_os_disk_managed_disk_type = local.params.storage_os_disk_managed_disk_type
  azurerm_route_table_name = local.params.azurerm_route_table_name
  
}
