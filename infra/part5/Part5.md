# Part 5 - Terraform, Ansible, GitHub CI/CD

Part 5 of this project is to put all the previous parts together into a **CI/CD pipeline.**

The aim here is to make changes to the infrastructure code, push to your repository and have a simple **GitHub Actions** workflow implement the changes automatically.

The previous parts were all based on the administration of Linux virtual machines following the scenario based guidance from the Microsoft Learn **[Linux VM Guided Project](https://learn.microsoft.com/en-gb/training/modules/guided-project-deploy-administer-linux-virtual-machines-azure/)** 

In this part we automate the deployment using a pipeline using [GitHub Actions](https://docs.github.com/en/actions/about-github-actions/understanding-github-actions)

**Terraform will deploy the infrastructure to Azure**

**Ansible will SSH to the VM(s) and configure the deployed infrastructure as per the specifications in the previous labs**

# Pipeline Diagram
![diagram](../../images/diagram.png)


## Components

For this you will need the following if not already available:

- A GitHub account
- Azure CLI Installed and configured
- An Azure Subscription with Owner RBAC activated
- Service Principal for GitHub access
- An Azure Storage Account and Container (This is to store the Terraform state file)
- VSCode with Dev Containers extension
- Docker Destkop (Alternatively you can open the Repo in Code Workspaces)

# Prerequisites
**NOTE:** YGithib needs some setup before deployment. You can skip the below steps if you already have them configured.

## Fork or clone this GitHub Repo as a Quick Start
If you are not opening in GitHub Codespaces:
```sh
git clone https://github.com/urbyone/linuxlab
cd linuxlab
```
If you do not create a forked repo, create a new private repository and change your remote.

```sh
git remote set-url origin https://github.com/YOUR_USERNAME/NEW_PRIVATE_REPOSITORY
git remote -v
```

## Open your repo in the DevContainers extension
If you have docker installed, open the project in the container. The container will take a minute or 2 to build.
Alternatively login to Codespaces which should build automatically.

## Login to **Azure CLI**
Once you are in the contsiner, ensure you have selected a valid **subscription** for this exercise and have **Owner** permissions active to assign RBAC roles. Login to your Azure Subscripton.

```sh
az login --use-device-code
```

## Check Az Environment variables
```sh
env | grep "ARM_SUBSCRIPTION_ID"
```
If this is not listed, create a **subscriptionId** variable from your az context. Alternatively you can set your Terraform values as environment vars.

```sh
ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
```
## Configure Azure Storage for the Terraform remote state
If you would like to create a new container for a Terraform State:

Create a resource group for the storage account if not already configured.
```sh
region="uksouth"
mytfRSG="MyTerraformState"
az group create -n $mytfRSG -l $region --tags Description="Terraform State File" Service="GitHub Actions Linux Labs" URL="https://github.com/urbyone/linuxlab"
```

### Create an Azure Blob Container for state files
### Generate a random azure storage account name (change if needed as accounts need to be unique)

```sh
accountName=$(head /dev/urandom | tr -dc a-z0-9 | head -c 24)
echo $accountName
```

```sh
az storage account create --resource-group $mytfRSG --name $accountName --sku Standard_LRS --encryption-services blob
az storage container create --name "tfstate" --account-name $accountName
```

## Create an Azure Service Principal
This SP will be used for **Github CI/CD Deployments via Actions**
```sh
appName="LinuxLabGitHubActions$(date +%Y%m%d)"
SP_OUTPUT=$(az ad sp create-for-rbac --name $appName --role Owner --scopes /subscriptions/${ARM_SUBSCRIPTION_ID} --json-auth)
echo "$SP_OUTPUT"
```

**Copy the output from the above step this will be for the GitHub Azure Credentials.**
```
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Grant the Service Principal access to your Subscription
Use the **ClientId** of the principal created above to create the role assignment for the blob container.

```sh
az role assignment create --assignee <clientId> --role "Storage Blob Data Contributor" --scope /subscriptions/${ARM_SUBSCRIPTION_ID}
```

## Create GitHub Secrets and Variables
From your Github repo, create the following secrets and environment variables

Secrets will be used for:
* Azure Credentials (AZURE_CREDENTIALS)
* Generate SSH Private Key (SSH_PRIVATE_KEY)

Environment Variables will be created for:
* Generated SSH Public Key on for the VM (SSH_PUBLC_KEY)
* Terraform State file location (TF_BACKEND_CONFIG)
* An email addres for Azure Monitor alerts (EMAIL_ADDRESS)

![gh-settings](../../images/settings.png)

### Create Secret: Azure Credentials
Take the service principal details you created above and paste the json into a secret called **"AZURE_CREDENTIALS"** in GitHub Actions. This will be the service principal to run the deployment.

https://github.com/yourusername/yourreponame/settings/secrets/actions

![GH-SPN](../../images/gh-creds.png)


### Create Environment Variable: SSH Public Key
Generate an SSH key pair on your host. # Note this will be lost and will need to be updated if you recycle your container / local dev environment. 

Store the public key as a variable for you to use in Terraform to assign to the VM(s) adminuser as part of the Terraform process. Keep the private key private.

```sh
ssh-keygen -t rsa -b 2048 -f ~/.ssh/mysshkey -C "githubactions"
ssh_public_key=$(cat ~/.ssh/mysshkey.pub)
echo $ssh_public_key
```
Create an environment variable called **"SSH_PUBLIC_KEY"** in Github Settings with the **public key** contents

![GH-pub](../../images/gh-ssh-pub.png)

### Create Secret: SSH Private Key
Create a secret called **"SSH_PRIVATE_KEY"** in Github Actions with the **private key** contents. 
This will be for the **Ansible** SSH connection after the deployment.

Always **protect** your private keys.

```sh
cat ~/.ssh/mysshkey
```
![GH-prv](../../images/gh-ssh-prv.png)

### Create Environment Variable: Terraform backend details
Create a variable called **"TF_BACKEND_CONFIG"** to contain your backend settings for the Terraform remote state file.

You will need to replace the details with your resource group, storage account, tenant and subscription information. 

Save this as json format like below and the backend configuration will be pulled by the pipeline.

```
{
  "resource_group_name": "your-resource-group",
  "storage_account_name": "your-storage-account-name",
  "container_name": "your-container-name",
  "key": "your-blob-name.tfstate",
  "subscription_id": "your-subscription-id",
  "tenant_id": "your-tenant-id"
}
```

![GH-be](../../images/gh-backend.png)

### Create Environment Variable: Email Address
Enter the value of the email address you want Azure notification to be sent to.

## Environment Checks
You should now have **two** secrets and **three** variables stored to use in future deployments.

- **Secret: AZURE_CREDENTIALS**
- **Secret: SSH_PRIVATE_KEY**
- **Env Var: SSH_PRIVATE_KEY**
- **Env Var: TF_BACKEND_CONFIG**
- **Env Var: EMAIL_ADDRESS**

![GH](../../images/gh-secret.png)

# Deployment
**Update and save your [variables.auto.tf](./variables.auto.tfvars)** in order to trigger the deployment.

Update the variables.auto.tfvars before commiting to the branch, specifically you can update your VM name, resouce group name and other preferred deployment options.

Once your environment is setup, pushing your code to your Github repo will start the pipeline depending on the branch trigger on the **pipeline.yml.**


```sh
git add .
git commit -m "DeployMyLinuxLab"
git push -u origin main

```
The pipeline will:
- **Checkout your repo**
- **Login to Azure using the Service Principal secret**
- **Install Terraform**
- **Get the SSH key pair for use in the deployments**
- **Create a backend.tf file using the TF_BACKEND_CONFIG secret**
- **Run the Terraform workflows using the backend remote state**
- **Create a bash shell script to configure the data disk and file share**
- **Create an Ansible hosts/inventory file**
- **Deploy the ansible.yml file to configure the deployed servers in the inventory file**

Check your Deployment was successful in Github Actions and you should be able to see your infrastructure configuration in the resource group you specified

![deploy](../../images/job.png)

# Cleanup

**Remember to clean up your resources!**
From the infra/part5 we have been working in, you can initialise Terraform and destroy the project
You might need to create a backend config before you can initialise.


```sh
cp backend.txt backend.tf #Then update your value for the state file
terraform init
terraform destroy -var="ssh_key=${ssh_public_key}" -auto-approve
```