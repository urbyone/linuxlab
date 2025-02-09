# Linux IaaS Infrastructure Project

## 1. Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud.

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios such as deploying with Terraform and applying any governance requirements.

### 1.1 Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. Instead of doing the lab using the Azure Portal, this lab will focus on automating the build process.

You are also interested in using SSH to securely connect to the virtual machine so you can install the latest OS updates and the Nginx web server.

**ADDITIONALLY** 
* 
* 
* 

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

Sh

```

subscription_id="e7ff6a6d-ec02-4fcc-b579-16ba0251b540"
region="uksouth"
rsgname="thecite-linuxlab"
vmname="ecom-nginx-web01"
vmSKU="Standard_DS1_v2"
client_ip=$(curl -s http://api.ipify.org)
my_ip_cidr="${client_ip}/32"
tfvarsFilePath=./infra/terraform.tfvars

ssh-keygen -t rsa -b 4096 -f ~/.ssh/${vmname} -C "thecite-linuxlabs"
chmod 600 ~/.ssh/${vmname}
sshkeypath=

{
  echo "region = \"$region\""
  echo "rsgname = \"$rsgname\""
  echo "vmname = \"$vmname\""
  echo "vmSKU = \"$vmSKU\""
  echo "subscription_id = \"$subscription_id\""
  echo "my_ip_cidr = \"$my_ip_cidr\""
} > $tfvarsFilePath

```

### 2.2 Deploy the Azure VM and its depandancies
Deploy the Virtual Machine and setup the SSH connection. A virtual network and NSG will be used to isolate inbund traffic from the internet. In real-world scenarios, inbound traffic would not usually be permitted directy to the web server, but more on that in a later lab exercise.

**Terraform Workflow Time**

```
terraform plan
```

```
terraform apply
```

**connect to the instance to ensure everything is working**
```
vm=(terraform output -raw vm_ip_address)
ssh -i ~/.ssh/${vmname} adminuser@$vm
```

**Use Ansible to deploy the nginx web server**

```

{
 echo "[Web]"
 echo 
}
$hosts = New-Item .\ansible\hosts -Force
"[web]" | Out-File -FilePath $Hosts.FullName -Encoding UTF8
"$vm ansible_user=adminuser ansible_ssh_private_key_file=/mnt/c"+($localKey.Split(':')[1]).replace('\','/') | Out-File -FilePath $Hosts.FullName -Append -Encoding UTF8
```

![VM](./images/lab01.png)