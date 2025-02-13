# Linux IaaS Infrastructure Project

## Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud.

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios such as deploying with automation. 

In a later parts of the project, we expand on this for governance and compliance requirements around the workload and also offload the automation to a CI/CD pipeine. 

### Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. Instead of doing the lab using the Azure Portal, this project will focus on automating the build processes.

You are also interested in using SSH to securely connect to the virtual machine, so you can install the latest OS updates and the Nginx web server.

**ADDITIONALLY** 
* 
* 
* 

### Prerequisites

- A Linux environment, WSL2 or VSCode Workspace
- An Azure Subscription
- Git
- Terraform (configured with access to Azure Subscription with Environment Variables)
- Ansible

### Project Objectives
#### **[Part 1](./Instructions/Part1.md)**

In part 1, the infrastructure for the scenario is deployed locally from a workspace or local lab using a few CLI tools and commands.

In this lab we will:

- Create an SSH key pair and set the required permissions
- Create an Ubuntu Linux virtual machine (using Terraform)
- Create an NSG and open up the ports for SSH and web traffic
- Connect to the virtual machine using SSH
- Install the Nginx web service and test to ensure it is working (using Ansible)
- Configure the "datadrive" storage (Azure managed disk) (using Ansible)
- Configure an Azure Monitor Action Group 
- Configure CPU alert notifications to the action group.
- Configure an activity log processing rule for VM changes
- Trigger an alert by resizing the virtual machine using the CLI.


#### **[Part 2](./Instructions/Part2.md)**
#### **[Part 3](./Instructions/Part3.md)**
#### **[Part 4](./Instructions/Part4.md)**
