data "azurerm_client_config" "resource_configs" {
}

resource "azurerm_mssql_server" "project_sql_svr" {
  location                     = var.location
  name                         = var.svr_name
  resource_group_name          = var.rg_name
  version                      = "12.0"
  administrator_login          = var.username
  administrator_login_password = var.password

  azuread_administrator {
    login_username = var.fn_app_name
    object_id      = data.azurerm_client_config.resource_configs.object_id #azurerm_linux_function_app.project_fa.identity.0.principal_id
  }
}

resource "azurerm_mssql_database" "project_sql_db" {
  name                 = var.db_name
  server_id            = azurerm_mssql_server.project_sql_svr.id
  storage_account_type = "Local"
  depends_on = [
    azurerm_mssql_server.project_sql_svr,
  ]
}
resource "azurerm_mssql_server_transparent_data_encryption" "project_sql_svr_encrypt" {
  server_id = azurerm_mssql_server.project_sql_svr.id
  depends_on = [
    azurerm_mssql_server.project_sql_svr,
  ]
}

resource "azurerm_mssql_firewall_rule" "project_sql_fw_rule" {
  end_ip_address   = "0.0.0.0"
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.project_sql_svr.id
  start_ip_address = "0.0.0.0"
  depends_on = [
    azurerm_mssql_server.project_sql_svr,
  ]
}
resource "azurerm_mssql_virtual_network_rule" "project_sql_vnet_rule" {
  name      = var.vnet_rule_1
  server_id = azurerm_mssql_server.project_sql_svr.id
  subnet_id = var.subnet_id_value
  depends_on = [
    var.subnet,
    azurerm_mssql_server.project_sql_svr,
  ]
}

resource "azurerm_service_plan" "project_asp" {
  location            = var.location
  name                = var.asp_name
  os_type             = "Linux"
  resource_group_name = var.rg_name
  sku_name            = "B1"
}
resource "azurerm_linux_function_app" "project_fa" {
  app_settings = {
    BUILD_FLAGS                    = "UseExpressBuild" # its an envirnoment variable
    DB_CONNECTION_STRING           = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=tcp:${var.svr_name}.database.windows.net,1433;DATABASE=${var.db_name};"
    ENABLE_ORYX_BUILD              = "true"        # its an envirnoment variable
    SCM_DO_BUILD_DURING_DEPLOYMENT = "1"           # its an envirnoment variable
    XDG_CACHE_HOME                 = "/tmp/.cache" # its an envirnoment variable
  }
  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  https_only                 = true
  location                   = var.location
  name                       = var.fn_app_name
  resource_group_name        = var.rg_name
  service_plan_id            = azurerm_service_plan.project_asp.id
  storage_account_access_key = var.sa_primary_key
  storage_account_name       = var.sa_name
  enabled                    = false
  tags = {
    "hidden-link: /app-insights-conn-string" = var.app_insights_conn_string
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_insights_connection_string = var.app_insights_conn_string
    ftps_state                             = "FtpsOnly"
    application_stack {
      python_version = "3.8"
    }
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
  }
  depends_on = [
    azurerm_service_plan.project_asp,
  ]
}




