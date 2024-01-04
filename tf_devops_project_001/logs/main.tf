
resource "azurerm_log_analytics_workspace" "project_logs" {
  location            = var.location
  name                = var.log_name
  resource_group_name = var.rg_name
}
resource "azurerm_monitor_smart_detector_alert_rule" "project_monitor_ar" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failed HTTP requests"
  resource_group_name = var.rg_name
  scope_resource_ids  = [azurerm_application_insights.project_app_insights.id]
  severity            = "Sev3"
  action_group {
    ids = [azurerm_monitor_action_group.project_monitor_ag.id]
  }
}
resource "azurerm_monitor_action_group" "project_monitor_ag" {
  name                = "Application Insights Smart Detection"
  resource_group_name = var.rg_name
  short_name          = "SmartDetect"
  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa" #environemnt variables
    use_common_alert_schema = true

  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05" #environemnt variables
    use_common_alert_schema = true
  }
}
resource "azurerm_application_insights" "project_app_insights" {
  application_type    = "web"
  location            = var.location
  name                = var.app_insights_name
  resource_group_name = var.rg_name
  sampling_percentage = 0
  workspace_id        = azurerm_log_analytics_workspace.project_logs.id
  depends_on = [
    azurerm_log_analytics_workspace.project_logs,
  ]
}
