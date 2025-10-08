
variable "rg_name"  { type = string }
variable "location" { type = string }
variable "vnet" {
  type = object({
    name    = string
    cidr    = string
    subnets = map(string)
  })
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = [var.vnet.cidr]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "sn" {
  for_each             = var.vnet.subnets
  name                 = each.key
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

output "vnet"    { value = azurerm_virtual_network.vnet }
output "subnets" { value = { for k,s in azurerm_subnet.sn : k => s.id } }
