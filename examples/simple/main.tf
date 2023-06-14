provider "azurerm" {
  features {}
}

module "region" {
  source = "github.com/aztfmods/module-azurerm-regions"

  workload    = var.workload
  environment = var.environment

  location = "westeurope"
}

module "rg" {
  source = "github.com/aztfmods/module-azurerm-rg"

  workload       = var.workloadj
  environment    = var.environment
  location_short = module.region.location_short
  location       = module.region.location
}

module "vnet" {
  source = "github.com/aztfmods/module-azurerm-vnet"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  vnet = {
    location      = module.rg.group.location
    resourcegroup = module.rg.group.name
    cidr          = ["10.18.0.0/16"]
    subnets = {
      internal = { cidr = ["10.18.1.0/24"] }
    }
  }
  depends_on = [module.rg]
}

module "kv" {
  source = "github.com/aztfmods/module-azurerm-kv"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  vault = {
    location      = module.rg.group.location
    resourcegroup = module.rg.group.name

    secrets = {
      tls_public_key = {
        vmss = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }

    contacts = {
      admin = {
        email = "dummy@cloudnation.nl"
      }
    }
  }
  depends_on = [module.rg]
}

module "vmss" {
  source = "../../"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  vmss = {
    location       = module.rg.group.location
    resource_group = module.rg.group.name
    keyvault       = module.kv.vault.id

    network_interfaces = {
      internal = { primary = true, subnet = module.vnet.subnets.internal.id }
    }

    ssh_keys = {
      adminuser = {
        public_key = module.kv.tls_public_key.vmss.value
      }
    }
  }
  depends_on = [module.rg]
}
