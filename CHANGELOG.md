# Changelog

## [1.6.0](https://github.com/aztfmods/terraform-azure-vmss/compare/v1.5.0...v1.6.0) (2023-08-06)


### Features

* grouped tests together and added a small check to ensured the right azure abbreviation is used ([#44](https://github.com/aztfmods/terraform-azure-vmss/issues/44)) ([d5cc01b](https://github.com/aztfmods/terraform-azure-vmss/commit/d5cc01bacbc0241bb25e37d44b0f63085366fae0))

## [1.5.0](https://github.com/aztfmods/terraform-azure-vmss/compare/v1.4.0...v1.5.0) (2023-08-05)


### Features

* add extended tests ([#42](https://github.com/aztfmods/terraform-azure-vmss/issues/42)) ([974f643](https://github.com/aztfmods/terraform-azure-vmss/commit/974f6433e5636016ceb446fe48697a9a08640fa2))

## [1.4.0](https://github.com/aztfmods/terraform-azure-vmss/compare/v1.3.1...v1.4.0) (2023-07-05)


### Features

* change data structure abit regarding interfaces ([#41](https://github.com/aztfmods/terraform-azure-vmss/issues/41)) ([15e6a23](https://github.com/aztfmods/terraform-azure-vmss/commit/15e6a232c55a5c9eaf7b6e8125fceea84b562968))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#37](https://github.com/aztfmods/terraform-azure-vmss/issues/37)) ([504dfbb](https://github.com/aztfmods/terraform-azure-vmss/commit/504dfbb589c8caf0be1c36ba29a38f4191ee2ffa))
* solve linting issues and update documentation ([#39](https://github.com/aztfmods/terraform-azure-vmss/issues/39)) ([b72bd6f](https://github.com/aztfmods/terraform-azure-vmss/commit/b72bd6f9e56b8f82c94e58422bc6341a875d69ed))

## [1.3.1](https://github.com/aztfmods/module-azurerm-linux-vmss/compare/v1.3.0...v1.3.1) (2023-03-23)


### Bug Fixes

* ignore the instances count on the scaleset itself in case autoscaling is used ([#23](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/23)) ([7d80c32](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/7d80c329886e6801e9c7ab88a6b135063416d676))

## [1.3.0](https://github.com/aztfmods/module-azurerm-linux-vmss/compare/v1.2.0...v1.3.0) (2023-03-23)


### Features

* small refactor public ssh keys ([#20](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/20)) ([c6e9da8](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/c6e9da82c6c014fa4470e8108ec16002a817fc21))

## [1.2.0](https://github.com/aztfmods/module-azurerm-linux-vmss/compare/v1.1.0...v1.2.0) (2023-02-21)


### Features

* add azurerm_monitor_autoscale_setting support ([#14](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/14)) ([a3d2b56](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/a3d2b56638796075975b6460db35c73ffd606f90))
* add network_interface dynamic blocks ([#9](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/9)) ([2c4f725](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/2c4f725d2eae966eda17a093bd8336ad1ed6fd27))
* small refactor due to vnet module ([#13](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/13)) ([d65765f](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/d65765f50f20d4b5bc64c4b927f733988b12f49a))

## [1.1.0](https://github.com/aztfmods/module-azurerm-linux-vmss/compare/v1.0.0...v1.1.0) (2023-02-14)


### Features

* add extension support ([#7](https://github.com/aztfmods/module-azurerm-linux-vmss/issues/7)) ([d6fe6b1](https://github.com/aztfmods/module-azurerm-linux-vmss/commit/d6fe6b1b3f54205ebc4237e78a92c0824fb80a06))

## 1.0.0 (2023-02-14)


### Features

* add documentation ([#4](https://github.com/aztfmods/module-azurerm-vmss/issues/4)) ([02e48df](https://github.com/aztfmods/module-azurerm-vmss/commit/02e48dfcfbdb449e8d9417e29f9467565df95169))
* add release workflow ([#1](https://github.com/aztfmods/module-azurerm-vmss/issues/1)) ([203bfde](https://github.com/aztfmods/module-azurerm-vmss/commit/203bfded5bad39ff53457ce8de17155a3bf90f1c))
* add validation workflow ([#5](https://github.com/aztfmods/module-azurerm-vmss/issues/5)) ([03d434f](https://github.com/aztfmods/module-azurerm-vmss/commit/03d434f0e83e14f22ca5b40eaa66d5426dca4259))


### Bug Fixes

* change directory structure examples ([#6](https://github.com/aztfmods/module-azurerm-vmss/issues/6)) ([0516ebc](https://github.com/aztfmods/module-azurerm-vmss/commit/0516ebce34bfa1d3efde8bb48452a680fc20f665))
