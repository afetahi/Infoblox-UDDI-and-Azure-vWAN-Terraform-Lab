
variable "rg_name"  { type = string }
variable "hub_name" { type = string }
variable "peers" {
  type = list(object({
    name = string
    ip   = string
    asn  = number
  }))
}
variable "hub_asn"  { type = number }
variable "anycast"  { type = string }

resource "azurerm_vhub_bgp_connection" "peer" {
  for_each            = { for p in var.peers : p.name => p }
  name                = each.value.name
  virtual_hub_name    = var.hub_name
  resource_group_name = var.rg_name
  peer_asn            = each.value.asn
  peer_ip             = each.value.ip
}

output "status" {
  value = { for k,p in azurerm_vhub_bgp_connection.peer : k => p.provisioning_state }
}
