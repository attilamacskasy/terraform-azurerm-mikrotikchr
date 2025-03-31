variable "public_ip_name" {
  type        = string
  description = "Name of the public IP address"
}

variable "location" {
  type        = string
  description = "Azure region/location"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "allocation_method" {
  type        = string
  description = "Allocation method for the public IP (Dynamic or Static)"
  default     = "Dynamic"
}

variable "sku" {
  type        = string
  description = "SKU for the public IP (Basic or Standard)"
  default     = "Basic"
}
