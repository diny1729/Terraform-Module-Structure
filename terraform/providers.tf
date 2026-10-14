terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Uncomment the backend block below to enable remote state isolation across environments:
  # backend "azurerm" {
  #   # Values passed dynamically via -backend-config during terraform init:
  #   # resource_group_name  = "rg-terraform-state"
  #   # storage_account_name = "sttfstateeastus"
  #   # container_name       = "tfstate"
  #   # key                  = "dev.terraform.tfstate" (or qa / prod)
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}
