terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Uncomment when backend is configured
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatestore"
  #   container_name      = "tfstate"
  #   key                 = "dev-platform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    application_insights {
      disable_generated_rule = true
    }
  }
}

provider "random" {}

module "networking" {
  source = "../../modules/networking"

  project_name      = var.project_name
  environment       = local.environment
  location          = var.location
  vnet_cidr         = var.vnet_cidrs[local.environment]
  aks_subnet_cidr   = var.aks_subnet_cidrs[local.environment]
  appgw_subnet_cidr = var.appgw_subnet_cidrs[local.environment]
  vm_subnet_cidr    = var.vm_subnet_cidrs[local.environment]
  admin_ip_range    = var.admin_ip_range
  tags              = local.common_tags
}

module "acr" {
  source = "../../modules/acr"

  project_name = var.project_name
  environment  = local.environment
  location     = var.location
  acr_sku      = local.environment == "production" ? "Premium" : "Standard"
  tags         = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name   = var.project_name
  environment    = local.environment
  location       = var.location
  retention_days = local.environment == "production" ? 90 : 30
  tags           = local.common_tags
}

module "aks" {
  source = "../../modules/aks"

  project_name               = var.project_name
  environment                = local.environment
  location                   = var.location
  kubernetes_version         = var.kubernetes_version
  node_count                 = var.node_count[local.environment]
  node_size                  = var.node_size[local.environment]
  subnet_id                  = module.networking.aks_subnet_id
  acr_id                     = module.acr.acr_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  admin_group_object_ids     = var.admin_group_object_ids
  service_cidr               = "172.16.0.0/16"
  dns_service_ip             = "172.16.0.10"
  tags                       = local.common_tags
}

module "application_gateway" {
  source = "../../modules/application-gateway"

  project_name        = var.project_name
  environment         = local.environment
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.appgw_subnet_id
  appgw_capacity      = local.environment == "production" ? 3 : 2
  tags                = local.common_tags
}
