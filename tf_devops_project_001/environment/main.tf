resource "azurerm_resource_group" "project_rg" {
  location = var.location
  name     = var.rg_name
}


