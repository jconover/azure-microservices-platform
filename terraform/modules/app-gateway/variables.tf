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

variable "appgw_subnet_id" {
  type = string
}

variable "capacity" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
