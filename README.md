# Linux IaaS Infrastructure Project

## 1. Project Overview
The goal of this project is to improve on the basics of deploying and administering linux virtual machines in the Azure Cloud.

The lab scenario is based on the **[Guided Project from Microsoft Learn](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/),** but expands on these concepts for real world scenarios such as deploying with automation. In a later project we expand on this for governance and compliance requirements around the workload and offload the automation to a devops pipeine. In this scenario, the infrastructure is deployed locally from a workspace or local lab.

### 1.1 Project Scenario
As in the guided project, you have been asked to create a web server for a new ecommerce website. You want to explore how to create Linux virtual machines using Azure. Instead of doing the lab using the Azure Portal, this lab will focus on automating the build process.

You are also interested in using SSH to securely connect to the virtual machine so you can install the latest OS updates and the Nginx web server.

**ADDITIONALLY** 
* 
* 
* 

### 1.2 Project Objectives
- Create an SSH key pair and set the required permissions
- Create a virtual machine (using Terraform)
- Connect to the virtual machine and install OS updates.
- Install the Nginx web service and test to ensure it is working (using Ansible).
- Configure VM Insights in Azure.
- Configure Azure Monitor Action Groups and alert notifications.
- Trigger an alert by resizing the virtual machine.
- Configure an alert processing rule.

### 1.3 Prerequisites
- A Linux environment, WSL2 or VSCode Workspace to run:     
  - An Azure Subscription
  - Git
  - Terraform (configured with access to Azure Subscription)
  - Ansible

## 2. Project Steps
### 2.1 Create an SSH Key Pair and configure variables



**Set some variables**
Edit the below variables to change your configuration

**sh**

```

subscription_id = env("ARM_SUBSCRIPTION_ID")
region="uksouth"
rsgname="thecite-linuxlab"
vmname="ecom-nginx-web01"
vmSKU="Standard_DS1_v2"
client_ip=$(curl -s http://api.ipify.org)
my_ip_cidr="${client_ip}/32"
tfvarsFilePath=./infra/terraform.tfvars
```
**Create the SSH Key Pair and set file permissions**

**sh**
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${vmname} -C "thecite-linuxlabs"
chmod 600 ~/.ssh/${vmname}

```
**Create the .tfvars file for terraform workflow**

**sh**
```
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
cd to the  ./infra directory check your variables look correct once formatted by terraform

**sh**
```
cd ./infra
terraform fmt
cat ./terraform.tfvars
```

Then run the following **terraform workflow** to kick off the deployment

**sh**

```
terraform validate
```
```
terraform plan
```
```
terraform apply
```


**Connect to the instance to ensure everything is working**

**sh**
```
vm=$(terraform output -raw vm_ip_address)
ssh -i ~/.ssh/${vmname} adminuser@$vm
```
You will likely receive a **warning** about the host's fingerprint. Continue by typing **yes** to add the fingerprint to your known hosts file

Confirm you are connected as **adminuser@vmname** 

**_'adminuser@ecom-nginx-web01:~$'_**

Then type **_'logout'_** to get back to the local terminal.

**Navigate to the Ansible directory to deploy the nginx web server**

**sh**
```
cd ../ansible
touch hosts

{
 echo "[web]"
 echo "$vm ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/${vmname}"
} > hosts

```
**Run the Ansible Playbook to install Nginx**

**sh**
```
ansible-playbook -i hosts nginx.yml

```

**Check the web server is now up and running**

**sh**
```
curl $vm # Gets a response from the web server
echo $vm # Show the IP Address to paste into your browser
```

**You should no be able to visit the webpage of the nginx server from a web browser**
![VM](./images/lab01.png)