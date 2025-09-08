terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateproduction5ba8b4"
    container_name       = "tfstate"
    key                  = "production.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "production"
  prefix      = "microservices"
  location    = "East US"
  
  tags = {
    Environment = local.environment
    Project     = "Microservices Platform"
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg-${local.environment}"
  location = local.location
  tags     = local.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.prefix}-law-${local.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  prefix               = local.prefix
  environment          = local.environment
  location             = local.location
  resource_group_name  = azurerm_resource_group.main.name
  vnet_address_space   = ["10.0.0.0/16"]
  aks_subnet_prefix    = "10.0.1.0/24"
  appgw_subnet_prefix  = "10.0.2.0/24"
  vm_subnet_prefix     = "10.0.3.0/24"
  tags                 = local.tags
}

# Container Registry Module
module "acr" {
  source = "../../modules/acr"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Premium"
  retention_days      = 90
  allowed_ip_range    = "0.0.0.0/0"
  aks_subnet_id       = module.networking.aks_subnet_id
  aks_principal_id    = module.aks.cluster_identity_principal_id
  tags                = local.tags
}

# Application Gateway Module
module "app_gateway" {
  source = "../../modules/app-gateway"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  appgw_subnet_id     = module.networking.appgw_subnet_id
  capacity            = 2
  tags                = local.tags
}

# AKS Module
module "aks" {
  source = "../../modules/aks"

  prefix                     = local.prefix
  environment                = local.environment
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  kubernetes_version         = "1.27.3"
  aks_subnet_id              = module.networking.aks_subnet_id
  dns_service_ip             = "10.2.0.10"
  service_cidr               = "10.2.0.0/24"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  application_gateway_id     = module.app_gateway.application_gateway_id
  admin_group_object_ids     = [var.admin_group_object_id]
  
  # System node pool
  system_node_count = 3
  system_node_size  = "Standard_D4s_v3"
  system_min_count  = 3
  system_max_count  = 5
  
  # User node pool
  user_node_count = 3
  user_node_size  = "Standard_D8s_v3"
  user_min_count  = 3
  user_max_count  = 10
  
  tags = local.tags
}
