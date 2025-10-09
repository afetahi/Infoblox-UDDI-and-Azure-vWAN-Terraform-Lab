# =====================================================================================
# Infoblox UDDI + Azure Virtual WAN Anycast Lab
# Terraform Variables
# =====================================================================================

# Azure Subscription (required)
subscription_id = "00000000-0000-0000-0000-000000000000"

# Global naming prefix
prefix         = "iblox-azure-anycast"
anycast_prefix = "10.100.100.10/32"

# =====================================================================================
# Regional configuration
# =====================================================================================

locations = {
  gwc = {
    rg_name  = "rg_hub_gwc_01"
    location = "germanywestcentral"

    hub = {
      name         = "hub_gwc_01"
      address_cidr = "10.110.0.0/22"
      asn          = 65515
    }

    vnet_shared = {
      name = "vnet_shared_gwc"
      cidr = "10.104.0.0/16"
      subnets = {
        niosx = "10.104.0.0/24"
        mgmt  = "10.104.1.0/24"
      }
    }

    vnet_spoke = {
      name = "vnet_spoke_gwc"
      cidr = "10.114.0.0/16"
      subnets = {
        vm = "10.114.0.0/24"
      }
    }

    niosx_bgp_peers = [
      { name = "niosx01azure", ip = "10.104.0.4", asn = 64581 },
      { name = "niosx02azure", ip = "10.104.1.4", asn = 64582 },
    ]
  }

  fra = {
    rg_name  = "rg_hub_fc_01"
    location = "francecentral"

    hub = {
      name         = "hub_fc_01"
      address_cidr = "10.110.4.0/22"
      asn          = 65515
    }

    vnet_shared = {
      name = "vnet_shared_fc"
      cidr = "10.108.0.0/16"
      subnets = {
        niosx = "10.108.0.0/24"
        mgmt  = "10.108.1.0/24"
      }
    }

    vnet_spoke = {
      name = "vnet_spoke_fc"
      cidr = "10.118.0.0/16"
      subnets = {
        vm = "10.118.0.0/24"
      }
    }

    niosx_bgp_peers = [
      { name = "niosx03azure", ip = "10.108.0.4", asn = 64583 },
      { name = "niosx04azure", ip = "10.108.1.4", asn = 64584 },
    ]
  }
}

# =====================================================================================
# NIOS-X Deployment
# =====================================================================================

# Toggle VM deployment (true = deploy NIOS-X from Marketplace)
deploy_niosx_vms = true

# Azure Marketplace image reference for Infoblox NIOS-X
niosx_image = {
  publisher = "infoblox"
  offer     = "nios-x"
  sku       = "byol"
  version   = "latest"
}

# Admin credentials (key-based recommended)
admin_username = "azureuser"
ssh_public_key = "~/.ssh/id_rsa.pub"

# =====================================================================================
# Infoblox Join Token
# =====================================================================================
# Leave this commented out — Terraform will prompt interactively at runtime.
# infoblox_join_token = "dXMtY29tLTE....ibjt"
