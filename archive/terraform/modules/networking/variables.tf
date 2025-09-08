variable "prefix" {
  description = "Prefix for resource names"
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

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "AKS subnet prefix"
  type        = string
}

variable "appgw_subnet_prefix" {
  description = "Application Gateway subnet prefix"
  type        = string
}

variable "vm_subnet_prefix" {
  description = "VM subnet prefix"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
