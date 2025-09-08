#!/bin/bash

# Script to manually clean up Azure resources if Terraform destroy fails

set -e

ENVIRONMENT=${1:-dev}
PROJECT_NAME="microservices"

echo "⚠️  WARNING: This will delete all resources for the $ENVIRONMENT environment!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

echo "🧹 Cleaning up Azure resources for $ENVIRONMENT environment..."

# List of resource groups to delete
RESOURCE_GROUPS=(
  "${PROJECT_NAME}-${ENVIRONMENT}-monitoring-rg"
  "${PROJECT_NAME}-${ENVIRONMENT}-aks-rg"
  "${PROJECT_NAME}-${ENVIRONMENT}-network-rg"
  "${PROJECT_NAME}-acr-rg"
)

# Delete resource groups
for RG in "${RESOURCE_GROUPS[@]}"; do
  if az group exists --name "$RG" 2>/dev/null; then
    echo "Deleting resource group: $RG"
    az group delete --name "$RG" --yes --no-wait || true
  else
    echo "Resource group $RG does not exist, skipping..."
  fi
done

# Also delete the AKS managed resource group (MC_*)
MC_RG=$(az group list --query "[?starts_with(name, 'MC_${PROJECT_NAME}-${ENVIRONMENT}')].name" -o tsv)
if [ ! -z "$MC_RG" ]; then
  echo "Deleting AKS managed resource group: $MC_RG"
  az group delete --name "$MC_RG" --yes --no-wait || true
fi

echo "✅ Cleanup initiated. Resources are being deleted in the background."
echo "Check deletion status with: az group list --query \"[?contains(name, '${PROJECT_NAME}')].{Name:name, State:properties.provisioningState}\""
