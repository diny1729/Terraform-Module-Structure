resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                         = var.system_node_pool_name
    node_count                   = var.system_node_count
    vm_size                      = var.system_node_vm_size
    vnet_subnet_id               = var.system_node_subnet_id != null ? var.system_node_subnet_id : var.vnet_subnet_id
    auto_scaling_enabled         = var.enable_auto_scaling
    min_count                    = var.enable_auto_scaling ? var.system_min_count : null
    max_count                    = var.enable_auto_scaling ? var.system_max_count : null
    max_pods                     = var.max_pods_per_node
    os_disk_size_gb              = var.os_disk_size_gb
    os_disk_type                 = var.os_disk_type
    only_critical_addons_enabled = var.only_critical_addons_enabled
    type                         = "VirtualMachineScaleSets"
    tags                         = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = var.network_policy
    load_balancer_sku   = "standard"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  role_based_access_control_enabled = true

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# USER NODE POOL (Dedicated for application workloads)
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = var.user_node_subnet_id != null ? var.user_node_subnet_id : (var.system_node_subnet_id != null ? var.system_node_subnet_id : var.vnet_subnet_id)
  mode                  = "User"
  auto_scaling_enabled  = var.enable_auto_scaling
  node_count            = var.user_node_count
  min_count             = var.enable_auto_scaling ? var.user_min_count : null
  max_count             = var.enable_auto_scaling ? var.user_max_count : null
  max_pods              = var.max_pods_per_node
  os_disk_size_gb       = var.user_os_disk_size_gb
  os_disk_type          = var.os_disk_type

  tags = var.tags
}
