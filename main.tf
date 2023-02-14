#----------------------------------------------------------------------------------------
# generate keys
#----------------------------------------------------------------------------------------

resource "tls_private_key" "key" {
  for_each = {
    for k, v in var.vmss.ssh_keys : k => v
  }

  algorithm = each.value.algorithm
  rsa_bits  = each.value.rsa_bits
}

#----------------------------------------------------------------------------------------
# secrets
#----------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "public_key" {
  for_each = {
    for k, v in var.vmss.ssh_keys : k => v
  }

  name         = "${each.key}-pub"
  value        = tls_private_key.key[each.key].public_key_pem
  key_vault_id = var.vmss.keyvault
}

#----------------------------------------------------------------------------------------
# Generate random id
#----------------------------------------------------------------------------------------

resource "random_string" "random" {
  length    = 4
  min_lower = 4
  special   = false
  numeric   = false
  upper     = false
}

#----------------------------------------------------------------------------------------
# virtual machine scale set
#----------------------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "vmss-${var.company}-${random_string.random.result}"
  resource_group_name = var.vmss.resource_group
  location            = var.vmss.location

  sku                             = try(var.vmss.sku, "Standard_F2")
  instances                       = try(var.vmss.instances, 2)
  admin_username                  = try(var.vmss.admin_username, "adminuser")
  disable_password_authentication = try(var.vmss.disable_password_authentication, true)
  upgrade_mode                    = try(var.vmss.upgrade_mode, "Automatic")
  provision_vm_agent              = try(var.vmss.provision_vm_agent, true)
  platform_fault_domain_count     = try(var.vmss.platform_fault_domain_count, 5)
  priority                        = try(var.vmss.priority, "Regular")
  secure_boot_enabled             = try(var.vmss.secure_boot_enabled, false)
  vtpm_enabled                    = try(var.vmss.vtpm_enabled, false)
  zone_balance                    = try(var.vmss.zone_balance, false)
  edge_zone                       = try(var.vmss.edge_zone, null)
  encryption_at_host_enabled      = try(var.vmss.encryption_at_host_enabled, false)
  extension_operations_enabled    = try(var.vmss.extension_operations_enabled, true)
  extensions_time_budget          = try(var.vmss.extensions_time_budget, "PT1H30M")
  overprovision                   = try(var.vmss.overprovision, true)
  zones                           = try(var.vmss.zones, ["1", "2", "3"])

  dynamic "admin_ssh_key" {
    for_each = {
      for key in local.ssh_keys : key.ssh_key => key
    }

    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key
    }
  }

  source_image_reference {
    publisher = try(var.vmss.image.publisher, "Canonical")
    offer     = try(var.vmss.image.offer, "UbuntuServer")
    sku       = try(var.vmss.image.sku, "18.04-LTS")
    version   = try(var.vmss.image.version, "latest")
  }

  os_disk {
    storage_account_type = try(var.vmss.os_disk.storage_account_type, "Standard_LRS")
    caching              = try(var.vmss.os_disk.caching, "ReadWrite")
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
        subnet_id = network_interface.value.subnet_id
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