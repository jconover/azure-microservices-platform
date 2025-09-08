resource "azurerm_resource_group" "aks" {
  name     = "${var.project_name}-${var.environment}-aks-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_size
    vnet_subnet_id      = var.subnet_id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.node_count
    max_count           = var.node_count * 2

    node_labels = {
      environment = var.environment
      nodepool    = "default"
    }

    tags = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Fixed: Include managed = true (required despite deprecation warning)
  azure_active_directory_role_based_access_control {
    managed                = true # Required field (will default to true in v4.0)
    azure_rbac_enabled     = true
    admin_group_object_ids = length(var.admin_group_object_ids) > 0 ? var.admin_group_object_ids : null
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  tags = var.tags

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_network" {
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.subnet_id
}
