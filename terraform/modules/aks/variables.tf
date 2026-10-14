variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the AKS cluster will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnets (BYO Network)
# ---------------------------------------------------------------------------------------------------------------------
variable "vnet_subnet_id" {
  description = "Default fallback Subnet ID for AKS nodes."
  type        = string
  default     = null
}

variable "system_node_subnet_id" {
  description = "Subnet ID dedicated to the System Node Pool."
  type        = string
  default     = null
}

variable "user_node_subnet_id" {
  description = "Subnet ID dedicated to the User Node Pool."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# System Node Pool
# ---------------------------------------------------------------------------------------------------------------------
variable "system_node_pool_name" {
  description = "The name of the system node pool."
  type        = string
  default     = "systempool"
}

variable "system_node_count" {
  description = "Initial number of nodes in the system node pool."
  type        = number
  default     = 2
}

variable "system_node_vm_size" {
  description = "The size of the Virtual Machines for the system node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "system_min_count" {
  description = "The minimum number of nodes for the system node pool (min: 2)."
  type        = number
  default     = 2
}

variable "system_max_count" {
  description = "The maximum number of nodes for the system node pool."
  type        = number
  default     = 5
}

variable "only_critical_addons_enabled" {
  description = "Enabling this taints system nodes with CriticalAddonsOnly=true so only system pods run here."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------------------------------------------------
# User Node Pool
# ---------------------------------------------------------------------------------------------------------------------
variable "user_node_pool_name" {
  description = "The name of the user node pool."
  type        = string
  default     = "userpool"
}

variable "user_node_count" {
  description = "Initial number of nodes in the user node pool (min: 2)."
  type        = number
  default     = 2
}

variable "user_node_vm_size" {
  description = "The size of the Virtual Machines for the user node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_min_count" {
  description = "The minimum number of nodes for the user node pool (min: 2)."
  type        = number
  default     = 2
}

variable "user_max_count" {
  description = "The maximum number of nodes for the user node pool."
  type        = number
  default     = 6
}

variable "user_os_disk_size_gb" {
  description = "OS disk size for user pool nodes in GB."
  type        = number
  default     = 100
}

# ---------------------------------------------------------------------------------------------------------------------
# General Node Pool Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "enable_auto_scaling" {
  description = "Should auto-scaler be enabled on node pools?"
  type        = bool
  default     = true
}

variable "max_pods_per_node" {
  description = "The maximum number of pods that can run on a single node (up to 110)."
  type        = number
  default     = 110
}

variable "os_disk_size_gb" {
  description = "The size of the OS Disk in GB for system nodes."
  type        = number
  default     = 50
}

variable "os_disk_type" {
  description = "The type of disk for the OS (Managed or Ephemeral)."
  type        = string
  default     = "Managed"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure CNI Overlay Network Profile
# ---------------------------------------------------------------------------------------------------------------------
variable "network_policy" {
  description = "Network policy to be used (azure or calico)."
  type        = string
  default     = "azure"
}

variable "pod_cidr" {
  description = "The CIDR block from which pod IP addresses are allocated in Azure CNI Overlay (must not overlap with VNet)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "The Network Range used by Kubernetes services (CIDR notation, must not overlap with VNet or Pod CIDR)."
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster DNS service."
  type        = string
  default     = "172.16.0.10"
}

variable "tags" {
  description = "Tags to apply to AKS resources."
  type        = map(string)
  default     = {}
}
