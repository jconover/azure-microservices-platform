output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "acr_name" {
  value = module.acr.acr_name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "application_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
}
