resource "azurerm_public_ip" "fw" {
  name                = "pip-fw-${var.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "afw-hub-${var.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

# to-do: Change to policy and groups
resource "azurerm_firewall_network_rule_collection" "hub" {
  name                = "DefaultNetworkRuleCollectionGroup"
  resource_group_name = azurerm_resource_group.hub.name
  azure_firewall_name = azurerm_firewall.hub.name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "allow-web"
    source_addresses = azurerm_virtual_network.hub.address_space

    destination_ports = [
      "80", "443"
    ]

    destination_addresses = ["*"]

    protocols = [
      "TCP"
    ]
  }
}