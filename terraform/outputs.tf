# vWAN
output "virtual_wan_name" {
  description = "The name of the Azure Virtual WAN deployed."
  value       = module.vwan.vwan_name
}

# Hubs
output "hub_names" {
  description = "Names of all vWAN hubs deployed per region."
  value       = module.vwan.hub_names
}

output "hub_ids" {
  description = "Resource IDs of all Azure Virtual Hubs."
  value       = module.vwan.hub_ids
}

# BGP router IPs per hub (use these as peers on NIOS-X)
output "hub_bgp_peering_ips" {
  description = "BGP router IPs per hub region to be used as peers in NIOS-X."
  value       = module.vwan.hub_bgp_router_ips
}

# Shared VNet names by region.
output "shared_vnet_names" {
  value = { for k, m in module.shared_vnets : k => m.vnet.name }
}

# Spoke VNet names by region.
output "spoke_vnet_names" {
  value = { for k, m in module.spoke_vnets : k => m.vnet.name }
}

# Hub-to-VNet connection names per region (requires module output below).
output "hub_connection_names" {
  value = { for k, m in module.hub_connections : k => m.connection_names }
}

# Optional: NIOS-X VM private IPs (only if deployed)
output "niosx_vm_private_ips" {
  description = "Private IPs of NIOS-X VMs by region (empty if not deployed)."
  value       = try({ for k, m in module.niosx_vms : k => m.private_ip }, {})
}

# Path to the generated private keys (sensitive)
output "ssh_key_paths" {
  description = "Local paths to the generated SSH private keys per region"
  value       = { for k in keys(var.locations) : k => local_sensitive_file.niosx_private_key[k].filename }
  sensitive   = true
}

# Convenience SSH commands using generated keys (private connectivity required)
output "ssh_commands" {
  description = "SSH commands to reach NIOS-X (needs private path/VPN/ER/Bastion)"
  value = {
    for k, m in module.niosx_vms :
    k => "ssh -i ${local_sensitive_file.niosx_private_key[k].filename} ${var.admin_username}@${m.private_ip}"
  }
}