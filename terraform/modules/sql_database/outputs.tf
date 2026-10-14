output "server_id" {
  description = "The ID of the SQL Server."
  value       = azurerm_mssql_server.sql_server.id
}

output "server_name" {
  description = "The name of the SQL Server."
  value       = azurerm_mssql_server.sql_server.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "database_id" {
  description = "The ID of the SQL Database."
  value       = azurerm_mssql_database.sql_db.id
}

output "database_name" {
  description = "The name of the SQL Database."
  value       = azurerm_mssql_database.sql_db.name
}

output "connection_string" {
  description = "ADO.NET connection string format for application configuration."
  value       = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql_db.name};Persist Security Info=False;User ID=${var.admin_username};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}
