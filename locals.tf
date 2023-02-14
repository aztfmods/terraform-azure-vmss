locals {
  interfaces = flatten([
    for interface_key, nic in var.vmss.network_interfaces : {

      interface_key                 = interface_key
      nic_name                      = "nic-${interface_key}"
      primary                       = nic.primary
      ipconf_name                   = "ipconf-${interface_key}"
      dns_servers                   = try(nic.dns_servers, [])
      enable_accelerated_networking = try(nic.enable_accelerated_networking, false)
      enable_ip_forwarding          = try(nic.enable_ip_forwarding, false)
      subnet_id                     = nic.subnet
    }
  ])
}

locals {
  data_disks = flatten([
    for disk_key, disk in try(var.vmss.data_disks, {}) : {

      disk_key             = disk_key
      caching              = disk.caching
      create_option        = try(disk.create_option, "Empty")
      disk_size_gb         = try(disk.disk_size_gb, 10)
      lun                  = disk.lun
      storage_account_type = try(disk.storage_account_type, "Standard_LRS")
    }
  ])
}

locals {
  ssh_keys = flatten([
    for ssh_key, ssh in var.vmss.ssh_keys : {

      ssh_key    = ssh_key
      username   = ssh_key
      public_key = tls_private_key.key[ssh_key].public_key_openssh
      algorithm  = try(ssh.algorithm, "RSA")
      rsa_bits   = try(ssh.rsa_bits, 4096)
    }
  ])
}

locals {
  ext_keys = flatten([
    for ext_key, ext in try(var.vmss.extensions, {}) : {

      ext_key                    = ext_key
      name                       = ext_key
      publisher                  = ext.publisher
      type                       = ext.type
      type_handler_version       = ext.type_handler_version
      auto_upgrade_minor_version = try(ext.auto_upgrade_minor_version, true)
      automatic_upgrade_enabled  = try(ext.automatic_upgrade_enabled, false)
      force_update_tag           = try(ext.force_update_tag, null)
      protected_settings         = try(ext.protected_settings, null)
      provision_after_extensions = try(ext.provision_after_extensions, null)
      settings                   = try(ext.settings, null)
    }
  ])
}