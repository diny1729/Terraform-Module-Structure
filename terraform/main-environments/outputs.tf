output "resource_group_name" {
  description = "The name of the Resource Group created."
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "The Azure region of the Resource Group."
  value       = azurerm_resource_group.rg.location
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking Outputs (Referenced by on-demand stack)
# ---------------------------------------------------------------------------------------------------------------------
output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of created subnet names to their IDs."
  value       = module.networking.subnet_ids
}

output "vm_subnet_id" {
  description = "Subnet ID for VMs."
  value       = module.networking.subnet_ids["vm-subnet"]
}

output "sql_subnet_id" {
  description = "Subnet ID for SQL Databases."
  value       = module.networking.subnet_ids["sql-subnet"]
}

# ---------------------------------------------------------------------------------------------------------------------
# Core Workload Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "aks_cluster_name" {
  description = "The name of the AKS Cluster."
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "The ID of the AKS Cluster."
  value       = module.aks.cluster_id
}

output "storage_account_name" {
  description = "Primary Storage Account Name."
  value       = module.storage.storage_account_name
}

output "sql_server_fqdn" {
  description = "Primary SQL Server FQDN."
  value       = module.sql_database.server_fqdn
}
