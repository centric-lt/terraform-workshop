output "app_service_name" {
  value = azurerm_app_service.production.name
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.production.default_site_hostname}"
}

output "app_service_slot_hostname" {
  value = "https://${azurerm_app_service_slot.staging.default_site_hostname}"
}