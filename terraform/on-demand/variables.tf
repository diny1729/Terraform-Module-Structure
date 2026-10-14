# Core Environment Lookup Variables
variable "resource_group_name" {
  description = "The existing Resource Group name created by the main environment."
  type        = string
  default     = "rg-myapp-dev-eastus"
}

variable "vnet_name" {
  description = "The existing Virtual Network name created by the main environment."
  type        = string
  default     = "myapp-vnet-dev"
}

variable "vm_subnet_name" {
  description = "The existing Subnet name to deploy the on-demand VM into."
  type        = string
  default     = "vm-subnet"
}

variable "sql_subnet_name" {
  description = "The existing Subnet name for SQL Database service endpoints."
  type        = string
  default     = "sql-subnet"
}

# ---------------------------------------------------------------------------------------------------------------------
# Workload Tracking & Record-Keeping Identifiers
# ---------------------------------------------------------------------------------------------------------------------
variable "workload_id" {
  description = "Unique identifier for this on-demand workload (e.g. pr-42, jira-1024, analytics-bench)."
  type        = string
  default     = "sandbox"
}

variable "pr_number" {
  description = "Associated GitHub / Azure DevOps Pull Request number if applicable."
  type        = string
  default     = ""
}

variable "requester" {
  description = "Team or developer name requesting this on-demand resource."
  type        = string
  default     = "devops-engineer"
}

variable "expiration_date" {
  description = "Target expiration / teardown date for automated governance tracking (YYYY-MM-DD)."
  type        = string
  default     = "2026-12-31"
}

# ---------------------------------------------------------------------------------------------------------------------
# Feature Flags (What to Deploy On-Demand)
# ---------------------------------------------------------------------------------------------------------------------
variable "enable_vm" {
  description = "Deploy an on-demand VM."
  type        = bool
  default     = true
}

variable "enable_sql" {
  description = "Deploy an on-demand SQL Server & DB."
  type        = bool
  default     = false
}

variable "enable_storage" {
  description = "Deploy an on-demand Storage Account."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# On-Demand VM Settings
# ---------------------------------------------------------------------------------------------------------------------
variable "vm_name" {
  description = "Custom name for on-demand VM (auto-generated if empty)."
  type        = string
  default     = "ondemand-dev-vm"
}

variable "vm_size" {
  description = "SKU for the on-demand VM."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vm_os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 64
}

variable "vm_enable_public_ip" {
  description = "Attach public IP to on-demand VM."
  type        = bool
  default     = true
}

variable "vm_admin_username" {
  description = "Admin username."
  type        = string
  default     = "azureuser"
}

variable "vm_disable_password_authentication" {
  description = "Disable password auth."
  type        = bool
  default     = false
}

variable "vm_admin_password" {
  description = "Admin password (pass via $env:TF_VAR_vm_admin_password)."
  type        = string
  default     = "OnDemandP@ss2026!"
  sensitive   = true
}

variable "vm_ssh_public_key" {
  description = "SSH public key."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# On-Demand SQL Settings
# ---------------------------------------------------------------------------------------------------------------------
variable "sql_server_name" {
  description = "Logical SQL server name (globally unique)."
  type        = string
  default     = ""
}

variable "sql_db_name" {
  description = "Database name."
  type        = string
  default     = "ondemand-db"
}

variable "sql_admin_username" {
  description = "Admin username for SQL."
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Admin password for SQL."
  type        = string
  default     = "OnDemandSqlP@ss2026!"
  sensitive   = true
}

variable "sql_sku_name" {
  description = "SQL SKU (S0, S1, GP_Gen5_2)."
  type        = string
  default     = "S1"
}

variable "sql_max_size_gb" {
  description = "SQL max size in GB."
  type        = number
  default     = 50
}

# ---------------------------------------------------------------------------------------------------------------------
# On-Demand Storage Settings
# ---------------------------------------------------------------------------------------------------------------------
variable "storage_account_name" {
  description = "Storage account name (leave empty for random suffix)."
  type        = string
  default     = ""
}

variable "storage_account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Storage replication."
  type        = string
  default     = "LRS"
}

variable "storage_containers" {
  description = "List of containers to create."
  type        = list(string)
  default     = ["temp-data"]
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default = {
    Workload    = "OnDemand"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
