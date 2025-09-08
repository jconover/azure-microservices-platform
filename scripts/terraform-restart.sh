#!/bin/bash

# Script to restart Terraform deployment after fixing issues

set -e

ENVIRONMENT=${1:-dev}

echo "🔄 Restarting Terraform deployment for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

echo "1️⃣ Refreshing state..."
terraform refresh || true

echo "2️⃣ Checking current resources..."
terraform state list

echo "3️⃣ Planning changes..."
terraform plan -out=tfplan

echo "4️⃣ Review the plan above. Apply changes? (yes/no)"
read -r response
if [[ "$response" == "yes" ]]; then
  terraform apply tfplan
else
  echo "Cancelled. Run 'terraform apply tfplan' when ready."
fi
