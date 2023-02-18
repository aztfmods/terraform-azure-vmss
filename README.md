# Virtual Machine Scale Sets

This terraform module enables flexible and efficient management of virtual machine scale sets on azure through customizable configuration options.

The below features are made available:

- multiple ssh keys
- multiple network interfaces
- multiple data disks
- multiple extensions
- terratest is used to validate different integrations

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "vmss" {
  source = "../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vmss = {
    location       = module.global.groups.demo.location
    resource_group = module.global.groups.demo.name
    keyvault       = module.kv.vaults.demo.id

    network_interfaces = {
      internal = { primary = true, subnet = module.vnet.subnets["demo.sn1"].id }
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
```

## Usage: network interfaces

```hcl
module "vmss" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vmss = {
    location       = module.global.groups.demo.location
    resource_group = module.global.groups.demo.name
    keyvault       = module.kv.vaults.demo.id

    network_interfaces = {
      internal = { primary = true, subnet = module.vnet.subnets["demo.sn1"].id }
      mgmt     = { primary = false, subnet = module.vnet.subnets["demo.sn2"].id }
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
```

## Usage: data disks

```hcl
module "vmss" {
  source = "../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vmss = {
    location       = module.global.groups.demo.location
    resource_group = module.global.groups.demo.name
    keyvault       = module.kv.vaults.demo.id

    data_disks = {
      disk1 = { lun = 10, caching = "ReadWrite" }
      disk2 = { lun = 11, caching = "ReadWrite" }
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
```

## Usage: extensions

```hcl
module "vmss" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vmss = {
    location       = module.global.groups.demo.location
    resource_group = module.global.groups.demo.name
    keyvault       = module.kv.vaults.demo.id

    network_interfaces = {
      nic0 = { primary = true, subnet = module.vnet.subnets["demo.sn1"].id }
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
        algorithm = "RSA"
        rsa_bits  = 4096
      }
    }
  }
  depends_on = [module.global]
}
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `vmss` | describes the virtual machine scale set related configuration | object | yes |
| `company` | contains the company name used, for naming convention	| string | yes |
| `region` | contains the shortname of the region, used for naming convention	| string | yes |
| `env` | contains shortname of the environment used for naming convention	| string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `vmss` | contains all virtual machine scale sets |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-vmss/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-vmss/blob/main/LICENSE) for full details.