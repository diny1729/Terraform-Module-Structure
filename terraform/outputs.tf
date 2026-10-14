output "resource_group_name" {
  description = "The name of the Resource Group created."
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "The Azure region of the Resource Group."
  value       = azurerm_resource_group.rg.location
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking Outputs
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

output "aks_system_nodes_subnet_id" {
  description = "Subnet ID dedicated to AKS system node pool."
  value       = module.networking.subnet_ids["aks-system-nodes-subnet"]
}

output "aks_user_nodes_subnet_id" {
  description = "Subnet ID dedicated to AKS user node pool."
  value       = module.networking.subnet_ids["aks-user-nodes-subnet"]
}

output "appgw_subnet_id" {
  description = "Subnet ID dedicated to Application Gateway."
  value       = module.networking.subnet_ids["appgw-subnet"]
}

# ---------------------------------------------------------------------------------------------------------------------
# Storage Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "storage_account_name" {
  description = "The name of the created Storage Account."
  value       = var.enable_storage ? module.storage[0].storage_account_name : null
}

output "storage_blob_endpoint" {
  description = "The Primary Blob service endpoint."
  value       = var.enable_storage ? module.storage[0].primary_blob_endpoint : null
}

# ---------------------------------------------------------------------------------------------------------------------
# Compute VM Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "vm_name" {
  description = "The name of the Virtual Machine."
  value       = var.enable_vm ? module.compute_vm[0].vm_name : null
}

output "vm_private_ip" {
  description = "Private IP address of the Virtual Machine."
  value       = var.enable_vm ? module.compute_vm[0].private_ip_address : null
}

output "vm_public_ip" {
  description = "Public IP address of the Virtual Machine (if enabled)."
  value       = var.enable_vm ? module.compute_vm[0].public_ip_address : null
}

# ---------------------------------------------------------------------------------------------------------------------
# SQL Database Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "sql_server_fqdn" {
  description = "The FQDN of the Azure SQL Server."
  value       = var.enable_sql ? module.sql_database[0].server_fqdn : null
}

output "sql_database_name" {
  description = "The name of the Azure SQL Database."
  value       = var.enable_sql ? module.sql_database[0].database_name : null
}

# ---------------------------------------------------------------------------------------------------------------------
# AKS Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "aks_cluster_name" {
  description = "The name of the AKS Cluster."
  value       = var.enable_aks ? module.aks[0].cluster_name : null
}

output "aks_cluster_id" {
  description = "The ID of the AKS Cluster."
  value       = var.enable_aks ? module.aks[0].cluster_id : null
}

output "aks_system_node_pool_name" {
  description = "The name of the System Node Pool."
  value       = var.enable_aks ? module.aks[0].system_node_pool_name : null
}

output "aks_user_node_pool_name" {
  description = "The name of the User Node Pool."
  value       = var.enable_aks ? module.aks[0].user_node_pool_name : null
}

output "aks_get_credentials_command" {
  description = "Azure CLI command to obtain AKS cluster credentials for kubectl."
  value       = var.enable_aks ? "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks[0].cluster_name} --overwrite-existing" : null
}
