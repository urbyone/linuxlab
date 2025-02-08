# Linux IaaS Infrastructure Project Plan

## 1. Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud. 

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios.

### 1.1 Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. 

You are also interested in using SSH to securely connect to the virtual machine. You will want to install the latest OS updates and the Nginx web server.

**ADDITIONALLY** the service will....
the servier should...

### 1.2 Project Objectives
- Create an SSH key pair and set the required permissions
- Create a virtual machine using Terraform.
- Connect to the virtual machine and install OS updates.
- Install the Nginx web service and test to ensure it is working.
- Configure VM Insights.
- Configure action groups and notifications.
- Create alerts.
- Trigger an alert by resizing the virtual machine.
- Configure an alert processing rule.

### 1.3 Prerequisites

## 2. Project Steps
### 2.1 Create an SSH Key Pair for VM authentication
Create this key in your working directory. Terraform will read the public key content and configure it on the Azure Virtual Machine for SSH.
- Assign the ssh key a name for reference
- Create a key pair using ssh-Keygen
- Get its full path to inject into the terraform.tfvars file for the 'sshkeypath' variable

PS
```
# Create a filename
$sshfile = "lx-vm-ssh"

# Generate an SSH Key Pair (optinoally assign a passphrase)
ssh-keygen -t rsa -b 4096 -C "thecite-linuxlab" -f "$env:USERPROFILE\$sshfile"

# Get the key path
$key = [string](Get-Item "$env:USERPROFILE\$sshfile").FullName.Replace('\','/')

# Append the key path to the .tfvars file
"sshkeypath=`"$key`"" | Out-File .\infra\terraform.tfvars -Append
```



### 2.1 Deploy the Azure VM and its depandancies
Deploy the Virtual Machine and setup the SSH connection. A virtual network and NSG will be used to isolate inbund traffic from the internet. In real-world scenarios, inbound traffic would not usually be permitted directy to the web server, but more on that in a later lab exercise.

![VM](./images/lab01.png)

```
PS
$vm = (terraform output -raw vm_ip_address) ; ssh -i $key adminuser@$vm
```