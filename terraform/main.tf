resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-devops-lab"
  location = "austriaeast"
  tags = {
    Environment = "Dev"
    Project     = "cloud-devops-lab"
    Day         = "01"
  }
}

module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "dev-vnet"
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = module.vnet.public_subnet_ids[0]
  admin_username      = "azureuser"
  ssh_public_key      = file("~/.ssh/devops_id_rsa.pub")
}
