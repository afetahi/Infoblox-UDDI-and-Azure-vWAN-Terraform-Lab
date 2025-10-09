
variable "rg_name"               { type = string }
variable "hub_id"                { type = string }
variable "hub_name"              { type = string }
variable "vnet_shared"           { type = any }
variable "vnet_spoke"            { type = any }
variable "use_default_for_shared"{ type = bool }
variable "spoke_rt_name"         { type = string }

resource "azurerm_virtual_hub_route_table" "spoke" {
  name           = var.spoke_rt_name
  virtual_hub_id = var.hub_id
  labels         = ["Spokes"]
  
}

resource "azurerm_virtual_hub_connection" "shared" {
  name                      = "${var.hub_name}-conn-shared"
  virtual_hub_id            = var.hub_id
  remote_virtual_network_id = var.vnet_shared.id

  routing {
    associated_route_table_id = var.use_default_for_shared ? null : azurerm_virtual_hub_route_table.spoke.id
    propagated_route_table { labels = ["Default"] }
  }
}

resource "azurerm_virtual_hub_connection" "spoke" {
  name                      = "${var.hub_name}-conn-spoke"
  virtual_hub_id            = var.hub_id
  remote_virtual_network_id = var.vnet_spoke.id

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.spoke.id
    propagated_route_table { labels = ["Default"] }
  }
}

output "rt_names" {
  value = { spoke = azurerm_virtual_hub_route_table.spoke.name }
}
output "connection_names" {
  description = "Names of the shared and spoke hub connections"
  value = {
    shared = azurerm_virtual_hub_connection.shared.name
    spoke  = azurerm_virtual_hub_connection.spoke.name
  }
}
