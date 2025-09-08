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

variable "kubernetes_version" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "application_gateway_id" {
  type = string
}

variable "admin_group_object_ids" {
  type = list(string)
}

variable "system_node_count" {
  type = number
}

variable "system_node_size" {
  type = string
}

variable "system_min_count" {
  type = number
}

variable "system_max_count" {
  type = number
}

variable "user_node_count" {
  type = number
}

variable "user_node_size" {
  type = string
}

variable "user_min_count" {
  type = number
}

variable "user_max_count" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
