#!/bin/bash
# Fixed setup-backend.sh with unique storage account names

set -e

echo "=== Setting up Terraform Backend ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Azure${NC}"
    echo "Please run: az login"
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"

# Create resource group for Terraform state
echo "Creating resource group for Terraform state..."
az group create --name terraform-state-rg --location eastus

# Generate unique suffix for storage account names
# Use a combination of random and timestamp to ensure uniqueness
UNIQUE_ID=$(echo $RANDOM | md5sum | head -c 6)
echo ""
echo -e "${YELLOW}Using unique ID for storage accounts: ${UNIQUE_ID}${NC}"
echo ""

# Create storage accounts for each environment
for env in dev staging production; do
    # Storage account name must be 3-24 chars, lowercase alphanumeric only
    # Using format: tfstate{env}{uniqueid}
    STORAGE_ACCOUNT="tfstate${env}${UNIQUE_ID}"
    
    echo ""
    echo "Setting up backend for ${env} environment..."
    echo "Storage account name: ${STORAGE_ACCOUNT}"
    
    # Check if storage account name is available
    echo "Checking name availability..."
    NAME_AVAILABLE=$(az storage account check-name --name ${STORAGE_ACCOUNT} --query nameAvailable -o tsv)
    
    if [ "$NAME_AVAILABLE" == "false" ]; then
        echo -e "${YELLOW}Name ${STORAGE_ACCOUNT} is taken, trying alternative...${NC}"
        # Add more randomness if name is taken
        STORAGE_ACCOUNT="tfstate${env}${UNIQUE_ID}$(date +%s | tail -c 3)"
        echo "New name: ${STORAGE_ACCOUNT}"
    fi
    
    # Create storage account
    echo "Creating storage account: ${STORAGE_ACCOUNT}"
    az storage account create \
        --name ${STORAGE_ACCOUNT} \
        --resource-group terraform-state-rg \
        --location eastus \
        --sku Standard_LRS \
        --encryption-services blob \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false
    
    # Get storage account key
    ACCOUNT_KEY=$(az storage account keys list \
        --resource-group terraform-state-rg \
        --account-name ${STORAGE_ACCOUNT} \
        --query '[0].value' -o tsv)
    
    # Create blob container
    echo "Creating blob container..."
    az storage container create \
        --name tfstate \
        --account-name ${STORAGE_ACCOUNT} \
        --account-key "${ACCOUNT_KEY}"
    
    echo -e "${GREEN}✓${NC} Created backend for ${env} environment"
    echo "  Storage Account: ${STORAGE_ACCOUNT}"
    
    # Create backend configuration file
    cat > terraform-backend-${env}.conf << EOF
# Terraform Backend Configuration for ${env}
# Generated on $(date)
resource_group_name  = "terraform-state-rg"
storage_account_name = "${STORAGE_ACCOUNT}"
container_name       = "tfstate"
key                  = "${env}.terraform.tfstate"
EOF
    
    echo -e "${GREEN}✓${NC} Saved configuration to: terraform-backend-${env}.conf"
    
    # Update the terraform main.tf file if it exists
    TERRAFORM_FILE="terraform/environments/${env}/main.tf"
    if [ -f "${TERRAFORM_FILE}" ]; then
        # Create a backup
        cp ${TERRAFORM_FILE} ${TERRAFORM_FILE}.backup
        
        # Update the backend configuration
        sed -i.bak -e "/backend \"azurerm\"/,/}/ {
            s/storage_account_name = \".*\"/storage_account_name = \"${STORAGE_ACCOUNT}\"/
        }" ${TERRAFORM_FILE}
        
        echo -e "${GREEN}✓${NC} Updated ${TERRAFORM_FILE} with new storage account name"
    fi
done

# Create a summary file
cat > terraform-backend-summary.txt << EOF
Terraform Backend Configuration Summary
========================================
Generated: $(date)
Unique ID: ${UNIQUE_ID}

Storage Accounts Created:
-------------------------
EOF

for env in dev staging production; do
    STORAGE_ACCOUNT="tfstate${env}${UNIQUE_ID}"
    echo "${env}: ${STORAGE_ACCOUNT}" >> terraform-backend-summary.txt
    echo "  Config file: terraform-backend-${env}.conf" >> terraform-backend-summary.txt
done

cat >> terraform-backend-summary.txt << EOF

To initialize Terraform for each environment:
----------------------------------------------
cd terraform/environments/dev
terraform init -backend-config=../../../terraform-backend-dev.conf

cd terraform/environments/staging
terraform init -backend-config=../../../terraform-backend-staging.conf

cd terraform/environments/production
terraform init -backend-config=../../../terraform-backend-production.conf

Or use the -reconfigure flag if already initialized:
terraform init -reconfigure -backend-config=../../../terraform-backend-{env}.conf
EOF

echo ""
echo "=== Terraform Backend Setup Complete ==="
echo ""
echo -e "${GREEN}✓ All storage accounts created successfully!${NC}"
echo ""
echo "Storage accounts created:"
for env in dev staging production; do
    STORAGE_ACCOUNT="tfstate${env}${UNIQUE_ID}"
    echo "  ${env}: ${STORAGE_ACCOUNT}"
done
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "1. Backend configuration files created: terraform-backend-*.conf"
echo "2. Use these files when initializing Terraform"
echo "3. Summary saved to: terraform-backend-summary.txt"
echo ""
echo "Next steps:"
echo "  cd terraform/environments/dev"
echo "  terraform init -backend-config=../../../terraform-backend-dev.conf"
echo "  terraform plan"
echo ""