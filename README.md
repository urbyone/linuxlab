# Linux IaaS Infrastructure Project

## Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud.

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios such as deploying with automation. 

In later parts of the project, we expand on this for governance and compliance requirements around the workload and also offload the automation to a CI/CD pipeine. 

### Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. Instead of doing the lab using the Azure Portal in a ClickOps fashion, this project will focus on automating the build processes to:

- Increase efficiency
- Increase conistency
- Reduce errors

You are also interested in using SSH to securely connect to the virtual machine, so you can install the latest OS updates and the Nginx web server.

**ADDITIONALLY** 
* 
* 
* 

### Prerequisites

- A Linux environment, WSL2 or VSCode Workspace you can use the tools from.
- An Azure Subscription with Owner RBAC
- Azure CLI
- Git
- Terraform (configured with access to Azure Subscription with Environment Variables)
- Ansible

### Project Objectives
#### **[Part 1](./Instructions/Part1.md)**

In part 1, the infrastructure for the scenario is deployed locally from a workspace or local lab using a few CLI tools and commands.

In Part 1 we will implment the guided project in line witht he requirements:

- Create an SSH key pair and set the required permissions
- Create an Ubuntu Linux virtual machine
- Create an NSG and open up the ports for SSH and web traffic*
- Connect to the virtual machine using the SSH key
- Install the Nginx web service
- Configure the "datadrive" storage as an Azure managed disk
- Create an Azure Storage Account with a blob container and file share
- Configure an Azure Monitor Action Group 
- Configure CPU alert notifications to the action group.
- Configure an activity log processing rule for VM changes
- Trigger an alert by resizing the virtual machine using the CLI.
- Copy files from the VM to the File Share

***Note that in production scenarios this will often never be the case to expose infrastructure servers directly to the internet since it does not adhere to zero-trust architecture patterns and does not provide defense in depth.**


#### **[Part 2](./Instructions/Part2.md)**
#### **[Part 3](./Instructions/Part3.md)**
#### **[Part 4](./Instructions/Part4.md)**
