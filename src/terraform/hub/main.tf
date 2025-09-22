resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-dev-01"
  location = "North Europe"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-dev-01"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each = {
    gw = "10.0.0.0/24"
    fw = "10.0.1.0/24"
  }
  name                 = "snet-${each.key}-dev-01"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value
}