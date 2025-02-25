# Part 1

This part 1 is based on the Microsoft Learn guided project section **[Exercise 01: Configure an Azure Linux virtual machine](https://microsoftlearning.github.io/Deploy-and-administer-Linux-virtual-machines-in-Azure/Instructions/Labs/Lab01-configure-vms.html)**

### Architecture diagram

![VM](../../images/lab01.png)

Please also remember to see the prerequisites in the **[README](../../README.md)** for this walkthrough before starting.

- Skill 1: Use Terraform to create the virtual machine instead of the Azure Portal.
- Skill 2: Connect to the virtual machine using your SSH key.
- Skill 3: Install the Nginx web service using Ansible instead of doing it manually in the console.

**_A note on the code snippets used in this walkthrough_**


```
# This code in a code block runs on your local to copy and paste.
```

> **adminuser@VM1:~$** These commands run on the Azure Virtual Machine in the SSH session

### 1.0 Set working folder
Step into your working folder and clone the repo is you do not have it locally. Ensure you are in the Part 1 working folder for this part.

```sh
git clone https://github.com/urbyone/linuxlab
cd ./infra/part1
```

### 1.1 Set local variables
These local variables will be passed to the terraform configuration. 

```sh
region="eastus"
rsgname="RG1"
vmname="VM1"
vmSKU="Standard_DS1_v2"
client_ip=$(curl -s http://api.ipify.org)
my_ip_cidr="${client_ip}/32"
subscription_id=$ARM_SUBSCRIPTION_ID
tfvarsFilePath=./terraform.tfvars
```

**Create a .tfvars file for the terraform workflow**


```sh
{
  echo "region = \"$region\""
  echo "rsgname = \"$rsgname\""
  echo "vmname = \"$vmname\""
  echo "vmSKU = \"$vmSKU\""
  echo "subscription_id = \"$subscription_id\""
  echo "my_ip_cidr = \"$my_ip_cidr\""
} > $tfvarsFilePath

```
### 1.2 Create an SSH Key Pair 

**Create the SSH Key Pair and set file permissions**


```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${vmname}_key -C ${rsgname}
chmod 600 ~/.ssh/${vmname}_key
```

### 1.3 Deploy the Azure VM and its dependencies
Deploy the Virtual Machine and setup the SSH connection. A virtual network and NSG will be used to isolate inbound traffic from the internet, allowing your client's IP address for **port 22**. 

**In real-world scenarios, inbound traffic would not usually be permitted directy to the web server, but more on that in later parts**

**It's Terraform Workflow Time!**

Check the **./terraform.tfvars** variables look correct once formatted by terraform


```sh
terraform fmt
cat ./terraform.tfvars
```

Now run the following **terraform workflow** to kick off the deployment.

```sh
terraform init
```

```sh
terraform validate
```
```sh
terraform plan
```
 Now run the apply, remembering to type **yes** if you do not use the **-auto-approve** flag
```sh
terraform apply
```
Wait for the deployment to complete successfully.
Then get some values from the **terrform outputs:**

```sh
vm=$(terraform output -raw vm_ip_address)
```

### 1.4 Verify a connection to the instance

```sh
ssh -i ~/.ssh/${vmname}_key adminuser@$vm
```
You will likely receive a **warning** about the host's fingerprint. Continue by typing **_yes_** to add the fingerprint to your known hosts file.

```sh
The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.
ED25519 key fingerprint is SHA256:+xxxxxxxxyyyyyyyzzzzzzzzz.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```
Confirm you are connected to the vm, then logout:

>**_adminuser@VM1:~$_ logout**

### 1.5 Configure the Nginx server using Ansible

```sh
touch hosts
{
 echo "[web]"
 echo "$vm ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/${vmname}_key"
} > hosts

```
**Run the Ansible Playbook**
This playbook should:
- Install Nginx

```sh
ansible-playbook -i hosts ansible.yml
```
Wait for the ansible tasks to complete observing the results of the **PLAY RECAP** for any errors.

### 1.6 Check the web server is now up and running


```sh
curl $vm # Gets a response from the web server
echo $vm # Show the IP Address to paste into your browser
```
**You should now be able to visit the webpage of the nginx server from a web browser**


## Part 1 Cleanup
Once you have configured, **remember to save costs by destroying the infrastruture**


```sh
rm hosts
terraform destroy -auto-approve
```