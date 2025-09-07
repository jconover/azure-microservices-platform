# Azure Container Registry Module
resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}acr${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false

  georeplications = var.environment == "production" ? [
    {
      location                = "West US"
      zone_redundancy_enabled = true
      tags                    = {}
    },
    {
      location                = "North Europe"
      zone_redundancy_enabled = true
      tags                    = {}
    }
  ] : []

  retention_policy {
    days    = var.retention_days
    enabled = true
  }

  trust_policy {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Role Assignment for AKS to pull images
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = var.aks_principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}
