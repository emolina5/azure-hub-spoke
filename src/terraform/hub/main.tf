#### HUB ####
locals {
  map = zipmap(["gw", "fw"], cidrsubnets("10.0.0.0/16", 8, 8))

  spokes = {
    spoke1 = {
      vnet = "10.1.0.0/16"
    }
    spoke2 = {
      vnet = "10.2.0.0/16"
    }
  }

}

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

resource "azurerm_subnet" "hub" {
  for_each             = local.map
  name                 = "snet-${each.key}-dev-01"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

#### SPOKES ####

resource "azurerm_resource_group" "spoke" {
  for_each = local.spokes

  name     = "rg-${each.key}-dev-01"
  location = "North Europe"
}



resource "azurerm_virtual_network" "spoke" {
  for_each            = local.spokes

  name                = "vnet-${each.key}-dev-01"
  location            = azurerm_resource_group.spoke[each.key].location
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  address_space       = [each.value.vnet]

}

resource "azurerm_subnet" "spoke" {
  for_each             = local.spokes

  name                 = "snet-default-dev-01"
  resource_group_name  = azurerm_resource_group.spoke[each.key].name
  virtual_network_name = azurerm_virtual_network.spoke[each.key].name
  address_prefixes     = [cidrsubnet(each.value.vnet, 8, 1)]
}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  for_each                     = local.spokes

  name                         = "hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  for_each                     = local.spokes

  name                         = "${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke[each.key].name
  virtual_network_name         = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}