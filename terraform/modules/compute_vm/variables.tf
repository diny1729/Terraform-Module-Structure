variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the VM will be deployed."
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the VM NIC will be attached."
  type        = string
}

variable "vm_size" {
  description = "Azure VM Size (SKU)."
  type        = string
  default     = "Standard_B2s"
}

variable "enable_public_ip" {
  description = "Whether to allocate a public IP for this VM."
  type        = bool
  default     = false
}

variable "private_ip_address_allocation" {
  description = "Allocation method for private IP (Dynamic or Static)."
  type        = string
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "Static private IP address (if allocation is Static)."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Administrator username for the VM."
  type        = string
  default     = "azureuser"
}

variable "disable_password_authentication" {
  description = "Whether password authentication should be disabled (true for SSH keys only)."
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "Administrator password for the VM (required if disable_password_authentication is false)."
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_ssh_public_key" {
  description = "Public SSH key for authentication (required if disable_password_authentication is true)."
  type        = string
  default     = ""
}

variable "os_disk_type" {
  description = "Type of storage account for the OS disk (Standard_LRS, Premium_LRS, StandardSSD_LRS)."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB."
  type        = number
  default     = 30
}

variable "image_publisher" {
  description = "OS Image publisher."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "OS Image offer."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "OS Image SKU."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "OS Image version."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to compute resources."
  type        = map(string)
  default     = {}
}
