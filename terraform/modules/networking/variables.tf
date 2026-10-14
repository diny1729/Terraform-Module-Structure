variable "resource_group_name" {
  description = "The name of the resource group in which to create the network resources."
  type        = string
}

variable "location" {
  description = "The Azure region where network resources will be provisioned."
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network in CIDR notation."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create with their configurations."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name         = string
      service_name = string
      actions      = optional(list(string), [])
    })), [])
  }))
}

variable "nsg_rules" {
  description = "Map of NSG definitions and their security rules."
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = optional(string)
    destination_port_ranges    = optional(list(string))
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  })))
  default = {}
}

variable "nsg_associations" {
  description = "Map of subnet names to NSG keys to associate."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
