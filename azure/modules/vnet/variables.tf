variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_location" {
  description = "The location/region where the virtual network is created"
  type        = string
}

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space that is used the virtual network. You can supply more than one address space"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  type        = list(string)
  default     = null
}

variable "subnet" {
  description = "Optional feature to be used in-line within the Network Security Group resource. Check advanced example for usage"
  type = list(object({
    name           = string
    address_prefix = string
    security_group = optional(string)
  }))
  default = []
}
