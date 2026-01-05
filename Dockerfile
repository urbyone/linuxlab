FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION=1.14.3
ENV PACKER_VERSION=1.14.3

# Update and install prerequisites
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform and Packer
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform packer

# Install Ansible
RUN apt-get update \
    && apt-get install -y ansible \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install sudo
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Create admin user with sudo privileges
RUN useradd -m -s /bin/bash admin && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy Azure credentials directory structure for admin user
RUN mkdir -p /home/admin/.azure

# Set working directory
WORKDIR /workspace

# Verify installations
RUN pwsh --version && \
    terraform version && \
    packer version && \
    ansible --version && \
    az version


# Switch to the non-root user
USER admin

# Set the default command to bash
CMD ["/bin/bash"]