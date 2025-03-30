resource "azurerm_virtual_network_peering" "source" {
  provider                     = azurerm.source
  name                         = format("peering-to-%s", local.vnet_destination_name)
  resource_group_name          = local.vnet_source_resource_group_name
  virtual_network_name         = local.vnet_source_name
  remote_virtual_network_id    = var.vnet_destination_id
  allow_virtual_network_access = var.allow_virtual_source_network_access
  allow_forwarded_traffic      = var.allow_forwarded_source_traffic
  allow_gateway_transit        = var.allow_gateway_source_transit
  use_remote_gateways          = var.use_remote_source_gateway
}

resource "azurerm_virtual_network_peering" "destination" {
  provider                     = azurerm.destination
  name                         = format("peering-to-%s", local.vnet_source_name)
  resource_group_name          = local.vnet_destination_resource_group_name
  virtual_network_name         = local.vnet_destination_name
  remote_virtual_network_id    = var.vnet_source_id
  allow_virtual_network_access = var.allow_virtual_destination_network_access
  allow_forwarded_traffic      = var.allow_forwarded_destination_traffic
  allow_gateway_transit        = var.allow_gateway_destination_transit
  use_remote_gateways          = var.use_remote_destination_gateway
}
