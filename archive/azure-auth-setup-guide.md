# Azure Authentication & Authorization Setup Guide

## Prerequisites - What You Need First

### 1. Azure Account
- Sign up for Azure at https://azure.microsoft.com/free/
- You'll get $200 free credits for 30 days (perfect for learning)
- Credit card required but won't be charged during free trial

### 2. Install Required Tools
```bash
# Azure CLI (choose based on your OS)
# macOS
brew install azure-cli

# Windows (use PowerShell as Administrator)
winget install Microsoft.AzureCLI

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version
```

## Step 1: Initial Azure Setup

### Login to Azure
```bash
# This opens a browser for authentication
az login

# List your subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "Your-Subscription-Name-or-ID"

# Verify current subscription
az account show
```

## Step 2: Create Service Principal (Automated Authentication)

A Service Principal is like a "robot user" that your scripts and tools use to authenticate with Azure.

### Create Service Principal for Terraform
```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "terraform-sp-microservices" \
  --role="Contributor" \
  --scopes="/subscriptions/$(az account show --query id -o tsv)"
```

**Save this output immediately!** You'll see something like:
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",        # This is your CLIENT_ID
  "displayName": "terraform-sp-microservices",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",     # This is your CLIENT_SECRET
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"        # This is your TENANT_ID
}
```

### Get your Subscription ID
```bash
az account show --query id -o tsv
# Save this as your SUBSCRIPTION_ID
```

## Step 3: Set Up Environment Variables

### For Linux/macOS (add to ~/.bashrc or ~/.zshrc)
```bash
# Azure Service Principal Credentials
export ARM_CLIENT_ID="your-app-id-from-above"
export ARM_CLIENT_SECRET="your-password-from-above"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Reload your shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

### For Windows (PowerShell)
```powershell
# Set environment variables for current session
$env:ARM_CLIENT_ID="your-app-id-from-above"
$env:ARM_CLIENT_SECRET="your-password-from-above"
$env:ARM_SUBSCRIPTION_ID="your-subscription-id"
$env:ARM_TENANT_ID="your-tenant-id"

# To make them permanent, use System Properties or:
[System.Environment]::SetEnvironmentVariable("ARM_CLIENT_ID", "your-app-id", "User")
[System.Environment]::SetEnvironmentVariable("ARM_CLIENT_SECRET", "your-password", "User")
[System.Environment]::SetEnvironmentVariable("ARM_SUBSCRIPTION_ID", "your-subscription-id", "User")
[System.Environment]::SetEnvironmentVariable("ARM_TENANT_ID", "your-tenant-id", "User")
```

## Step 4: GitHub Secrets Setup (for CI/CD)

If using GitHub Actions, add these secrets to your repository:

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add these repository secrets:
   - `ARM_CLIENT_ID` - Your service principal app ID
   - `ARM_CLIENT_SECRET` - Your service principal password
   - `ARM_SUBSCRIPTION_ID` - Your Azure subscription ID
   - `ARM_TENANT_ID` - Your Azure tenant ID
   - `ACR_REGISTRY` - Will be created later (format: `acrdev123456.azurecr.io`)
   - `ACR_USERNAME` - Service principal app ID (same as ARM_CLIENT_ID)
   - `ACR_PASSWORD` - Service principal password (same as ARM_CLIENT_SECRET)

## Step 5: Container Registry Authentication Setup

After Terraform creates your ACR, set up authentication:

```bash
# Get ACR name (after running Terraform)
ACR_NAME=$(az acr list --query "[0].name" -o tsv)

# Enable admin user (for development only)
az acr update -n $ACR_NAME --admin-enabled true

# Get ACR credentials
az acr credential show -n $ACR_NAME

# Grant service principal access to ACR
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/rg-microservices-platform-dev/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME" \
  --role "AcrPush"
```

## Step 6: Kubernetes (AKS) Authentication

After AKS is created, get credentials:

```bash
# Get AKS credentials for kubectl
az aks get-credentials \
  --resource-group "rg-microservices-platform-dev" \
  --name "aks-dev-eus"

# Verify connection
kubectl get nodes
```

## Step 7: Create Azure Key Vault (for Secrets)

```bash
# Create Key Vault
az keyvault create \
  --name "kv-microservices-dev" \
  --resource-group "rg-microservices-platform-dev" \
  --location "eastus"

# Grant service principal access to Key Vault
az keyvault set-policy \
  --name "kv-microservices-dev" \
  --spn $ARM_CLIENT_ID \
  --secret-permissions get list set delete \
  --key-permissions get list create delete
```

## Step 8: Modified Bootstrap Script with Auth

Create a file `scripts/setup-auth.sh`:

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Azure Authentication Setup Script${NC}"

# Check if already logged in
if ! az account show &>/dev/null; then
    echo -e "${YELLOW}Please login to Azure...${NC}"
    az login
fi

# Get current subscription
CURRENT_SUB=$(az account show --query name -o tsv)
echo -e "${GREEN}Current subscription: $CURRENT_SUB${NC}"

# Ask if user wants to create service principal
read -p "Do you want to create a new service principal? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SP_NAME="terraform-sp-microservices-$(date +%s)"
    echo -e "${YELLOW}Creating service principal: $SP_NAME${NC}"
    
    # Create service principal
    SP_OUTPUT=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role="Contributor" \
        --scopes="/subscriptions/$(az account show --query id -o tsv)" \
        --output json)
    
    # Parse output
    CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.appId')
    CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.password')
    TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenant')
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    
    # Create .env file
    cat > .env << EOF
# Azure Service Principal Credentials
export ARM_CLIENT_ID="$CLIENT_ID"
export ARM_CLIENT_SECRET="$CLIENT_SECRET"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_TENANT_ID="$TENANT_ID"

