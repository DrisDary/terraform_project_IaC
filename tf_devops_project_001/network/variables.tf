variable "agw_name" {
  description = "name of application gateway"
}

variable "baa_pool_name" {
  description = "name of backend address pool"
}


variable "ba_http_name" {
  description = "name of backend http"
}

variable "fnt_end_ip_name" {
  description = "front end ip configuration name"
}

variable "gw_ip_name" {
  description = "gateway ip configuration name"
}

variable "listener_name" {
  description = "http listerner name"
}

variable "routing_rule_name" {
  description = "routing rule name"
}

variable "pip_name" {
  description = "public ip name"
}

variable "vnet_name" {
  description = "vnet name"
}

variable "subnet_name" {
  description = "snet name"
}

variable "rg_name" {

  description = "resource group name"
}

variable "location" {

  description = "instance location"
}

