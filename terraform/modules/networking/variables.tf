variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
}

variable "aks_subnet_cidr" {
  description = "CIDR block for AKS subnet"
  type        = string
}

variable "appgw_subnet_cidr" {
  description = "CIDR block for Application Gateway subnet"
  type        = string
}

variable "vm_subnet_cidr" {
  description = "CIDR block for VM subnet"
  type        = string
}

variable "admin_ip_range" {
  description = "IP range for admin access"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
