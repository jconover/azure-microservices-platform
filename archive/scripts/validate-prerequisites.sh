#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================================================="
echo "   Validating Prerequisites for Microservices Platform"
echo "==================================================================="
echo ""

PREREQUISITES_MET=true

# Check Azure CLI
echo -n "Checking Azure CLI... "
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "version unknown")
    echo -e "${GREEN}✓${NC} Found version $AZ_VERSION"
else
    echo -e "${RED}✗${NC} Not found. Please install Azure CLI"
    echo "  Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    PREREQUISITES_MET=false
fi

# Check Terraform
echo -n "Checking Terraform... "
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version | head -n1 | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Found version $TF_VERSION"
else
    echo -e "${RED}✗${NC} Not found. Please install Terraform >= 1.0"
    echo "  Visit: https://www.terraform.io/downloads"
    PREREQUISITES_MET=false
fi

# Check kubectl
echo -n "Checking kubectl... "
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 || kubectl version --client -o json 2>/dev/null | grep gitVersion | head -1 | cut -d'"' -f4 || echo "version found")
    echo -e "${GREEN}✓${NC} Found version $KUBECTL_VERSION"
else
    echo -e "${RED}✗${NC} Not found. Please install kubectl"
    echo "  Visit: https://kubernetes.io/docs/tasks/tools/"
    PREREQUISITES_MET=false
fi

# Check Flux CLI
#echo -n "Checking Flux CLI... "
#if command -v flux &> /dev/null; then
#    FLUX_VERSION=$(flux version --client 2>/dev/null | grep flux | cut -d' ' -f2 || echo "version found")
#    echo -e "${GREEN}✓${NC} Found version $FLUX_VERSION"
#else
#    echo -e "${RED}✗${NC} Not found. Please install Flux CLI"
#    echo "  Run: curl -s https://fluxcd.io/install.sh | sudo bash"
#    PREREQUISITES_MET=false
#fi

# Check Ansible
echo -n "Checking Ansible... "
if command -v ansible &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2 | tr -d ']')
    echo -e "${GREEN}✓${NC} Found version $ANSIBLE_VERSION"
else
    echo -e "${YELLOW}!${NC} Not found. Ansible is optional but recommended"
    echo "  Run: pip install ansible"
fi

# Check Azure login status
echo -n "Checking Azure login status... "
if az account show &> /dev/null; then
    ACCOUNT=$(az account show --query name -o tsv 2>/dev/null || echo "Logged in")
    echo -e "${GREEN}✓${NC} Logged in to: $ACCOUNT"
else
    echo -e "${YELLOW}!${NC} Not logged in. Run: az login"
    PREREQUISITES_MET=false
fi

# Check for .env file
echo -n "Checking for .env configuration... "
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} Found .env file"
else
    echo -e "${YELLOW}!${NC} .env file not found. Copy from .env.example and configure"
    if [ -f ".env.example" ]; then
        echo "  Run: cp .env.example .env"
    fi
fi

echo ""
echo "==================================================================="
if [ "$PREREQUISITES_MET" = true ]; then
    echo -e "${GREEN}✓ All required prerequisites met! You're ready to deploy.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Configure your .env file if not already done"
    echo "2. Run: make setup (or ./scripts/setup-backend.sh)"
    echo "3. Run: make deploy-dev (or ./scripts/deploy.sh dev)"
else
    echo -e "${RED}✗ Some prerequisites are missing. Please install them before proceeding.${NC}"
fi
echo "==================================================================="
