provider "azurerm" {
  features {}
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"

  company = "cn"
  env     = "p"
  region  = "weu"

  rgs = {
    demo = { location = "westeurope" }
  }
}

module "vnet" {
  source = "github.com/aztfmods/module-azurerm-vnet"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vnets = {
    location      = module.global.groups.demo.location
    resourcegroup = module.global.groups.demo.name
    cidr          = ["10.18.0.0/16"]
    subnets = {
      internal = {
        cidr = ["10.18.1.0/24"]
        rules = [
          { name = "myhttps", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "443", source_address_prefix = "10.151.1.0/24", destination_address_prefix = "*" },
          { name = "mysql", priority = 200, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "3306", source_address_prefix = "10.0.0.0/24", destination_address_prefix = "*" }
        ]
      }
    }
  }
  depends_on = [module.global]
}

module "kv" {
  source = "github.com/aztfmods/module-azurerm-kv"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vaults = {
    demo = {
      location      = module.global.groups.demo.location
      resourcegroup = module.global.groups.demo.name
      sku           = "standard"
      enable = {
        rbac_auth = true
      }

      contacts = {
        admin = {
          email = "dennis.kool@cloudnation.nl"
        }
      }
    }
  }
  depends_on = [module.global]
}

module "vmss" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vmss = {
    location       = module.global.groups.demo.location
    resource_group = module.global.groups.demo.name
    keyvault       = module.kv.vaults.demo.id

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
      internal = { primary = true, subnet = module.vnet.subnets.internal.id }
    }

    ssh_keys = {
      adminuser = {
        algorithm = "RSA"
        rsa_bits  = 4096
      }
    }
  }
  depends_on = [module.global]
}