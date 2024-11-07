terraform {
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "vault/terraform.tfstate"
    resource_group_name  = "sje-azure-state"
    storage_account_name = "k17s7zcpsjeazure"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "vault" {
  skip_tls_verify = "true"
}

data "azurerm_client_config" "current" {}
