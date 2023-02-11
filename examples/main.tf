provider "azurerm" {
  features {}
}

module "scaleset" {
  source = "../"

  vmss = {
    rgname    = "rg-vmss-demo"
    location  = "westeurope"
    instances = 3

    network = { rg = "rg-networking-demo", vnet = "vmss-demo", subnet = "internal" }
    vault   = { rg = "rg-networking-demo", name = "kvdemodsdcv" }

    network_interfaces = {
      nic0 = { primary = true, enable_accelerated_networking = true }
      nic1 = { primary = false }
    }

    data_disks = {
      disk1 = { lun = 10, caching = "ReadWrite" }
      disk2 = { lun = 11, caching = "ReadWrite" }
    }

    ssh_keys = {
      rsa1 = { algorithm = "RSA", rsa_bits = 4096 }
      rsa2 = { algorithm = "RSA", rsa_bits = 4096 }
    }
  }
}