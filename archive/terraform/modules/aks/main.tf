# AKS Cluster Module
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.prefix}-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_size
    vnet_subnet_id      = var.aks_subnet_id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.system_min_count
    max_count           = var.system_max_count

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
    }

    tags = merge(
      var.tags,
      {
        "nodepool-type" = "system"
        "environment"   = var.environment
      }
    )
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    load_balancer_sku  = "standard"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }

  azure_policy_enabled = true

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# User Node Pool for Applications
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_node_size
  node_count            = var.user_node_count
  vnet_subnet_id        = var.aks_subnet_id
  enable_auto_scaling   = true
  min_count             = var.user_min_count
  max_count             = var.user_max_count

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
  }

  node_taints = [
    "workload=user:NoSchedule"
  ]

  tags = merge(
    var.tags,
    {
      "nodepool-type" = "user"
      "environment"   = var.environment
    }
  )
}
