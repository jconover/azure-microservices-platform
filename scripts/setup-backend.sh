#!/bin/bash
set -e

echo "=== Setting up Terraform Backend ==="

# Create resource group for Terraform state
az group create --name terraform-state-rg --location eastus

# Create storage accounts for each environment
for env in dev staging production; do
    STORAGE_ACCOUNT="tfstate${env}"
    
    # Create storage account
    az storage account create \
        --name ${STORAGE_ACCOUNT} \
        --resource-group terraform-state-rg \
        --location eastus \
        --sku Standard_LRS \
        --encryption-services blob
    
    # Get storage account key
    ACCOUNT_KEY=$(az storage account keys list \
        --resource-group terraform-state-rg \
        --account-name ${STORAGE_ACCOUNT} \
        --query '[0].value' -o tsv)
    
    # Create blob container
    az storage container create \
        --name tfstate \
        --account-name ${STORAGE_ACCOUNT} \
        --account-key ${ACCOUNT_KEY}
    
    echo "Created backend for ${env} environment"
done

echo "=== Terraform Backend Setup Complete ==="
