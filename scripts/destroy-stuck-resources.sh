#!/bin/bash

# Script to destroy stuck resources

set -e

ENVIRONMENT=${1:-dev}

echo "⚠️  This will destroy and recreate stuck resources for $ENVIRONMENT"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

cd terraform/environments/$ENVIRONMENT

# Try to destroy specific stuck resources
echo "Attempting to destroy Application Insights..."
terraform destroy -target=module.monitoring.azurerm_application_insights.main -auto-approve || true

echo "Attempting to destroy ACR..."
terraform destroy -target=module.acr -auto-approve || true

echo "Attempting to destroy AKS..."
terraform destroy -target=module.aks -auto-approve || true

echo "Now reapplying all resources..."
terraform apply -auto-approve
