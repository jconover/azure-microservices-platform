resource "azurerm_resource_group" "monitoring" {
  name     = "${var.project_name}-${var.environment}-monitoring-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-${var.environment}-law"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# Simplified Application Insights configuration with timeout
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-appinsights"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  # Disable automatic rule creation to avoid timeout issues
  disable_ip_masking                  = false
  force_customer_storage_for_profiler = false
  internet_ingestion_enabled          = true
  internet_query_enabled              = true

  tags = var.tags

  # Add timeout configuration
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  # Ignore changes to automatically created resources
  lifecycle {
    ignore_changes = [
      tags["hidden-link:"]
    ]
  }
}
