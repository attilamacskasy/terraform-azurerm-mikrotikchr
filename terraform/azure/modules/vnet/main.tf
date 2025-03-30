/*
resource "azurerm_virtual_network" "vnet_example" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.resource_group
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "subnet" {
    for_each = { for s in var.subnet : s.name => s }
    content {
      name           = subnet.value.name
      address_prefixes = [
        subnet.value.address_prefix
      ]
    }
  }
}
*/
resource "azurerm_virtual_network" "vnet_example" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.resource_group
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "subnet" {
    for_each = var.subnet
    content {
      name           = subnet.value["name"]
      address_prefix = subnet.value["address_prefix"]
      security_group = subnet.value["security_group"]
    }
  }
}
