#!/bin/bash

# Quick apply script for Terraform

set -e

ENVIRONMENT=${1:-dev}
AUTO_APPROVE=${2:-false}

echo "🚀 Quick apply for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

# Check if we need to init
if [ ! -d ".terraform" ]; then
  echo "Initializing Terraform..."
  terraform init
fi

# Format code
echo "Formatting Terraform files..."
terraform fmt -recursive ../..

# Validate
echo "Validating configuration..."
if ! terraform validate; then
  echo "❌ Validation failed!"
  exit 1
fi

# Plan
echo "Planning changes..."
terraform plan -out=tfplan

if [ "$AUTO_APPROVE" == "true" ]; then
  echo "Auto-applying changes..."
  terraform apply tfplan
else
  echo ""
  echo "Review the plan above. Apply changes? (yes/no)"
  read -r response
  if [[ "$response" == "yes" ]]; then
    terraform apply tfplan
  else
    echo "Cancelled. Run 'terraform apply tfplan' when ready."
  fi
fi
