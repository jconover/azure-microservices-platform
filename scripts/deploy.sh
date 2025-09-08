#!/bin/bash
# Complete deployment script replacing Flux with ArgoCD
# This is a drop-in replacement for the original deploy.sh

set -e

# Configuration
ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="terraform/environments/${ENVIRONMENT}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "==================================================================="
echo -e "${BLUE}   Deploying Microservices Platform with ArgoCD - ${ENVIRONMENT}${NC}"
echo "==================================================================="
echo ""

# Validate environment
if [ ! -d "${TERRAFORM_DIR}" ]; then
    echo -e "${RED}Error: Environment '${ENVIRONMENT}' not found${NC}"
    echo "Available environments: dev, staging, production"
    exit 1
fi

# Step 1: Deploy Infrastructure with Terraform
echo -e "${YELLOW}Step 1: Deploying Azure infrastructure...${NC}"
cd ${TERRAFORM_DIR}

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

echo "Planning Terraform changes..."
terraform plan -out=tfplan

echo "Applying Terraform changes..."
terraform apply tfplan

# Get outputs
AKS_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "")
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
ACR_NAME=$(terraform output -raw acr_name 2>/dev/null || echo "")

if [ -z "$AKS_NAME" ]; then
    echo -e "${RED}Error: Could not get AKS cluster name from Terraform outputs${NC}"
    exit 1
fi

cd - > /dev/null

# Step 2: Configure kubectl
echo ""
echo -e "${YELLOW}Step 2: Configuring kubectl...${NC}"
az aks get-credentials \
    --resource-group ${RESOURCE_GROUP} \
    --name ${AKS_NAME} \
    --overwrite-existing

# Verify connection
if ! kubectl get nodes > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Connected to AKS cluster: ${AKS_NAME}"

# Step 3: Install ArgoCD (Much simpler than Flux!)
echo ""
echo -e "${YELLOW}Step 3: Installing ArgoCD...${NC}"

# Create namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD - Using stable version
echo "Downloading and installing ArgoCD components..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready (this may take 2-3 minutes)..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || {
    echo -e "${YELLOW}ArgoCD is taking longer than expected. Checking status...${NC}"
    kubectl get pods -n argocd
    echo "Waiting additional 60 seconds..."
    sleep 60
}

# Step 4: Configure ArgoCD Access
echo ""
echo -e "${YELLOW}Step 4: Configuring ArgoCD access...${NC}"

# Get initial admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

if [ -z "$ARGOCD_PASSWORD" ]; then
    echo -e "${YELLOW}Waiting for admin secret to be created...${NC}"
    sleep 10
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
fi

# Step 5: Create ArgoCD Applications
echo ""
echo -e "${YELLOW}Step 5: Setting up GitOps applications...${NC}"

# Create a simple application for the sample app
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: microservices
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ENVIRONMENT}-platform
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/microservices-platform-config
    targetRevision: main
    path: kubernetes/overlays/${ENVIRONMENT}
  destination:
    server: https://kubernetes.default.svc
    namespace: microservices
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
EOF

echo -e "${GREEN}✓${NC} ArgoCD application created"

# Step 6: Setup Access Methods
echo ""
echo -e "${YELLOW}Step 6: Setting up access to ArgoCD...${NC}"

# Option 1: Port-forward (immediate access)
echo -e "${BLUE}Starting port-forward for ArgoCD UI...${NC}"
echo "Run this command in a new terminal:"
echo ""
echo -e "${GREEN}kubectl port-forward svc/argocd-server -n argocd 8080:443${NC}"
echo ""

# Option 2: LoadBalancer (for cloud access)
echo "Alternatively, expose ArgoCD via LoadBalancer:"
echo -e "${GREEN}kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'${NC}"
echo ""

# Step 7: Display Summary
echo ""
echo "==================================================================="
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo "==================================================================="
echo ""
echo -e "${BLUE}Environment:${NC} ${ENVIRONMENT}"
echo -e "${BLUE}AKS Cluster:${NC} ${AKS_NAME}"
echo -e "${BLUE}ACR Registry:${NC} ${ACR_NAME}.azurecr.io"
echo ""
echo -e "${YELLOW}ArgoCD Access:${NC}"
echo "  URL: https://localhost:8080 (after port-forward)"
echo "  Username: admin"
echo "  Password: ${ARGOCD_PASSWORD}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Start port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Login to ArgoCD UI: https://localhost:8080"
echo "3. Configure your Git repository in ArgoCD"
echo "4. Deploy applications through the ArgoCD UI"
echo ""
echo -e "${YELLOW}To install ArgoCD CLI (optional):${NC}"
echo "  brew install argocd     # macOS"
echo "  OR"
echo "  curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "  chmod +x argocd && sudo mv argocd /usr/local/bin/"
echo ""

# Save credentials to file
cat > argocd-credentials-${ENVIRONMENT}.txt << EOF
ArgoCD Credentials for ${ENVIRONMENT}
=====================================
URL: https://localhost:8080
Username: admin
Password: ${ARGOCD_PASSWORD}
Date: $(date)
EOF

echo -e "${GREEN}Credentials saved to: argocd-credentials-${ENVIRONMENT}.txt${NC}"