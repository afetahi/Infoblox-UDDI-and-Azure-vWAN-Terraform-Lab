# NOTE: This module only deploys NIOS-X virtual machines (from Azure Marketplace).
# DNS service enablement, Anycast configuration, and BGP peering must be done manually
# through the Infoblox UDDI portal or directly on the appliance.

variable "rg_name"   { type = string }
variable "location"  { type = string }
variable "subnet_id" { type = string }

# Image reference for Marketplace or Shared Gallery
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "admin_username" { type = string }

# Provide one of these auth methods:
variable "ssh_public_key" {
  description = "Public SSH key; if set, password auth is disabled"
  type        = string
  default     = null
}

variable "admin_password" {
  description = "Admin password; required if ssh_public_key is null"
  type        = string
  default     = null
  sensitive   = true
}

variable "vm_name_prefix" { type = string }
variable "vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name_prefix}-nic"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_name_prefix}-vm"
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Enforce valid auth combo
  disable_password_authentication = var.ssh_public_key != null

  # Only set when a password is provided
  dynamic "admin_password" {
    for_each = var.ssh_public_key == null && var.admin_password != null ? [1] : []
    content  = var.admin_password
  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key != null ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  # If the Marketplace image requires plan terms, include this block.
  # (name = sku, product = offer, publisher = publisher)
  dynamic "plan" {
    for_each = [1] # set to [] if your image does not require a plan
    content {
      name      = var.image.sku
      product   = var.image.offer
      publisher = var.image.publisher
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # cloud-init (must be base64 for azurerm_linux_virtual_machine)
  custom_data = filebase64("${path.module}/cloud-init.tpl")

  tags = var.tags

  lifecycle {
    precondition {
      condition     = (var.ssh_public_key != null) || (var.admin_password != null)
      error_message = "Provide either ssh_public_key or admin_password for the VM."
    }
  }
}
