resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "sql_db" {
  name         = var.sql_db_name
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = var.collation
  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb
  enclave_type = var.enclave_type

  tags = var.tags
}

# Allow Azure services to access SQL Server if enabled
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# VNet integration rule connecting SQL server directly to virtual network subnet
resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  count               = var.subnet_id != null && var.subnet_id != "" ? 1 : 0
  name                = "sql-vnet-rule"
  server_id           = azurerm_mssql_server.sql_server.id
  subnet_id           = var.subnet_id
  ignore_missing_vnet_service_endpoint = false
}

# Optional custom client firewall rules
resource "azurerm_mssql_firewall_rule" "custom_rules" {
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
