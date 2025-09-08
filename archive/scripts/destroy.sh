#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="../terraform/environments/${ENVIRONMENT}"

echo "=== Destroying Microservices Platform - ${ENVIRONMENT} ==="

read -p "Are you sure you want to destroy the ${ENVIRONMENT} environment? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Destruction cancelled"
    exit 0
fi

cd ${TERRAFORM_DIR}
terraform destroy -auto-approve

echo "=== Destruction Complete ==="
