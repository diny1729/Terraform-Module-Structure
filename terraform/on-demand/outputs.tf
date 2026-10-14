output "on_demand_vm_name" {
  description = "Name of the on-demand VM."
  value       = var.enable_vm ? module.on_demand_vm[0].vm_name : null
}

output "on_demand_vm_private_ip" {
  description = "Private IP of the on-demand VM."
  value       = var.enable_vm ? module.on_demand_vm[0].private_ip_address : null
}

output "on_demand_vm_public_ip" {
  description = "Public IP of the on-demand VM."
  value       = var.enable_vm ? module.on_demand_vm[0].public_ip_address : null
}

output "on_demand_sql_server_fqdn" {
  description = "FQDN of the on-demand SQL server."
  value       = var.enable_sql ? module.on_demand_sql[0].server_fqdn : null
}

output "on_demand_sql_database_name" {
  description = "Name of the on-demand SQL database."
  value       = var.enable_sql ? module.on_demand_sql[0].database_name : null
}

output "on_demand_storage_account_name" {
  description = "Name of the on-demand storage account."
  value       = var.enable_storage ? module.on_demand_storage[0].storage_account_name : null
}
