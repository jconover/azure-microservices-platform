variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservices"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.28"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
