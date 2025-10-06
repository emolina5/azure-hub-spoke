locals {
  hub_vnet    = "10.0.0.0/16"
  hub_subnets = ["GatewaySubnet", "AzureFirewallSubnet"]
  hub_subnets_addr = zipmap(local.hub_subnets,
    [for idx, subnets in local.hub_subnets : cidrsubnet(local.hub_vnet, 8, idx)]
  )

  spokes = {
    compute  = { vnet = "10.1.0.0/16" }
    database = { vnet = "10.2.0.0/16" }
  }

}
