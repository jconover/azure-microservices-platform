#!/bin/bash

# Comprehensive script to fix all Terraform issues

set -e

ENVIRONMENT=${1:-dev}

echo "🔧 Running comprehensive Terraform fix for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

echo "1️⃣ Cleaning up Terraform cache..."
rm -rf .terraform .terraform.lock.hcl

echo "2️⃣ Formatting Terraform files..."
terraform fmt -recursive ../..

echo "3️⃣ Initializing Terraform..."
terraform init

echo "4️⃣ Validating configuration..."
if terraform validate; then
  echo "✅ Configuration is valid!"
else
  echo "❌ Validation failed. Checking for common issues..."
  
  # Check for missing variables
  echo "Checking for missing variables..."
  terraform validate 2>&1 | grep -o "var\.[a-zA-Z_]*" | sort -u || true
  
  # Check for missing modules
  echo "Checking for missing modules..."
  ls ../../modules/
fi

echo "5️⃣ Running terraform plan (output to plan.out)..."
terraform plan -out=plan.out 2>&1 | tee plan.log || true

echo ""
echo "📊 Summary:"
echo "  - Environment: $ENVIRONMENT"
echo "  - Config location: $(pwd)"
echo "  - Validation status: $(terraform validate &>/dev/null && echo "✅ Valid" || echo "❌ Invalid")"
echo ""
echo "Check plan.log for detailed output"
