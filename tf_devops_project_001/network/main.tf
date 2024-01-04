
resource "azurerm_application_gateway" "project_agw" {
  enable_http2        = true
  location            = var.location
  name                = var.agw_name
  resource_group_name = var.rg_name
  autoscale_configuration {
    max_capacity = 2
    min_capacity = 0
  }
  backend_address_pool {
    name = var.baa_pool_name
  }
  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = var.ba_http_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  frontend_ip_configuration {
    name                 = var.fnt_end_ip_name
    public_ip_address_id = azurerm_public_ip.project_pip.id
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  gateway_ip_configuration {
    name      = var.gw_ip_name
    subnet_id = azurerm_subnet.project_snet.id
  }
  http_listener {
    frontend_ip_configuration_name = var.fnt_end_ip_name
    frontend_port_name             = "port_80"
    name                           = var.listener_name
    protocol                       = "Http"
  }
  request_routing_rule {
    backend_address_pool_name  = var.baa_pool_name
    backend_http_settings_name = var.ba_http_name
    http_listener_name         = var.listener_name
    name                       = var.routing_rule_name
    priority                   = 10000
    rule_type                  = "Basic"
  }
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  depends_on = [
    azurerm_public_ip.project_pip,
    azurerm_subnet.project_snet,
  ]
}
resource "azurerm_public_ip" "project_pip" {
  allocation_method   = "Static"
  location            = var.location
  name                = var.pip_name
  resource_group_name = var.rg_name
  sku                 = "Standard"
}
resource "azurerm_virtual_network" "project_vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = var.vnet_name
  resource_group_name = var.rg_name
}
resource "azurerm_subnet" "project_snet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  service_endpoints    = ["Microsoft.Sql"]
  virtual_network_name = var.vnet_name
  depends_on = [
    azurerm_virtual_network.project_vnet,
  ]
}



