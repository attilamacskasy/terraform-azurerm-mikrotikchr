output "public_ip_address" {
  description = "The actual public IP address"
  value       = azurerm_public_ip.chr_public_ip.ip_address
}

output "public_ip_id" {
  description = "The resource ID of the public IP"
  value       = azurerm_public_ip.chr_public_ip.id
}
