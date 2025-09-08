output "application_gateway_id" {
  description = "Application Gateway resource ID"
  value       = azurerm_application_gateway.main.id
}

output "public_ip_address" {
  description = "Public IP address of Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "backend_address_pool_id" {
  description = "Backend address pool ID"
  value       = tolist(azurerm_application_gateway.main.backend_address_pool)[0].id
}
