variable "azurerm_image_name" {
  type        = string
  description = "Name of the Mikrotik image"
}

variable "location" {
  type        = string
  description = "Azure region/location"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group"
}

variable "azurerm_network_interface_name" {
  type        = string
  description = "Name of the network interface"
}

variable "ip_configuration_name" {
  type        = string
  description = "Name of the IP configuration"
}

variable "az_subnet_id" {
  type        = string
  description = "ID of the subnet"
}

variable "azurerm_virtual_machine_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "azurerm_virtual_machine_vm_size" {
  type        = string
  description = "Size of the virtual machine"
}

variable "storage_os_disk_name" {
  type        = string
  description = "Name of the OS disk"
}

variable "storage_os_disk_managed_disk_type" {
  type        = string
  description = "Managed disk type for the OS disk"
}

variable "azurerm_route_table_name" {
  type        = string
  description = "Name of the route table"
}

variable "os_profile_admin_password" {
  type        = string
  description = "Admin password for CHR"
}

variable "public_ip_address_id" {
  type        = string
  description = "ID of the public IP address"
}

variable "nsg_id" {
  type        = string
  description = "ID of the Network Security Group"
}
