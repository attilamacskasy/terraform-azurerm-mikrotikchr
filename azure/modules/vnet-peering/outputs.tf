output "vnet_peering_source_id" {
  description = "Virtual network source peering id"
  value       = azurerm_virtual_network_peering.source.id
}

output "vnet_peering_source_name" {
  description = "Virtual network source peering name"
  value       = azurerm_virtual_network_peering.source.name
}

output "vnet_peering_destination_id" {
  description = "Virtual network destination peering id"
  value       = azurerm_virtual_network_peering.destination.id
}

output "vnet_peering_destination_name" {
  description = "Virtual network destination peering name"
  value       = azurerm_virtual_network_peering.destination.name
}
