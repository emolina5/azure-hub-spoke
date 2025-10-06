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

  name                 = each.key
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

resource "azurerm_storage_account" "hub" {
  name                     = "stem5hub${var.environment}"
  resource_group_name      = azurerm_resource_group.hub.name
  location                 = azurerm_resource_group.hub.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "hub" {
  name                  = "terraform"
  storage_account_id    = azurerm_storage_account.hub.id
  container_access_type = "private"
}

resource "azurerm_public_ip" "hub" {
  name                = "pip-hub-${var.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "afw-hub-${var.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku_name            = "AZFW_Hub"
  sku_tier            = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.hub.id
  }
}