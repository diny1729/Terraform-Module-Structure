output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network."
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their respective subnet IDs."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their respective address prefixes."
  value       = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes }
}

output "nsg_ids" {
  description = "Map of NSG names to their respective IDs."
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}
