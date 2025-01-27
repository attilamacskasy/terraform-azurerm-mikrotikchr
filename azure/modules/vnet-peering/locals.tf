locals {
  vnet_source_parts               = split("/", var.vnet_source_id)
  vnet_source_name                = element(local.vnet_source_parts, 8)
  vnet_source_resource_group_name = element(local.vnet_source_parts, 4)

  vnet_destination_parts               = split("/", var.vnet_destination_id)
  vnet_destination_name                = element(local.vnet_destination_parts, 8)
  vnet_destination_resource_group_name = element(local.vnet_destination_parts, 4)
}
