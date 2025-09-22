
# Architecture Diagram

```mermaid
graph TD
    A[Developer] --> B(Git Repository)
    B --> C{CI Pipeline}
    C --> D[Docker Image]
    D --> E(Azure Container Registry)
    B --> F(ArgoCD)
    F --> G(Kubernetes Manifests)
    H(Application Gateway) --> I{AKS Cluster}
    I --> N(Azure Monitor)
    I --> O(Prometheus & Grafana)
    I --> P(ELK Stack)
    E --> I
```

## Diagram Legend

- **Developer Workflow**: Represents the developer's interaction with the source code repository.
- **CI/CD Pipeline**: Automated process for building, testing, and packaging the application.
- **GitOps**: Continuous deployment mechanism using ArgoCD.
- **Azure Cloud Environment**: The cloud infrastructure hosting the application.
- **Azure VNet**: Isolated network for the application.
- **AKS Cluster**: The Kubernetes cluster where the microservices are deployed.
- **Monitoring & Logging**: Tools for observing the application's health and performance.
