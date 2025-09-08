locals {
  environment = "production"

  common_tags = merge(
    var.tags,
    {
      Environment = local.environment
      Terraform   = "true"
    }
  )
}
