resource "azurerm_resource_group" "onprem" {
  name     = "rg-onprem-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "onprem" {
  name                = "vnet-onprem-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.onprem.name
  address_space       = [local.onprem_vnet]
}

resource "azurerm_subnet" "onprem" {
  for_each = local.onprem_subnets_addr

  name                 = "snet-${each.key}-${var.environment}"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = [each.value]
}

resource "azurerm_virtual_network_peering" "hub-to-onprem" {
  name                         = "hub-to-onprem"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.onprem.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "onprem-to-hub" {
  for_each = local.spokes

  name                         = "onprem-to-hub"
  resource_group_name          = azurerm_resource_group.onprem.name
  virtual_network_name         = azurerm_virtual_network.onprem.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
