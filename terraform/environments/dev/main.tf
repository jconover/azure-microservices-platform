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
    storage_account_name = "tfstatedev"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "dev"
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
  retention_in_days   = 30
  tags                = local.tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  prefix               = local.prefix
  environment          = local.environment
  location             = local.location
  resource_group_name  = azurerm_resource_group.main.name
  vnet_address_space   = ["10.1.0.0/16"]
  aks_subnet_prefix    = "10.1.1.0/24"
  appgw_subnet_prefix  = "10.1.2.0/24"
  vm_subnet_prefix     = "10.1.3.0/24"
  tags                 = local.tags
}

# Container Registry Module
module "acr" {
  source = "../../modules/acr"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  retention_days      = 30
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
  capacity            = 1
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
  dns_service_ip             = "10.3.0.10"
  service_cidr               = "10.3.0.0/24"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  application_gateway_id     = module.app_gateway.application_gateway_id
  admin_group_object_ids     = [var.admin_group_object_id]
  
  # System node pool
  system_node_count = 1
  system_node_size  = "Standard_D2s_v3"
  system_min_count  = 1
  system_max_count  = 3
  
  # User node pool
  user_node_count = 1
  user_node_size  = "Standard_D4s_v3"
  user_min_count  = 1
  user_max_count  = 5
  
  tags = local.tags
}
