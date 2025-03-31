# get parameters from deploy-params.json
locals {
  params = jsondecode(file("${path.module}/../../deploy-params.json"))
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

module "public_ip" {
  source              = "./modules/pip"
  public_ip_name      = local.params.public_ip_name
  location            = local.params.location
  resource_group_name = local.params.resource_group
  allocation_method   = "Static" # Change this to Static
  sku                 = "Standard" # Change this to Standard, Basic does not work
  zones               = ["1"] # Add this line
}

module "nsg" {
  source              = "./modules/nsg"
  nsg_name            = local.params.nsg_name
  location            = local.params.location
  resource_group_name = local.params.resource_group
  security_rules = [
    {
      name                       = "Allow_Winbox"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8291" # Winbox port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow_SSH"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22" # SSH port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    # {
    #   name                       = "Allow_HTTP"
    #   priority                   = 120
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "Tcp"
    #   source_port_range          = "*"
    #   destination_port_range     = "80"
    #   source_address_prefix      = "*"
    #   destination_address_prefix = "*"
    # },
    # {
    #   name                       = "Allow_HTTPS"
    #   priority                   = 130
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "Tcp"
    #   source_port_range          = "*"
    #   destination_port_range     = "443"
    #   source_address_prefix      = "*"
    #   destination_address_prefix = "*"
    # }
  ]
}

module "vm_mikrotik" {
  source         = "./modules/mikrotik"

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
  os_profile_admin_password = local.params.os_profile_admin_password

  az_subnet_id   = module.subnet_chr.subnet_id
  public_ip_address_id = module.public_ip.public_ip_id
  nsg_id = module.nsg.nsg_id

}

# feat: add self-hosted GitHub runner (gh_runner) via Terraform for secure CHR config
# - Deploys lightweight VM inside same Azure VNet as MikroTik CHR
# - Runner registers automatically using GitHub token
# - Enables private, secure automation (no public IP needed)
# module "gh_runner" {
#   source              = "./modules/gh_runner"
#   resource_group      = local.params.resource_group
#   location            = local.params.location
#   subnet_id           = module.subnet_chr.subnet_id
#   vm_name             = local.params.gh_runner_vm_name
#   vm_size             = local.params.gh_runner_vm_size
#   admin_username      = local.params.gh_runner_admin_user
#   admin_password      = local.params.gh_runner_admin_password
#   github_repo         = local.params.github_repo
#   github_runner_token = local.params.github_runner_token
# }
