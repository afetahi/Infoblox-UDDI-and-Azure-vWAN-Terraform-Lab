
variable "subscription_id" { type = string }
variable "prefix"          { type = string }                  # eg iblox-azure-anycast
variable "anycast_prefix"  { type = string }                  # eg 10.100.100.10/32

variable "locations" {
  description = "Per-region settings"
  type = map(object({
    rg_name  = string
    location = string

    hub = object({
      name         = string
      address_cidr = string         # /22 recommended
      asn          = number         # 16-bit ASN, eg 65515
    })

    vnet_shared = object({
      name    = string
      cidr    = string
      subnets = map(string)        # { "niosx" = "10.x.x.0/24", "mgmt" = "10.x.x.0/24" }
    })

    vnet_spoke = object({
      name    = string
      cidr    = string
      subnets = map(string)        # { "vm" = "10.x.x.0/24" }
    })

    niosx_bgp_peers = list(object({
      name = string
      ip   = string
      asn  = number
    }))
  }))
}

variable "deploy_niosx_vms" {
  type    = bool
  default = false
}

variable "niosx_image" {
  description = "NIOS-X Marketplace image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Optional public key for VM login"
  default     = null
}
