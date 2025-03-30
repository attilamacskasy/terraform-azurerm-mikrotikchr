resource "azurerm_storage_account" "sa_mikrotik" {
  name                     = "samikrotik${var.project}${var.environment}${var.az_region}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sa_container_mikrotik" {
  name                  = "sa-container-mikrotik-${var.project}-${var.environment}-${var.az_region}"
  storage_account_name  = azurerm_storage_account.sa_mikrotik.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "sa_blob_mikrotik" {
  name                   = "mikrotik-image.vhd"
  storage_account_name   = azurerm_storage_account.sa_mikrotik.name
  storage_container_name = azurerm_storage_container.sa_container_mikrotik.name
  type                   = "Page"
  source                 = "../mikrotik/chr-7.10rc6.vhd"
}

resource "azurerm_image" "image_mikrotik" {
  name                = "mikrotik-image-${var.project}-${var.environment}-${var.az_region}"
  hyper_v_generation  = "V1"
  location            = var.location
  resource_group_name = var.resource_group
  zone_resilient      = false
  os_disk {
    blob_uri = azurerm_storage_blob.sa_blob_mikrotik.url
    caching  = "ReadWrite"
    os_state = "Generalized"
    os_type  = "Linux"
    size_gb  = 10
  }

}

resource "azurerm_network_interface" "ip_mikrotik" {
  name                 = "ip-mikrotik-${var.project}-${var.environment}-${var.az_region}"
  location             = var.location
  resource_group_name  = var.resource_group
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ip-mikrotik-${var.project}-${var.environment}-${var.az_region}"
    subnet_id                     = var.az_subnet_id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_virtual_machine" "vm_mikrotik" {
  location              = var.location
  name                  = "vm-chr-${var.project}-${var.environment}-${var.az_region}"
  network_interface_ids = [azurerm_network_interface.ip_mikrotik.id]
  resource_group_name   = var.resource_group
  vm_size               = "Standard_B1s"
  zones = [
    "1",
  ]

  os_profile {
    admin_username = "cloudadmin"
    computer_name  = "vm-mikrotik"
    admin_password = "***"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_image_reference {
    id = azurerm_image.image_mikrotik.id
  }

  storage_os_disk {
    name                      = "disk-os-vm-mikrotik-chr"
    caching                   = "ReadWrite"
    create_option             = "FromImage"
    disk_size_gb              = 10
    managed_disk_type         = "StandardSSD_LRS"
    os_type                   = "Linux"
    write_accelerator_enabled = false
  }
}

resource "azurerm_route_table" "rt_mikrotik" {
  name                          = "rt-chr-${var.project}-${var.environment}-${var.az_region}"
  location                      = var.location
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false

  route {
    name                   = "to_VMWare_Lab"
    address_prefix         = "172.22.22.0/24"
    next_hop_in_ip_address = "172.17.1.6"
    next_hop_type          = "VirtualAppliance"
  }

}

resource "azurerm_subnet_route_table_association" "rt_ass_mikrotik" {
  subnet_id      = var.az_subnet_id
  route_table_id = azurerm_route_table.rt_mikrotik.id
}
