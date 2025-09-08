# Azure Microservices Platform

A complete multi-environment microservices platform built on Azure with automated deployment pipelines.

## 🏗️ Architecture Overview

- **Infrastructure**: Azure Kubernetes Service (AKS) clusters for dev, staging, and production
- **GitOps**: ArgoCD for continuous deployment
- **Configuration Management**: Ansible for VM configuration
- **Container Registry**: Azure Container Registry (ACR)
- **Networking**: Segmented VNets with NSGs
- **Ingress**: Azure Application Gateway with WAF

## 📋 Prerequisites

- Azure CLI (>= 2.50.0)
- Terraform (>= 1.5.0)
- Ansible (>= 2.15)
- kubectl (>= 1.28)
- ArgoCD CLI (>= 2.8)
- GitHub CLI (optional)

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd azure-microservices-platform
   ```

2. **Set up Azure credentials**
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

3. **Setup the Backend**
    ```bash
    ./scripts/setup-terraform-backend.sh
    ```
    
4. **Initialize Terraform**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

5. **Configure Ansible**
   ```bash
   cd ansible
   ansible-playbook -i inventory/dev playbooks/site.yml
   ```

6. **Deploy ArgoCD**
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl apply -f argocd/applications/
   ```

## 📁 Project Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── environments/       # Environment-specific configurations
│   └── modules/           # Reusable Terraform modules
├── ansible/               # Configuration management
│   ├── playbooks/         # Ansible playbooks
│   └── roles/            # Ansible roles
├── argocd/               # GitOps configurations
│   ├── applications/      # ArgoCD application definitions
│   └── overlays/         # Environment-specific overlays
├── kubernetes/           # Kubernetes manifests
│   ├── base/            # Base configurations
│   └── overlays/        # Environment-specific configurations
├── scripts/             # Utility scripts
├── .github/workflows/   # CI/CD pipelines
└── docs/               # Documentation
```

## 🌍 Environments

- **Development**: For development and testing
- **Staging**: Pre-production environment
- **Production**: Live production environment

## 🔐 Security

- Network segmentation with Azure VNets and NSGs
- WAF protection via Application Gateway
- Pod Security Policies enabled
- Azure Key Vault for secrets management
- RBAC configured for AKS

## 📊 Monitoring

- Azure Monitor for infrastructure monitoring
- Prometheus & Grafana for application metrics
- ELK stack for centralized logging
- Application Insights for APM

## 🤝 Contributing

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
