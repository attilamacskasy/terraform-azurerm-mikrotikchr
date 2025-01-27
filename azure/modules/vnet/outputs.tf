output "vnet_id" {
  value       = azurerm_virtual_network.vnet_example.id
  description = "Vnet ID"
}
output "vnet_name" {
  value       = azurerm_virtual_network.vnet_example.name
  description = "Vnet name"
}
