resource "azurerm_public_ip" "appgw" {
  name                = "${var.project_name}-${var.environment}-appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "${var.project_name}-${var.environment}-waf-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = var.environment == "production" ? "Prevention" : "Detection"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = var.tags
}

locals {
  backend_address_pool_name      = "aks-backend-pool"
  frontend_port_name_http        = "http-port"
  frontend_port_name_https       = "https-port"
  frontend_ip_configuration_name = "frontend-ip"
  http_setting_name              = "http-settings"
  listener_name_http             = "http-listener"
  request_routing_rule_name      = "routing-rule"
  gateway_ip_configuration_name  = "gateway-ip-config"
}

resource "azurerm_application_gateway" "main" {
  name                = "${var.project_name}-${var.environment}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.appgw_capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "health-probe"
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = "/health"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_http
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.main.id

  tags = var.tags

  # This is needed for the Application Gateway to work properly
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      ssl_certificate,
      redirect_configuration,
      autoscale_configuration
    ]
  }
}
