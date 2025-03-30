resource "azurerm_image" "image_mikrotik" {
  hyper_v_generation  = "V2"
  name                = var.azurerm_image_name
  location            = var.location
  resource_group_name = var.resource_group
  tags                = {}
  zone_resilient      = false

  os_disk {
    storage_type  = "Standard_LRS"
    blob_uri      = "https://mikrotikchrstorage01.blob.core.windows.net/vhds/chr-7.18.2.vhd"
    caching       = "ReadWrite"
    os_state      = "Generalized"
    os_type       = "Linux"
    size_gb       = 1
  }
}

resource "azurerm_network_interface" "ip_mikrotik" {
  name                  = var.azurerm_network_interface_name
  location              = var.location
  resource_group_name   = var.resource_group
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.az_subnet_id
    private_ip_address_allocation = "Dynamic" # or Static 

  }
}

resource "azurerm_virtual_machine" "vm_mikrotik" {
  location              = var.location
  name                  = var.azurerm_virtual_machine_name
  network_interface_ids = [azurerm_network_interface.ip_mikrotik.id]
  resource_group_name   = var.resource_group
  vm_size               = var.azurerm_virtual_machine_vm_size
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
    name                      = var.storage_os_disk_name
    caching                   = "ReadWrite"
    create_option             = "FromImage"
    disk_size_gb              = 10
    managed_disk_type         = var.storage_os_disk_managed_disk_type
    os_type                   = "Linux"
    write_accelerator_enabled = false
  }
}

resource "azurerm_route_table" "rt_mikrotik" {
  name                          = var.azurerm_route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group
  #BGP route propagation is turned ON 
  #disable_bgp_route_propagation = false
  bgp_route_propagation_enabled = true
  route {
    name                   = "to_onpremises_lab"
    address_prefix         = "172.22.22.0/24"
    next_hop_in_ip_address = "172.30.1.4"
    next_hop_type          = "VirtualAppliance"
  }
}

resource "azurerm_subnet_route_table_association" "rt_ass_mikrotik" {
  subnet_id      = var.az_subnet_id
  route_table_id = azurerm_route_table.rt_mikrotik.id
}
