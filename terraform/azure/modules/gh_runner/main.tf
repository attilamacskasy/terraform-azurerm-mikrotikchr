resource "azurerm_network_interface" "gh_runner_nic" {
  name                = "vmnic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gh_runner" {
  name                = var.vm_name
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.gh_runner_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.vm_name}_disk1"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

# I will do this in next pipeline making sure we have a little success of deploying 2nd VM in Azure (vm-gh-runner)
/*
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y curl jq git

    useradd -m runner
    cd /home/runner

    curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64-2.316.0.tar.gz
    tar xzf ./actions-runner-linux-x64.tar.gz
    chown -R runner:runner /home/runner

    sudo -u runner ./config.sh --url https://github.com/${var.github_repo} --token ${var.github_runner_token} --unattended --name ${var.vm_name}
    sudo -u runner ./run.sh &
  EOF
  )
*/

  tags = {
    Role = "GitHubSelfHostedRunner"
  }
}
