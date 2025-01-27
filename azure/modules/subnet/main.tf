resource "azurerm_subnet" "subnet_example" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_prefixes
}
