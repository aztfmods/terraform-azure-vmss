provider "azurerm" {
  features {}
}

module "rg" {
  source = "github.com/aztfmods/terraform-azure-rg?ref=v0.1.0"

  environment = var.environment

  groups = {
    demo = {
      region = "westeurope"
    }
  }
}

module "vnet" {
  source = "github.com/aztfmods/terraform-azure-vnet?ref=v1.13.0"

  workload    = var.workload
  environment = var.environment

  vnet = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]
    subnets = {
      internal = { cidr = ["10.18.1.0/24"] }
      mgmt     = { cidr = ["10.18.2.0/24"] }
    }
  }
}

module "kv" {
  source = "github.com/aztfmods/terraform-azure-kv?ref=v1.9.0"

  workload    = var.workload
  environment = var.environment

  vault = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

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

}

module "scaleset" {
  #source = "github.com/aztfmods/terraform-azure-vmss?ref=v1.4.0"
  source      = "../../"
  workload    = var.workload
  environment = var.environment

  vmss = {
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    keyvault       = module.kv.vault.id

    interfaces = {
      internal = { subnet = module.vnet.subnets.internal.id, primary = true }
      mgmt     = { subnet = module.vnet.subnets.mgmt.id }
    }

    extensions = {
      DAExtension = {
        publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
        type                 = "DependencyAgentLinux"
        type_handler_version = "9.5"
      }
    }

    ssh_keys = {
      adminuser = {
        public_key = module.kv.tls_public_key.vmss.value
      }
    }
  }
}
