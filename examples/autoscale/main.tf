provider "azurerm" {
  features {}
}

module "rg" {
  source = "github.com/aztfmods/terraform-azure-rg"

  environment = var.environment

  groups = {
    demo = {
      region = "westeurope"
    }
  }
}

module "vnet" {
  source = "github.com/aztfmods/terraform-azure-vnet"

  workload    = var.workload
  environment = var.environment

  vnet = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]
    subnets = {
      internal = {
        cidr = ["10.18.1.0/24"]
      }
    }
  }
  depends_on = [module.rg]
}

module "kv" {
  source = "github.com/aztfmods/terraform-azure-kv"

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
  depends_on = [module.rg]
}

module "vmss" {
  source = "../../"

  workload    = var.workload
  environment = var.environment

  vmss = {
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    keyvault       = module.kv.vault.id

    autoscaling = {
      enable = true
      profile = {
        scale_min = 1
        scale_max = 5
        rules = {
          increase = { metric_name = "Percentage CPU", time_grain = "PT1M", statistic = "Average", time_window = "PT5M", time_aggregation = "Average", operator = "GreaterThan", threshold = 80, direction = "Increase", value = 1, cooldown = "PT1M", type = "ChangeCount" }
          decrease = { metric_name = "Percentage CPU", time_grain = "PT1M", statistic = "Average", time_window = "PT5M", time_aggregation = "Average", operator = "LessThan", threshold = 20, direction = "Decrease", value = 1, cooldown = "PT1M", type = "ChangeCount" }
        }
      }
    }

    network_interfaces = {
      internal = {
        primary = true
        subnet  = module.vnet.subnets.internal.id
      }
    }

    ssh_keys = {
      adminuser = {
        public_key = module.kv.tls_public_key.vmss.value
      }
    }
  }
  depends_on = [module.rg]
}

