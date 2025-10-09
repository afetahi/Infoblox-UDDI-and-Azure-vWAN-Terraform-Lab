
# Azure vWAN Anycast DNS Lab Outputs


# Virtual WAN info
output "virtual_wan_name" {
  description = "The name of the Azure Virtual WAN deployed."
  value       = azurerm_virtual_wan.vwan.name
}

# Hub information
output "hub_names" {
  description = "Names of all vWAN hubs deployed per region."
  value       = { for k, v in azurerm_virtual_hub.hub : k => v.name }
}

output "hub_ids" {
  description = "Resource IDs of all Azure Virtual Hubs."
  value       = { for k, v in azurerm_virtual_hub.hub : k => v.id }
}

# BGP peer IPs for manual NIOS-X configuration
output "hub_bgp_peering_ips" {
  description = "BGP router IPs per hub region to be used as peers in NIOS-X."
  value = {
    for k, v in azurerm_virtual_hub.hub :
    k => v.virtual_router_ips
  }
}

# VNets and connection info
output "vnet_names" {
  description = "Deployed VNets per region."
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.name }
}

output "hub_connection_names" {
  description = "Hub-to-VNet connection names per region."
  value       = { for k, v in azurerm_virtual_hub_connection.connection : k => v.name }
}

# Optional: NIOS-X VM private IPs (if deployed)
output "niosx_vm_private_ips" {
  description = "Private IPs of NIOS-X VMs, useful for manual configuration."
  value       = can(azurerm_network_interface.niosx) ? { for k, v in azurerm_network_interface.niosx : k => v.private_ip_address } : {}
}

# Note: Validation (BGP session state, routes, Anycast reachability)
# must be performed manually after NIOS-X configuration.

