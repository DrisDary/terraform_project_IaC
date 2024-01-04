
resource "azurerm_storage_account" "project_sa" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = var.location
  name                            = var.sa_name
  resource_group_name             = var.rg_name
}
resource "azurerm_storage_container" "project_sc_hosts" {
  name                 = "azure-webjobs-hosts"
  storage_account_name = azurerm_storage_account.project_sa.name
}
resource "azurerm_storage_container" "project_sc_secrets" {
  name                 = "azure-webjobs-secrets"
  storage_account_name = azurerm_storage_account.project_sa.name
}

