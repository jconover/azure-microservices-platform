variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservices"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.32.6"
}

variable "node_count" {
  description = "Number of nodes in AKS cluster"
  type        = map(number)
  default = {
    dev        = 2
    staging    = 3
    production = 5
  }
}

variable "node_size" {
  description = "VM size for AKS nodes"
  type        = map(string)
  default = {
    dev        = "Standard_D2s_v3"
    staging    = "Standard_D4s_v3"
    production = "Standard_D8s_v3"
  }
}

variable "vnet_cidrs" {
  description = "CIDR blocks for VNets"
  type        = map(string)
  default = {
    dev        = "10.0.0.0/16"
    staging    = "10.1.0.0/16"
    production = "10.2.0.0/16"
  }
}

variable "aks_subnet_cidrs" {
  description = "CIDR blocks for AKS subnets"
  type        = map(string)
  default = {
    dev        = "10.0.1.0/24"
    staging    = "10.1.1.0/24"
    production = "10.2.1.0/24"
  }
}

variable "appgw_subnet_cidrs" {
  description = "CIDR blocks for Application Gateway subnets"
  type        = map(string)
  default = {
    dev        = "10.0.2.0/24"
    staging    = "10.1.2.0/24"
    production = "10.2.2.0/24"
  }
}

variable "vm_subnet_cidrs" {
  description = "CIDR blocks for VM subnets"
  type        = map(string)
  default = {
    dev        = "10.0.3.0/24"
    staging    = "10.1.3.0/24"
    production = "10.2.3.0/24"
  }
}

variable "admin_ip_range" {
  description = "IP range for admin access"
  type        = string
  default     = "*"
}

variable "admin_group_object_ids" {
  description = "AAD group object IDs for cluster admin"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Microservices Platform"
  }
}
