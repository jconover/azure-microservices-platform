#!/bin/bash

# Script to set up Terraform backend storage in Azure

RESOURCE_GROUP="terraform-state-rg"
STORAGE_ACCOUNT="tfstatestore$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob

echo "Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

echo "Creating blob container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

echo "Storage account created: $STORAGE_ACCOUNT"
echo "Update terraform/main.tf with these values:"
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  container_name       = \"$CONTAINER_NAME\""
