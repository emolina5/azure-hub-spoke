#### HUB ####
locals {
  hub_vnet         = "10.0.0.0/16"
  hub_subnets      = ["gateway", "firewall","mgmt"]
  hub_subnets_addr = zipmap(local.hub_subnets, cidrsubnets(local.hub_vnet, 8, 8, 8))
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [local.hub_vnet]

}

resource "azurerm_subnet" "hub" {
  for_each = local.hub_subnets_addr

  name                 = "snet-${each.key}-${var.environment}"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}
