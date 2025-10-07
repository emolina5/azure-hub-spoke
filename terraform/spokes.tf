resource "azurerm_resource_group" "spoke" {
  for_each = local.spokes

  name     = "rg-${each.key}-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "spoke" {
  for_each = local.spokes

  name                = "vnet-${each.key}-${var.environment}"
  location            = azurerm_resource_group.spoke[each.key].location
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  address_space       = [each.value.vnet]

}

resource "azurerm_subnet" "spoke" {
  for_each = local.spokes

  name                 = "snet-default-${var.environment}"
  resource_group_name  = azurerm_resource_group.spoke[each.key].name
  virtual_network_name = azurerm_virtual_network.spoke[each.key].name
  address_prefixes     = [cidrsubnet(each.value.vnet, 8, 1)]
}

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

resource "azurerm_storage_account" "spoke" {
  for_each = local.spokes

  name                     = "stem5${each.key}${var.environment}"
  resource_group_name      = azurerm_resource_group.spoke[each.key].name
  location                 = azurerm_resource_group.spoke[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "spoke" {
  for_each = local.spokes

  name                  = "terraform"
  storage_account_id    = azurerm_storage_account.spoke[each.key].id
  container_access_type = "private"
}

resource "azurerm_route_table" "spoke" {
  for_each = local.spokes

  name                = "rt-${each.key}-${var.environment}"
  resource_group_name = azurerm_resource_group.spoke[each.key].name
  location            = azurerm_resource_group.spoke[each.key].location

  route {
    name                   = "route-to-hub"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke" {
  for_each = local.spokes

  subnet_id      = azurerm_subnet.spoke[each.key].id
  route_table_id = azurerm_route_table.spoke[each.key].id
}