# Azure Configuration
export AZURE_REGION="eastus"
export PROJECT_NAME="microservices-platform"
EOF
    
    echo -e "${GREEN}Service principal created successfully!${NC}"
    echo -e "${GREEN}Credentials saved to .env file${NC}"
    echo -e "${YELLOW}Run 'source .env' to load credentials${NC}"
    
    # Display credentials
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Save these credentials securely:${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "ARM_CLIENT_ID=$CLIENT_ID"
    echo "ARM_CLIENT_SECRET=$CLIENT_SECRET"
    echo "ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
    echo "ARM_TENANT_ID=$TENANT_ID"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${YELLOW}Please set up environment variables manually${NC}"
fi

# Verify service principal (if env vars are set)
if [[ ! -z "$ARM_CLIENT_ID" ]]; then
    echo -e "${YELLOW}Testing service principal authentication...${NC}"
    
    # Test authentication
    az login --service-principal \
        --username $ARM_CLIENT_ID \
        --password $ARM_CLIENT_SECRET \
        --tenant $ARM_TENANT_ID &>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Service principal authentication successful!${NC}"
        # Switch back to user authentication
        az login &>/dev/null
    else
        echo -e "${RED}Service principal authentication failed!${NC}"
    fi
fi
```

## Step 9: Security Best Practices

### 1. Use Azure Key Vault for Secrets
```bash
# Store secrets in Key Vault instead of environment variables
az keyvault secret set \
  --vault-name "kv-microservices-dev" \
  --name "terraform-client-secret" \
  --value "$ARM_CLIENT_SECRET"
```

### 2. Rotate Service Principal Credentials
```bash
# Reset service principal password
az ad sp credential reset \
  --name $ARM_CLIENT_ID \
  --years 1
```

### 3. Use Managed Identities (for AKS)
```bash
# Enable managed identity for AKS (in Terraform)
# This is already configured in the provided Terraform code
```

### 4. Limit Service Principal Permissions
```bash
# Create custom role with minimum permissions
az role definition create --role-definition '{
  "Name": "Terraform Deployer",
  "Description": "Custom role for Terraform deployments",
  "Actions": [
    "Microsoft.Resources/subscriptions/resourceGroups/*",
    "Microsoft.ContainerService/*",
    "Microsoft.Network/*",
    "Microsoft.ContainerRegistry/*",
    "Microsoft.Storage/*"
  ],
  "AssignableScopes": ["/subscriptions/YOUR_SUBSCRIPTION_ID"]
}'
```

## Step 10: Verify Everything Works

Run this verification script:

```bash
#!/bin/bash
# save as verify-setup.sh

echo "Checking Azure CLI..."
if command -v az &> /dev/null; then
    echo "✓ Azure CLI installed: $(az --version | head -n1)"
else
    echo "✗ Azure CLI not found"
fi

echo "Checking Azure authentication..."
if az account show &> /dev/null; then
    echo "✓ Logged in as: $(az account show --query user.name -o tsv)"
    echo "✓ Subscription: $(az account show --query name -o tsv)"
else
    echo "✗ Not logged in to Azure"
fi

echo "Checking environment variables..."
for var in ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_SUBSCRIPTION_ID ARM_TENANT_ID; do
    if [[ -z "${!var}" ]]; then
        echo "✗ $var is not set"
    else
        echo "✓ $var is set"
    fi
done

echo "Checking Terraform..."
if command -v terraform &> /dev/null; then
    echo "✓ Terraform installed: $(terraform --version | head -n1)"
else
    echo "✗ Terraform not found"
fi

echo "Checking kubectl..."
if command -v kubectl &> /dev/null; then
    echo "✓ kubectl installed: $(kubectl version --client --short 2>/dev/null)"
else
    echo "✗ kubectl not found"
fi
```

## Common Issues and Solutions

### Issue 1: "Authorization failed"
**Solution**: Your service principal might not have enough permissions. Grant Contributor role:
```bash
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID"
```

### Issue 2: "Subscription not found"
**Solution**: Make sure you're using the correct subscription:
```bash
az account list --output table
az account set --subscription "Correct-Subscription-Name"
```

### Issue 3: "Service principal not found"
**Solution**: The service principal might have been deleted. Create a new one:
```bash
az ad sp create-for-rbac --name "terraform-sp-new" --role="Contributor"
```

### Issue 4: "Cannot pull images from ACR"
**Solution**: Grant AcrPull permission to AKS:
```bash
# This is handled in Terraform, but manually:
az aks update \
  --name aks-dev-eus \
  --resource-group rg-microservices-platform-dev \
  --attach-acr $ACR_NAME
```

## Quick Start After Setup

Once everything is configured:

```bash
# 1. Load your credentials
source .env

# 2. Verify setup
./scripts/verify-setup.sh

# 3. Run the main bootstrap script
./scripts/bootstrap.sh

# 4. Access your resources
kubectl get nodes
az aks list --output table
az acr list --output table
```

## Security Checklist

- [ ] Service principal created with minimum required permissions
- [ ] Credentials stored securely (not in code)
- [ ] Key Vault created for secrets management
- [ ] Service principal password has expiration date
- [ ] GitHub secrets configured (if using GitHub Actions)
- [ ] Network security groups configured
- [ ] RBAC enabled on AKS
- [ ] Container registry has authentication enabled
- [ ] Regular credential rotation scheduled

## Next Steps

1. Run the setup-auth.sh script to create credentials
2. Source the .env file to load credentials
3. Run the main bootstrap.sh script to deploy infrastructure
4. Configure ArgoCD for GitOps
5. Deploy your first microservice

## Support Resources

- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure Service Principal Guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Authentication](https://docs.microsoft.com/en-us/azure/aks/concepts-identity)