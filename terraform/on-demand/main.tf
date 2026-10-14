# ==============================================================================
# ON-DEMAND STACK (Independent State Isolated from Main Environment)
# ==============================================================================

# Look up the existing Resource Group created by the main environment
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Look up the existing VNet created by the main environment
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Look up existing subnets in the VNet
data "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "sql_subnet" {
  name                 = var.sql_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  audit_tags = merge(var.tags, {
    Workload        = "OnDemand"
    WorkloadId      = var.workload_id
    PRNumber        = var.pr_number != "" ? var.pr_number : "none"
    Requester       = var.requester
    ExpirationDate  = var.expiration_date
    ManagedBy       = "Terraform-OnDemand"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# ON-DEMAND COMPUTE VM (Independent State)
# ---------------------------------------------------------------------------------------------------------------------
module "on_demand_vm" {
  count                           = var.enable_vm ? 1 : 0
  source                          = "../modules/compute_vm"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  vm_name                         = var.vm_name != "" ? var.vm_name : "vm-${var.workload_id}-${random_string.suffix.result}"
  subnet_id                       = data.azurerm_subnet.vm_subnet.id
  vm_size                         = var.vm_size
  enable_public_ip                = var.vm_enable_public_ip
  admin_username                  = var.vm_admin_username
  disable_password_authentication = var.vm_disable_password_authentication
  admin_password                  = var.vm_admin_password
  admin_ssh_public_key            = var.vm_ssh_public_key
  os_disk_type                    = "Premium_LRS"
  os_disk_size_gb                 = var.vm_os_disk_size_gb
  tags                            = local.audit_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ON-DEMAND SQL DATABASE (Independent State)
# ---------------------------------------------------------------------------------------------------------------------
module "on_demand_sql" {
  count                         = var.enable_sql ? 1 : 0
  source                        = "../modules/sql_database"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sql_server_name               = var.sql_server_name != "" ? var.sql_server_name : "sql-${var.workload_id}-${random_string.suffix.result}"
  sql_db_name                   = var.sql_db_name
  admin_username                = var.sql_admin_username
  admin_password                = var.sql_admin_password
  sku_name                      = var.sql_sku_name
  max_size_gb                   = var.sql_max_size_gb
  public_network_access_enabled = true
  allow_azure_services          = true
  subnet_id                     = data.azurerm_subnet.sql_subnet.id
  tags                          = local.audit_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ON-DEMAND STORAGE ACCOUNT (Independent State)
# ---------------------------------------------------------------------------------------------------------------------
module "on_demand_storage" {
  count                         = var.enable_storage ? 1 : 0
  source                        = "../modules/storage"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  storage_account_name          = var.storage_account_name != "" ? var.storage_account_name : lower(replace("st${var.workload_id}${random_string.suffix.result}", "-", ""))
  account_tier                  = var.storage_account_tier
  account_replication_type      = var.storage_account_replication
  public_network_access_enabled = true
  container_names               = var.storage_containers
  allowed_subnet_ids            = [data.azurerm_subnet.vm_subnet.id]
  tags                          = local.audit_tags
}
