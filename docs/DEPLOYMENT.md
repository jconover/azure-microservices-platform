# Deployment Guide

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Tools Installation**:
   ```bash
   # Azure CLI
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Terraform
   wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   
   # kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   
   # ArgoCD CLI
   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
   sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
   ```

## Initial Setup

### 1. Azure Authentication
```bash
az login
az account set --subscription <your-subscription-id>
```

### 2. Create Terraform Backend
```bash
chmod +x scripts/setup-terraform-backend.sh
./scripts/setup-terraform-backend.sh
```

### 3. Configure Terraform Variables
```bash
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
# Edit terraform.tfvars with your values
```

## Deploy Infrastructure

### Development Environment
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Connect to AKS
```bash
chmod +x scripts/connect-aks.sh
./scripts/connect-aks.sh dev
```

### Install ArgoCD
```bash
chmod +x scripts/install-argocd.sh
./scripts/install-argocd.sh
```

### Configure ArgoCD Applications
```bash
kubectl apply -f argocd/applications/
```

## Configure VMs with Ansible

### 1. Create Inventory
```bash
cp ansible/inventory/sample ansible/inventory/dev
# Edit inventory file with your VM IPs
```

### 2. Run Playbooks
```bash
cd ansible
ansible-playbook -i inventory/dev playbooks/site.yml
```

## Deploying Applications

### 1. Build and Push Images
```bash
# Login to ACR
az acr login --name <your-acr-name>

# Build and push
docker build -t <your-acr-name>.azurecr.io/app:v1.0.0 .
docker push <your-acr-name>.azurecr.io/app:v1.0.0
```

### 2. Update Kubernetes Manifests
```bash
# Update image tags in kubernetes/base/deployment.yaml
# Commit and push to Git
```

### 3. Sync with ArgoCD
```bash
argocd app sync dev-apps
```

## Monitoring Setup

### Access Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Navigate to http://localhost:3000
```

### Access Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Navigate to http://localhost:9090
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### ArgoCD Issues
```bash
argocd app get <app-name>
argocd app sync <app-name> --force
```

### Terraform Issues
```bash
terraform refresh
terraform state list
terraform state show <resource>
```

## Cleanup

### Destroy Environment
```bash
cd terraform/environments/dev
terraform destroy
```

### Remove ArgoCD
```bash
kubectl delete namespace argocd
```
