
variable "prefix"  { type = string }
variable "regions" { type = any }

resource "azurerm_resource_group" "rg" {
  for_each = var.regions
  name     = each.value.rg_name
  location = each.value.location
}

resource "azurerm_virtual_wan" "wan" {
  name                = "${var.prefix}-vwan"
  resource_group_name = values(azurerm_resource_group.rg)[0].name
  location            = values(azurerm_resource_group.rg)[0].location
  type                = "Standard"
}

resource "azurerm_virtual_hub" "hub" {
  for_each            = var.regions
  name                = each.value.hub.name
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = each.value.location
  virtual_wan_id      = azurerm_virtual_wan.wan.id
  address_prefix      = each.value.hub.address_cidr
  sku                 = "Standard"
}

output "hubs" {
  value = { for k,h in azurerm_virtual_hub.hub : k => {
    id   = h.id
    name = h.name
  } }
}
