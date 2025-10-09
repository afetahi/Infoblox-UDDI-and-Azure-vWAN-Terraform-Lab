variable "rg_name"   { type = string } # kept for compatibility (not used by resource)
variable "hub_id"    { type = string } # <-- use hub_id
variable "peers" {
  type = list(object({
    name = string
    ip   = string
    asn  = number
  }))
}
variable "hub_asn"  { type = number }
variable "anycast"  { type = string }

# Provider uses 'azurerm_virtual_hub_bgp_connection'
resource "azurerm_virtual_hub_bgp_connection" "peer" {
  for_each        = { for p in var.peers : p.name => p }
  name            = each.value.name
  virtual_hub_id  = var.hub_id
  peer_asn        = each.value.asn
  peer_ip         = each.value.ip
}

output "bgp_connection_ids" {
  description = "IDs of BGP connections per peer name"
  value       = { for k, p in azurerm_virtual_hub_bgp_connection.peer : k => p.id }
}

# (Optional) names too
output "bgp_connection_names" {
  value = [for p in azurerm_virtual_hub_bgp_connection.peer : p.name]
}