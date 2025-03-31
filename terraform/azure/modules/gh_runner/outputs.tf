output "vm_id" {
  description = "The ID of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.gh_runner.id
}

output "vm_private_ip" {
  description = "Private IP of the GitHub runner"
  value       = azurerm_network_interface.gh_runner_nic.private_ip_address
}

output "vm_name" {
  description = "Name of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.gh_runner.name
}
