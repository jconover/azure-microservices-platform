variable "admin_group_object_id" {
  description = "Azure AD group object ID for AKS administrators"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32.6"
}
