resource "azurerm_storage_account" "storage" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  min_tls_version                   = var.min_tls_version
  enable_https_traffic_only         = true
  public_network_access_enabled     = var.public_network_access_enabled
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = var.shared_access_key_enabled

  identity {
    type = "SystemAssigned"
  }

  blob_properties {
    versioning_enabled = var.enable_versioning

    delete_retention_policy {
      days = var.blob_retention_days
    }

    container_delete_retention_policy {
      days = var.container_retention_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.container_names)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "network_rules" {
  count                      = length(var.allowed_subnet_ids) > 0 || length(var.allowed_ip_ranges) > 0 ? 1 : 0
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = var.network_rules_default_action
  ip_rules                   = var.allowed_ip_ranges
  virtual_network_subnet_ids = var.allowed_subnet_ids
  bypass                     = ["AzureServices", "Logging", "Metrics"]
}
