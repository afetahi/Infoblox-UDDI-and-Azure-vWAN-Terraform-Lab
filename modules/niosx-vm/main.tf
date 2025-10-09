############################################
# NIOS-X VM Deployment (Azure Marketplace)
# -----------------------------------------
# NOTE:
# - This module deploys NIOS-X VMs from the Azure Marketplace.
# - DNS, Anycast, and BGP config remain MANUAL via UDDI/appliance.
# - NIC IP forwarding is supported (required for Anycast).
############################################

variable "rg_name"   { type = string }
variable "location"  { type = string }
variable "subnet_id" { type = string }

# Marketplace (or shared image) reference
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

# If your Marketplace image requires a plan, set true
variable "image_requires_plan" {
  type    = bool
  default = true
}

variable "admin_username" { type = string }

# Auth: provide ONE of these
variable "ssh_public_key" {
  description = "Public SSH key content; if set, password auth is disabled"
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
  description = "VM size (Infoblox doc recommends Standard_F8s; keep your choice if preferred)"
  type        = string
  default     = "Standard_D4s_v5"
}

# Enable NIC IP forwarding for Anycast/routing
variable "enable_ip_forwarding" {
  type    = bool
  default = true
}

# Optional join token (interactive at root by leaving null)
variable "join_token" {
  description = "Infoblox join token (injected via cloud-init)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

############################################
# Network Interface (with IP forwarding)
############################################
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name_prefix}-nic"
  resource_group_name = var.rg_name
  location            = var.location
  ip_forwarding_enabled = var.enable_ip_forwarding
  
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

############################################
# Linux VM
############################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.vm_name_prefix}-vm"
  resource_group_name   = var.rg_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Auth model: SSH key OR password
  disable_password_authentication = var.ssh_public_key != null
  admin_password                  = var.admin_password

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

  # Marketplace plan (when required)
  dynamic "plan" {
    for_each = var.image_requires_plan ? [1] : []
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

  # Inject join_token into cloud-init
  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    join_token = coalesce(var.join_token, "")
  }))

  tags = var.tags

  lifecycle {
    precondition {
      condition     = (var.ssh_public_key != null) || (var.admin_password != null)
      error_message = "Provide either ssh_public_key or admin_password for the VM."
    }
  }
}

############################################
# Outputs
############################################
output "private_ip" {
  description = "The private IP address of the NIOS-X VM"
  value       = azurerm_network_interface.nic.private_ip_address
}
