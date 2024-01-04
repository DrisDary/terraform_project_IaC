terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.85.0"
    }
  }
}


provider "azurerm" {
  features {}

}

resource "random_string" "storage_account_name_generator" {
  length  = 24
  upper   = false
  lower   = true
  numeric = true
  special = false
}



locals {
  local_resource_group_name   = "rg-devops-project-002"
  local_location              = "eastus"
  local_storage_account_name  = random_string.storage_account_name_generator.result
  local_function_app_name     = "fn-devops-project-002"
  local_app_insights_name     = "appinsights-devops-project-002"
  local_database_name         = "sqldb-devops-project-002"
  local_database_server_name  = "sqlserver-devops-project-002"
  local_app_service_plan_name = "asp-devops-project-002"
}

module "environment" {
  source   = "./environment"
  rg_name  = local.local_resource_group_name
  location = local.local_location
}

module "network" {
  source            = "./network"
  agw_name          = "agw-devops-project-002"
  baa_pool_name     = "backendpool-devops-project-002"
  ba_http_name      = "backend-devops-project-002"
  fnt_end_ip_name   = "appGwPublicFrontendIpIPv4"
  gw_ip_name        = "appGatewayIpConfig"
  listener_name     = "listener-devops-project-002"
  routing_rule_name = "routerule-devops-project-002"
  pip_name          = "pip-devops-project-002"
  vnet_name         = "vnet-devops-project-002"
  subnet_name       = "snet-devops-project-002"
  rg_name           = local.local_resource_group_name
  location          = local.local_location

  #depends_on = [module.environment]
}

module "storage" {
  source   = "./storage"
  sa_name  = local.local_storage_account_name
  rg_name  = local.local_resource_group_name
  location = local.local_location

  #depends_on = [module.environment]
}

module "logs" {
  source            = "./logs"
  log_name          = "loganalytics-devops-project-002"
  app_insights_name = local.local_app_insights_name
  rg_name           = local.local_resource_group_name
  location          = local.local_location

  #depends_on = [module.environment]
}

module "database_function_app" {
  source                   = "./database_function_app"
  svr_name                 = local.local_database_server_name
  username                 = "rotreyuyuql"
  password                 = "@#sWi9ltH0tr6#epHowru-=s2uE@ql"
  db_name                  = local.local_database_name
  vnet_rule_1              = "VnetRule"
  rg_name                  = local.local_resource_group_name
  location                 = local.local_location
  fn_app_name              = local.local_function_app_name
  subnet_id_value          = module.network.snet_id
  subnet                   = module.network.snet
  firewall_rule_name       = "AllowAll"
  asp_name                 = local.local_app_service_plan_name
  sa_name                  = local.local_storage_account_name
  sa_primary_key           = module.storage.sa_pkey
  app_insights_conn_string = module.logs.app_insights_conn

  #depends_on = [module.storage, module.logs, module.network, module.environment]

}










