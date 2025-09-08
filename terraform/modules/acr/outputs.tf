output "acr_id" {
  description = "ACR resource ID"
  value       = azurerm_container_registry.main.id
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.main.login_server
}

output "acr_suffix" {
  description = "Random suffix used for ACR name"
  value       = random_string.acr_suffix.result
}
