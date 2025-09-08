#!/bin/bash

# Script to reinitialize Terraform after fixing provider configuration

set -e

ENVIRONMENT=${1:-dev}

echo "🔄 Reinitializing Terraform for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

# Remove existing Terraform state and providers
echo "Cleaning up existing Terraform files..."
rm -rf .terraform
rm -f .terraform.lock.hcl

# Reinitialize Terraform
echo "Initializing Terraform..."
terraform init

# Refresh state
echo "Refreshing Terraform state..."
terraform refresh || true

echo "✅ Terraform reinitialized successfully!"
echo ""
echo "You can now run:"
echo "  terraform plan"
echo "  terraform apply"
echo "  terraform destroy"
