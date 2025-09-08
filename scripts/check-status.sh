#!/bin/bash

# Script to check deployment status

set -e

ENVIRONMENT=${1:-dev}

echo "📊 Checking deployment status for $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

echo ""
echo "🔍 Terraform State Resources:"
terraform state list 2>/dev/null || echo "No resources in state"

echo ""
echo "🔧 Current Outputs:"
terraform output 2>/dev/null || echo "No outputs available"

echo ""
echo "☁️ Azure Resource Groups:"
az group list --query "[?contains(name, 'microservices')].{Name:name, Location:location, Status:properties.provisioningState}" -o table 2>/dev/null || echo "Azure CLI not configured"

echo ""
echo "📦 Azure Container Registries:"
az acr list --query "[?contains(name, 'microservices')].{Name:name, Location:location, SKU:sku.name}" -o table 2>/dev/null || true

echo ""
echo "🎯 AKS Clusters:"
az aks list --query "[?contains(name, 'microservices')].{Name:name, Location:location, Version:kubernetesVersion, Status:provisioningState}" -o table 2>/dev/null || true
