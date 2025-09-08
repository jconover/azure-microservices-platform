output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = azurerm_subnet.aks.id
}

output "appgw_subnet_id" {
  description = "Application Gateway subnet ID"
  value       = azurerm_subnet.appgw.id
}

output "vm_subnet_id" {
  description = "VM subnet ID"
  value       = azurerm_subnet.vm.id
}

output "resource_group_name" {
  description = "Networking resource group name"
  value       = azurerm_resource_group.network.name
}

output "resource_group_id" {
  description = "Networking resource group ID"
  value       = azurerm_resource_group.network.id
}
