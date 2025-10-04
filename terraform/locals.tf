locals {
  hub_vnet    = "10.0.0.0/16"
  hub_subnets = ["gateway", "firewall", "mgmt"]
  hub_subnets_addr = zipmap(local.hub_subnets,
    [for idx, subnets in local.hub_subnets : cidrsubnet(local.hub_vnet, 8, idx)]
  )

  onprem_vnet    = "192.168.0.0/16"
  onprem_subnets = ["gateway", "mgmt"]
  onprem_subnets_addr = zipmap(local.onprem_subnets,
    [for i, s in local.onprem_subnets : cidrsubnet(local.onprem_vnet, 8, i)]
  )

  spokes = {
    compute  = { vnet = "10.1.0.0/16" }
    database = { vnet = "10.2.0.0/16" }
  }

}
