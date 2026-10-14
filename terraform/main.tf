resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING MODULE (Foundation: VNet, Subnets for BYO Network, and NSGs)
# ---------------------------------------------------------------------------------------------------------------------
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "${var.prefix}-vnet-${var.environment}"
  vnet_address_space  = var.vnet_address_space

  subnets = {
    # BYO Subnet dedicated to AKS System Nodes
    "aks-system-nodes-subnet" = {
      address_prefixes  = [var.subnet_cidrs.aks_system_nodes]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    # BYO Subnet dedicated to AKS User Workload Nodes
    "aks-user-nodes-subnet" = {
      address_prefixes  = [var.subnet_cidrs.aks_user_nodes]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "vm-subnet" = {
      address_prefixes  = [var.subnet_cidrs.vm]
      service_endpoints = ["Microsoft.Storage"]
    }
    "sql-subnet" = {
      address_prefixes  = [var.subnet_cidrs.sql]
      service_endpoints = ["Microsoft.Sql"]
    }
    "appgw-subnet" = {
      address_prefixes  = [var.subnet_cidrs.appgw]
      service_endpoints = []
    }
  }

  nsg_rules = {
    "vm" = [
      {
        name                   = "Allow-SSH"
        priority               = 1001
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        source_port_range      = "*"
        destination_port_range = "22"
        source_address_prefix  = var.admin_ip_allowlist
      },
      {
        name                   = "Allow-VNet-Inbound"
        priority               = 1010
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "*"
        source_port_range      = "*"
        destination_port_range = "*"
        source_address_prefix  = "VirtualNetwork"
      }
    ]
  }

  nsg_associations = {
    "vm-subnet" = "vm"
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# STORAGE MODULE (Conditionally Deployed)
# ---------------------------------------------------------------------------------------------------------------------
module "storage" {
  count                         = var.enable_storage ? 1 : 0
  source                        = "./modules/storage"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  storage_account_name          = lower(replace("${var.prefix}st${var.environment}${random_string.suffix.result}", "-", ""))
  account_tier                  = var.storage_account_tier
  account_replication_type      = var.storage_account_replication
  public_network_access_enabled = true
  container_names               = var.storage_containers
  allowed_subnet_ids            = [
    module.networking.subnet_ids["vm-subnet"],
    module.networking.subnet_ids["aks-system-nodes-subnet"],
    module.networking.subnet_ids["aks-user-nodes-subnet"]
  ]
  tags                          = var.tags

  depends_on = [module.networking]
}

# ---------------------------------------------------------------------------------------------------------------------
# COMPUTE VM MODULE (Conditionally Deployed)
# ---------------------------------------------------------------------------------------------------------------------
module "compute_vm" {
  count                           = var.enable_vm ? 1 : 0
  source                          = "./modules/compute_vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  vm_name                         = "${var.prefix}-vm-${var.environment}"
  subnet_id                       = module.networking.subnet_ids["vm-subnet"]
  vm_size                         = var.vm_size
  enable_public_ip                = var.vm_enable_public_ip
  admin_username                  = var.vm_admin_username
  disable_password_authentication = var.vm_disable_password_authentication
  admin_password                  = var.vm_admin_password
  admin_ssh_public_key            = var.vm_ssh_public_key
  os_disk_type                    = "Premium_LRS"
  os_disk_size_gb                 = 32
  tags                            = var.tags

  depends_on = [module.networking]
}

# ---------------------------------------------------------------------------------------------------------------------
# AZURE SQL DATABASE MODULE (Conditionally Deployed)
# ---------------------------------------------------------------------------------------------------------------------
module "sql_database" {
  count                         = var.enable_sql ? 1 : 0
  source                        = "./modules/sql_database"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sql_server_name               = "${var.prefix}-sql-${var.environment}-${random_string.suffix.result}"
  sql_db_name                   = var.sql_database_name
  admin_username                = var.sql_admin_username
  admin_password                = var.sql_admin_password
  sku_name                      = var.sql_sku_name
  max_size_gb                   = var.sql_max_size_gb
  public_network_access_enabled = true
  allow_azure_services          = true
  subnet_id                     = module.networking.subnet_ids["sql-subnet"]
  tags                          = var.tags

  depends_on = [module.networking]
}

# ---------------------------------------------------------------------------------------------------------------------
# AKS MODULE (Conditionally Deployed)
# ---------------------------------------------------------------------------------------------------------------------
module "aks" {
  count                         = var.enable_aks ? 1 : 0
  source                        = "./modules/aks"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  cluster_name                  = "${var.prefix}-aks-${var.environment}"
  dns_prefix                    = "${var.prefix}-k8s-${var.environment}"
  system_node_subnet_id         = module.networking.subnet_ids["aks-system-nodes-subnet"]
  user_node_subnet_id           = module.networking.subnet_ids["aks-user-nodes-subnet"]
  system_node_count             = var.aks_system_node_count
  system_node_vm_size           = var.aks_system_vm_size
  system_min_count              = var.aks_system_min_count
  system_max_count              = var.aks_system_max_count
  user_node_count               = var.aks_user_node_count
  user_node_vm_size             = var.aks_user_vm_size
  user_min_count                = var.aks_user_min_count
  user_max_count                = var.aks_user_max_count
  max_pods_per_node             = 110
  enable_auto_scaling           = true
  only_critical_addons_enabled  = true
  pod_cidr                      = var.aks_pod_cidr
  service_cidr                  = var.aks_service_cidr
  dns_service_ip                = var.aks_dns_service_ip
  tags                          = var.tags

  depends_on = [module.networking]
}
