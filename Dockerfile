# Dockerfile
FROM fedora:40

RUN dnf update -y && dnf install -y \
    curl wget git vim python3 python3-pip unzip tar\
    && dnf clean all

# Download latest Terraform (1.13.1) for ARM64
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g') && \
    TERRAFORM_VERSION="1.13.1" && \
    wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" && \
    unzip terraform_*.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_*.zip && \
    terraform --version

# Azure CLI 
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm && \
    dnf install -y azure-cli

# Install Ansible
#RUN pip3 install ansible
RUN dnf install -y ansible

# Optional: Install Azure collection for Ansible
RUN ansible-galaxy collection install azure.azcollection || true

# kubectl and Helm for ARM64
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g') && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    curl -LO "https://get.helm.sh/helm-v3.16.1-linux-${ARCH}.tar.gz" && \
    tar -zxf helm-*.tar.gz && \
    mv linux-${ARCH}/helm /usr/local/bin/ && \
    rm -rf linux-${ARCH} helm-*.tar.gz

# Install Flux CLI for ARM64
# Using fluxcd.io install script (auto-detects architecture)
#RUN curl -L --progress-bar -s https://fluxcd.io/install.sh | bash && \
 #   mv $HOME/.flux/bin/flux /usr/local/bin/flux

#RUN curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=2.0.0 bash


WORKDIR /workspace
CMD ["/bin/bash"]
