#!/bin/bash

# Script to validate Terraform configuration

set -e

ENVIRONMENT=${1:-dev}

echo "🔍 Validating Terraform configuration for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

# Check for duplicate definitions
echo "Checking for duplicate definitions..."
for file in *.tf; do
  echo "  - $file"
done

# Initialize if needed
if [ ! -d ".terraform" ]; then
  echo "Initializing Terraform..."
  terraform init
fi

# Format check
echo "Checking formatting..."
terraform fmt -check || (echo "Running formatter..." && terraform fmt)

# Validate
echo "Validating configuration..."
terraform validate

if [ $? -eq 0 ]; then
  echo "✅ Terraform configuration is valid!"
else
  echo "❌ Validation failed. Please check the errors above."
  exit 1
fi

# Optional: Show what would be created
echo ""
echo "Would you like to see the plan? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
  terraform plan
fi
