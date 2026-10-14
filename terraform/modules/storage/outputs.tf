output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location."
  value       = azurerm_storage_account.storage.primary_blob_host
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary blob location."
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true
}

output "containers" {
  description = "Map of created containers and their IDs."
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}
