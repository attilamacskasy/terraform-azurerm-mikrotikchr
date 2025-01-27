variable "rg_name" {
  type        = string
  description = "Name for the Resource Group"
  default     = "TFResourceGroup"
}
variable "location" {
  type        = string
  description = "Location for the Resource Group"
  default     = "westeurope"
}
variable "tags" {
  type        = map(string)
  description = "Tags for the Resource Group"
  default = {
    "source" = "Terraform"
  }
}


