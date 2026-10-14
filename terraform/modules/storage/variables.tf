variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be deployed."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account (3-24 lowercase alphanumeric characters)."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)."
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Defines the Kind of account (StorageV2, BlobStorage, etc.)."
  type        = string
  default     = "StorageV2"
}

variable "min_tls_version" {
  description = "Minimum supported TLS version."
  type        = string
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable blob versioning."
  type        = bool
  default     = true
}

variable "blob_retention_days" {
  description = "Number of days for blob soft delete retention."
  type        = number
  default     = 7
}

variable "container_retention_days" {
  description = "Number of days for container soft delete retention."
  type        = number
  default     = 7
}

variable "container_names" {
  description = "List of blob container names to create."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs permitted to access the storage account."
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "List of public IP or CIDR ranges allowed to access the storage account."
  type        = list(string)
  default     = []
}

variable "network_rules_default_action" {
  description = "Default action when no other network rule matches (Allow or Deny)."
  type        = string
  default     = "Allow"
}

variable "tags" {
  description = "Mapping of tags to apply to the storage account."
  type        = map(string)
  default     = {}
}
