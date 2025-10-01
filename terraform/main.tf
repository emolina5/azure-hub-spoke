#### HUB ####
locals {

  hub_vnet         = "10.0.0.0/16"
  hub_subnets      = ["gateway", "firewall"]
  hub_subnets_addr = zipmap(local.hub_subnets, cidrsubnets(local.hub_vnet, 8, 8))

  spokes = {
    compute  = { vnet = "10.1.0.0/16" }
    database = { vnet = "10.2.0.0/16" }
  }

}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-${var.environment}-01"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}-01"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [local.hub_vnet]

}

resource "azurerm_subnet" "hub" {
  for_each = local.hub_subnets_addr

  name                 = "snet-${each.key}-${var.environment}-01"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

#### SPOKES ####

resource "azurerm_resource_group" "spoke" {
  for_each = local.spokes

  name     = "rg-${each.key}-${var.environment}-01"
  location = var.location
}

resource "azurerm_virtual_network" "spoke" {
  for_each = local.spokes

  name                = "vnet-${each.key}-${var.environment}-01"
  location            = azurerm_resource_group.spoke[each.key].location
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  address_space       = [each.value.vnet]

}

resource "azurerm_subnet" "spoke" {
  for_each = local.spokes

  name                 = "snet-default-${var.environment}-01"
  resource_group_name  = azurerm_resource_group.spoke[each.key].name
  virtual_network_name = azurerm_virtual_network.spoke[each.key].name
  address_prefixes     = [cidrsubnet(each.value.vnet, 8, 1)]
}

# PEERING

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  for_each = local.spokes

  name                         = "hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  for_each = local.spokes

  name                         = "${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke[each.key].name
  virtual_network_name         = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}