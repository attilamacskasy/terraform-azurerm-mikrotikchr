output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.os_flavor == "linux" ? tls_private_key.rsa[0].private_key_pem : null
}

output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  sensitive   = true
  value       = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
}
output "linux_virtual_machine_ids" {
  description = "The resource id's of all Linux Virtual Machine."
  value       = var.os_flavor == "linux" ? concat(azurerm_linux_virtual_machine.linux_vm.*.id, [""]) : null
}

output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = var.os_flavor == "windows" ? concat(azurerm_windows_virtual_machine.win_vm.*.id, [""]) : null
}

output "windows_vm_names" {
  description = "The names of all Windows Virtual Machines"
  value       = var.os_flavor == "windows" ? concat(azurerm_windows_virtual_machine.win_vm.*.name, [""]) : null
}

output "linux_vm_names" {
  description = "The names of all Linux Virtual Machines"
  value       = var.os_flavor == "linux" ? concat(azurerm_linux_virtual_machine.linux_vm.*.name, [""]) : null
}

output "instances_count" {
  description = "output instances count for the deployment"
  value       = var.instances_count
}
