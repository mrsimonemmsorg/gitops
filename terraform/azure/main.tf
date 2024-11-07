terraform {
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "azure/terraform.tfstate"
    resource_group_name  = "sje-azure-state"
    storage_account_name = "k17s7zcpsjeazure"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2, < 4.0.0"
    }
     kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.32.0, < 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubefirst.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.cluster_ca_certificate)
}

locals {
  cluster_name         = "sje-azure"
  dns_zone             = "azure.kubefirst.simonemms.com"
  dns_zone_rg          = "dns-zones"
  kube_config_filename = "../../../kubeconfig"
  kubernetes_version   = "1.29.7" # Latest stable at time of writing
  node_count           = tonumber("3")
  tags = {
    ClusterName   = local.cluster_name
    kubefirst     = "true"
    ProvisionedBy = "kubefirst"
  }
  use_dns_zone = try(local.dns_zone != "" && local.dns_zone_rg != "", false)
  vm_size      = "Standard_D2s_v4"
}

# All resources must be created in a resource group - the location will be inferred from this
resource "azurerm_resource_group" "kubefirst" {
  name     = local.cluster_name
  location = "eastus"

  tags = local.tags
}

data "azurerm_client_config" "current" {}
