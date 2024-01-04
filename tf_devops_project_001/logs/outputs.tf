output "app_insights_conn" {
  value = azurerm_application_insights.project_app_insights.connection_string
}