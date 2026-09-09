resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-devops-lab"
  location = "italynorth"
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
