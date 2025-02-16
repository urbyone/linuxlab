# Linux IaaS Infrastructure Project

## Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud.

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios such as deploying with automation. 

In later parts of the project, we expand on this for governance and compliance requirements around the workload and also offload the automation to a CI/CD pipeline. 

### Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. Instead of doing the lab using the Azure Portal in a _ClickOps_ fashion, this project will focus on automating the build processes to:

- **Increase efficiency**
- **Increase conistency**
- **Reduce errors**

You are also interested in using SSH to securely connect to the virtual machine, so you can install the latest OS updates and the Nginx web server.

### Prerequisites

- A Linux environment, [WSL2 on Windows](https://learn.microsoft.com/en-us/windows/wsl/install) or [GitHub Codespace](https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces#:~:text=GitHub%20Codespaces%20provides%20cloud-hosted%20development%20environments%20for%20any,Code%20or%20a%20browser-based%20editor%20that%27s%20accessible%20anywhere.)
- An Azure Subscription with Owner RBAC
- VS Code or Preferred IDE
- Azure CLI
- Git
- Terraform (configured with access to Azure Subscription with Environment Variables)
- Ansible

### Objectives
#### **[Part 1](./infra/part1/Part1.md)**

In part 1, the infrastructure for the scenario is deployed locally from a workspace or local lab using a few CLI tools and commands.

In Part 1 we will implement the guided project in line with the requirements:

- Create an SSH key pair and set the required permissions
- Create an Ubuntu Linux Virtual Machine using Terraform
- Create an NSG and open up the ports for SSH and web traffic*
- Connect to the virtual machine using the SSH key
- Install the Nginx web service using a simple Ansible playbook

***Note that in production scenarios this will often never be the case to expose infrastructure servers directly to the internet since it does not adhere to zero-trust architecture patterns and does not provide defense in depth.**

#### **[Part 2 - Coming Soon]**
#### **[Part 3 - Coming Soon]**
#### **[Part 4 - Coming Soon]**