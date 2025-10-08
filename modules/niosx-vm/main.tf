
variable "rg_name"        { type = string }
variable "location"       { type = string }
variable "subnet_id"      { type = string }
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type    = string
  default = null
}

variable "vm_name_prefix" {
  type = string
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
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_name_prefix}-vm"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_D4s_v5"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key == null ? [] : [1]
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  custom_data = filebase64("${path.module}/cloud-init.tpl")
}
