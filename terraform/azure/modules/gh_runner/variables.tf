variable "resource_group" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to join"
  type        = string
}

variable "vm_name" {
  description = "Name of the GitHub runner VM"
  type        = string
  default     = "gh-runner"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "runneradmin"
}

variable "admin_password" {
  description = "Admin password (for testing or bootstrapping)"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repo to register runner to (format: owner/repo)"
  type        = string
}

variable "github_runner_token" {
  description = "GitHub runner registration token"
  type        = string
  sensitive   = true
}
