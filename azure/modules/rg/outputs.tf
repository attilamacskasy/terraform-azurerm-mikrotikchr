output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the resource group"
}
output "resource_group_id" {
  value       = azurerm_resource_group.rg.id
  description = "The id of the resource group"
}

