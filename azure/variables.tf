variable "location" {
  type        = string
  description = "Location for the Resource Group"
  default     = "westeurope"

}
variable "az_region" {
  type        = string
  description = "Region used for the naming convension"
}

variable "environment" {
  type        = string
  description = "The stage of the development lifecycle for the workload that the resource supports."
}
variable "project" {
  type        = string
  description = "Name of a project, application, or service that the resource is a part of."
}
