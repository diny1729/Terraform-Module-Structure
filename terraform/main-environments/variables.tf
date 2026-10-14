variable "environment" {
  description = "Target environment name (e.g., dev, qa, prod)."
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "Resource prefix used to name all resources."
  type        = string
  default     = "myapp"
}

variable "location" {
  description = "The Azure Region to deploy resources into."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
  default     = "rg-myapp-dev-eastus"
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking Variables (BYO Subnets for System and User Nodes)
# ---------------------------------------------------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_cidrs" {
  description = "Subnet CIDR blocks map including dedicated node subnets."
  type = object({
    aks_system_nodes = string
    aks_user_nodes   = string
    vm               = string
    sql              = string
    appgw            = string
  })
  default = {
    aks_system_nodes = "10.0.1.0/24"
    aks_user_nodes   = "10.0.5.0/24"
    vm               = "10.0.2.0/24"
    sql              = "10.0.3.0/24"
    appgw            = "10.0.4.0/24"
  }
}

variable "admin_ip_allowlist" {
  description = "IP address or CIDR allowed for administrative access (SSH)."
  type        = string
  default     = "*"
}

# ---------------------------------------------------------------------------------------------------------------------
# Storage Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "storage_account_tier" {
  description = "Tier to use for the storage account."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Replication type for storage account (LRS, GRS, ZRS)."
  type        = string
  default     = "LRS"
}

variable "storage_containers" {
  description = "List of containers to create."
  type        = list(string)
  default     = ["data", "backups", "logs"]
}

# ---------------------------------------------------------------------------------------------------------------------
# Base VM Variables (Optional Jumpbox)
# ---------------------------------------------------------------------------------------------------------------------
variable "enable_base_vm" {
  description = "Whether to provision a baseline jumpbox VM in the core environment."
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Size of the Virtual Machine."
  type        = string
  default     = "Standard_B2s"
}

variable "vm_enable_public_ip" {
  description = "Whether to assign a public IP to the Virtual Machine."
  type        = bool
  default     = false
}

variable "vm_admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "vm_disable_password_authentication" {
  description = "Disable password auth and enforce SSH keys."
  type        = bool
  default     = false
}

variable "vm_admin_password" {
  description = "Admin password for the VM."
  type        = string
  default     = "ComplexPassword123!@#"
  sensitive   = true
}

variable "vm_ssh_public_key" {
  description = "Public SSH key for VM authentication."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# SQL Database Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "sql_database_name" {
  description = "Name of the Azure SQL Database."
  type        = string
  default     = "appdb"
}

variable "sql_admin_username" {
  description = "Administrator username for Azure SQL Server."
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Administrator password for Azure SQL Server."
  type        = string
  default     = "SqlStr0ngP@ssw0rd!2026"
  sensitive   = true
}

variable "sql_sku_name" {
  description = "SKU for Azure SQL Database."
  type        = string
  default     = "S0"
}

variable "sql_max_size_gb" {
  description = "Max size in GB for SQL Database."
  type        = number
  default     = 50
}

# ---------------------------------------------------------------------------------------------------------------------
# AKS Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "aks_system_node_count" {
  description = "Initial number of nodes in AKS system node pool."
  type        = number
  default     = 2
}

variable "aks_system_min_count" {
  description = "Minimum number of nodes for system node pool auto-scaling (min: 2)."
  type        = number
  default     = 2
}

variable "aks_system_max_count" {
  description = "Maximum number of nodes for system node pool auto-scaling."
  type        = number
  default     = 5
}

variable "aks_system_vm_size" {
  description = "VM size for AKS system nodes."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "aks_user_node_count" {
  description = "Initial number of nodes in AKS user node pool (min: 2)."
  type        = number
  default     = 2
}

variable "aks_user_min_count" {
  description = "Minimum number of nodes for user node pool auto-scaling (min: 2)."
  type        = number
  default     = 2
}

variable "aks_user_max_count" {
  description = "Maximum number of nodes for user node pool auto-scaling."
  type        = number
  default     = 6
}

variable "aks_user_vm_size" {
  description = "VM size for AKS user workload nodes."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "aks_pod_cidr" {
  description = "Pod CIDR for Azure CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "aks_service_cidr" {
  description = "Service CIDR for Kubernetes services."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "IP address for CoreDNS within service_cidr."
  type        = string
  default     = "172.16.0.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------------------------------------------------
variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "Infrastructure"
  }
}
