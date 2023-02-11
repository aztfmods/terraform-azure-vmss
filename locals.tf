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