output "cluster_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The Kubernetes Managed Cluster name."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "system_node_pool_name" {
  description = "The name of the system node pool."
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

output "user_node_pool_id" {
  description = "The ID of the user node pool."
  value       = azurerm_kubernetes_cluster_node_pool.user.id
}

output "user_node_pool_name" {
  description = "The name of the user node pool."
  value       = azurerm_kubernetes_cluster_node_pool.user.name
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "Kubernetes config object containing client keys and cluster certificates."
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "The Object ID of the user-assigned identity used by the Kubelet."
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "cluster_identity_principal_id" {
  description = "The Principal ID of the SystemAssigned Managed Identity of the cluster."
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for Workload Identity."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
