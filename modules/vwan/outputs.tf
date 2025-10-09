output "vwan_name" {
  description = "Name of the Virtual WAN"
  value       = azurerm_virtual_wan.wan.name
}

output "hub_names" {
  description = "Hub names per region key"
  value       = { for k, h in azurerm_virtual_hub.hub : k => h.name }
}

output "hub_ids" {
  description = "Hub resource IDs per region key"
  value       = { for k, h in azurerm_virtual_hub.hub : k => h.id }
}

output "hub_bgp_router_ips" {
  description = "vHub router IPs (two per hub) per region key"
  value       = { for k, h in azurerm_virtual_hub.hub : k => h.virtual_router_ips }
}
