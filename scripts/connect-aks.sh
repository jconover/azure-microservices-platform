#!/bin/bash

# Script to connect to AKS clusters

ENVIRONMENT=${1:-dev}
PROJECT_NAME="microservices"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: ./connect-aks.sh [dev|staging|production]"
  exit 1
fi

RESOURCE_GROUP="${PROJECT_NAME}-${ENVIRONMENT}-aks-rg"
CLUSTER_NAME="${PROJECT_NAME}-${ENVIRONMENT}-aks"

echo "Getting AKS credentials for $ENVIRONMENT environment..."
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --overwrite-existing

echo "Connected to $CLUSTER_NAME"
kubectl config current-context
kubectl get nodes
