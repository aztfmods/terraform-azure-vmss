data "azurerm_client_config" "current" {}

#----------------------------------------------------------------------------------------
# resourcegroups
#----------------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.vmss.resourcegroup
  location = var.vmss.location
}

#----------------------------------------------------------------------------------------
# existing
#----------------------------------------------------------------------------------------

data "azurerm_subnet" "subnet" {
  name                 = var.vmss.existing.network.subnet
  virtual_network_name = var.vmss.existing.network.vnet
  resource_group_name  = var.vmss.existing.network.rg
}

data "azurerm_key_vault" "vault" {
  name                = var.vmss.existing.vault.name
  resource_group_name = var.vmss.existing.vault.rg
}

#----------------------------------------------------------------------------------------
# generate keys / secrets
#----------------------------------------------------------------------------------------

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "privatekey" {
  name         = "private-key"
  value        = tls_private_key.key.private_key_pem
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "public_key" {
  name         = "public-key"
  value        = tls_private_key.key.public_key_pem
  key_vault_id = data.azurerm_key_vault.vault.id
}

#----------------------------------------------------------------------------------------
# virtual machine scale set
#----------------------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "vmss-bla"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  sku                             = var.vmss.sku
  instances                       = var.vmss.instances
  disable_password_authentication = true
  admin_username                  = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.key.public_key_openssh
  }

  source_image_reference {
    publisher = var.vmss.image.publisher
    offer     = var.vmss.image.offer
    sku       = var.vmss.image.sku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  dynamic "network_interface" {
    for_each = {
      for nic in local.interfaces : nic.interface_key => nic
    }

    content {
      name                          = network_interface.value.nic_name
      primary                       = network_interface.value.primary
      dns_servers                   = network_interface.value.dns_servers
      enable_accelerated_networking = network_interface.value.enable_accelerated_networking
      enable_ip_forwarding          = network_interface.value.enable_ip_forwarding

      ip_configuration {
        name      = network_interface.value.ipconf_name
        primary   = true
        subnet_id = data.azurerm_subnet.subnet.id
      }
    }
  }

  dynamic "data_disk" {
    for_each = {
      for disk in local.data_disks : disk.disk_key => disk
    }

    content {
      caching              = data_disk.value.caching
      create_option        = data_disk.value.create_option
      disk_size_gb         = data_disk.value.disk_size_gb
      lun                  = data_disk.value.lun
      storage_account_type = data_disk.value.storage_account_type
    }
  }
}