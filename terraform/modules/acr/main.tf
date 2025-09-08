resource "azurerm_resource_group" "acr" {
  name     = "${var.project_name}-acr-rg"
  location = var.location
  tags     = var.tags
}

# Generate random suffix for globally unique ACR name
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}acr${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = var.acr_sku
  admin_enabled       = false

  dynamic "georeplications" {
    for_each = var.environment == "production" ? [1] : []
    content {
      location                = "West Europe"
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }

  tags = var.tags
}
