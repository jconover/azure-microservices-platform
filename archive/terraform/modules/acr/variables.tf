variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "retention_days" {
  type = number
}

variable "allowed_ip_range" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "aks_principal_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
