variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the SQL Server and Database will be deployed."
  type        = string
}

variable "sql_server_name" {
  description = "Name of the Azure SQL logical server (globally unique)."
  type        = string
}

variable "sql_db_name" {
  description = "Name of the Azure SQL database."
  type        = string
  default     = "appdb"
}

variable "sql_version" {
  description = "The version for the database server. Valid values are: 2.0 (for v11 server) and 12.0."
  type        = string
  default     = "12.0"
}

variable "admin_username" {
  description = "The administrator username for the SQL Server."
  type        = string
  default     = "sqladminuser"
}

variable "admin_password" {
  description = "The administrator password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this server."
  type        = bool
  default     = true
}

variable "allow_azure_services" {
  description = "Whether to allow Azure services and resources to access this server (0.0.0.0 firewall rule)."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID with Microsoft.Sql service endpoint for VNet integration rule."
  type        = string
  default     = null
}

variable "sku_name" {
  description = "Specifies the name of the SKU used by the database. E.g. Basic, S0, S1, GP_Gen5_2, BC_Gen5_2."
  type        = string
  default     = "S0"
}

variable "max_size_gb" {
  description = "The max size of the database in gigabytes."
  type        = number
  default     = 50
}

variable "collation" {
  description = "The collation for the database."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "enclave_type" {
  description = "Specifies the type of enclave to be used by the database (Default or VBS)."
  type        = string
  default     = "Default"
}

variable "firewall_rules" {
  description = "Map of custom firewall rules to create."
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to SQL resources."
  type        = map(string)
  default     = {}
}
