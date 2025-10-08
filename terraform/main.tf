
# Global VWAN & Hubs
module "vwan" {
  source  = "../modules/vwan"
  prefix  = var.prefix
  regions = var.locations
}

# Shared & Spoke VNets
module "shared_vnets" {
  source   = "../modules/vnet"
  for_each = var.locations
  rg_name  = each.value.rg_name
  location = each.value.location
  vnet     = each.value.vnet_shared
}

module "spoke_vnets" {
  source   = "../modules/vnet"
  for_each = var.locations
  rg_name  = each.value.rg_name
  location = each.value.location
  vnet     = each.value.vnet_spoke
}

# VNet → Hub connections and route-table associations
module "hub_connections" {
  source   = "../modules/hub-connections"
  for_each = var.locations

  rg_name     = each.value.rg_name
  hub_id      = module.vwan.hubs[each.key].id
  hub_name    = module.vwan.hubs[each.key].name
  vnet_shared = module.shared_vnets[each.key].vnet
  vnet_spoke  = module.spoke_vnets[each.key].vnet

  # policy: Shared to Default RT, Spokes to custom Spoke RT
  use_default_for_shared = true
  spoke_rt_name          = "rt-spokes-${each.key}"
}

# vHub BGP peers to NIOS-X appliances
module "hub_bgp" {
  source   = "../modules/hub-bgp"
  for_each = var.locations

  rg_name   = each.value.rg_name
  hub_name  = each.value.hub.name
  peers     = each.value.niosx_bgp_peers
  hub_asn   = each.value.hub.asn
  anycast   = var.anycast_prefix
}

# Optional: deploy NIOS-X VMs
module "niosx_vms" {
  source          = "../modules/niosx-vm"
  for_each        = var.deploy_niosx_vms ? var.locations : {}
  rg_name         = each.value.rg_name
  location        = each.value.location
  subnet_id       = module.shared_vnets[each.key].subnets["niosx"]
  image           = var.niosx_image
  admin_username  = var.admin_username
  ssh_public_key  = var.ssh_public_key
  vm_name_prefix  = "niosx-${each.key}"
}
