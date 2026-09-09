# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Public / Default Subnet (10.0.0.0/24)
resource "azurerm_subnet" "public" {
  count                = length(var.public_subnet_prefixes)
  name                 = "snet-public-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_prefixes[count.index]]
}

# Private Subnet (10.0.2.0/24)
resource "azurerm_subnet" "private" {
  count                = length(var.private_subnet_prefixes)
  name                 = "snet-private-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_prefixes[count.index]]
}
