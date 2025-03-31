output "nsg_id" {
  description = "ID of the NSG"
  value       = azurerm_network_security_group.chr_nsg.id
}

output "nsg_name" {
  description = "Name of the NSG"
  value       = azurerm_network_security_group.chr_nsg.name
}
