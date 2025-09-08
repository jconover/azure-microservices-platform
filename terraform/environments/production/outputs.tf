output "resource_group_names" {
  description = "All resource group names"
  value = {
    networking = module.networking.resource_group_name
    monitoring = "${var.project_name}-${local.environment}-monitoring-rg"
    acr        = "${var.project_name}-acr-rg"
  }
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.acr_login_server
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = module.application_gateway.public_ip_address
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.monitoring.log_analytics_workspace_id
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = module.monitoring.application_insights_id
}
