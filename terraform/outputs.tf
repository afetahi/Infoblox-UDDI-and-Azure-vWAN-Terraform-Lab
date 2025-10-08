
output "hub_ids"      { value = { for k,v in module.vwan.hubs : k => v.id } }
output "hub_names"    { value = { for k,v in module.vwan.hubs : k => v.name } }
output "spoke_rt"     { value = module.hub_connections.rt_names }
output "bgp_peers"    { value = { for k,v in module.hub_bgp.status : k => v } }
output "anycast"      { value = var.anycast_prefix }
