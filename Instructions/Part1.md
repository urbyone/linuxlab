## Part 1 : Deploying Linux Virtual Machine using Terraform and Ansible

Please see the Prerequisites in the **[README](../README.md)** for this walkthrough beore starting.

**A note on the code snippets used in this walkthrough**

**sh**
```
# This code runs on your local lab machine / client
```

and...
> **adminuser@vmname:~$** # This code runs on the virtual machine 

### 1.1 Create an SSH Key Pair and configure variables

**Set some local variables**
Edit the below variables as required to change your configuration

**sh**

```sh
subscription_id=$ARM_SUBSCRIPTION_ID
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
```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${vmname} -C "thecite-linuxlabs"
chmod 600 ~/.ssh/${vmname}
```
**Create the .tfvars file for terraform workflow**

**sh**
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

### 2.2 Deploy the Azure VM and its dependencies
Deploy the Virtual Machine and setup the SSH connection. A virtual network and NSG will be used to isolate inbound traffic from the internet. 

In real-world scenarios, inbound traffic would not usually be permitted directy to the web server, but more on that in a later exercise.

**It's Terraform Workflow Time!**
**cd** to the  **./infra** directory check your variables look correct once formatted by terraform

**sh**
```sh
cd ./infra
terraform fmt
cat ./terraform.tfvars
```

Then run the following **terraform workflow** to kick off the deployment, providing your email address as a variable

**sh**

```sh
terraform validate
```
```sh
terraform plan
```
```sh
terraform apply -var="email=youremail@domain.com"
```


### 2.3 Connect to the instance to ensure everything is working

**sh**
```sh
vm=$(terraform output -raw vm_ip_address)
ssh -i ~/.ssh/${vmname} adminuser@$vm
```
You will likely receive a **warning** about the host's fingerprint. Continue by typing **_yes_** to add the fingerprint to your known hosts file.


```sh
The authenticity of host '172.166.195.243 (172.166.195.243)' can't be established.
ED25519 key fingerprint is SHA256:+ycbee44QbwBianvFg8zSU9F05xaQ3rqXftqwBUW75o.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```
Confirm you are connected to the vm:

>**_adminuser@vmname:~$_**

To confim the data disk is configured at this point, use **lsblk** in the console to list the block devices to see which device is the data disk attached. It should be somthing like:
>**lsblk -P | grep 'TYPE="disk"'**

NAME="sda" MAJ:MIN="8:0" RM="0" SIZE="30G" RO="0" TYPE="disk" MOUNTPOINTS=""
NAME="sdb" MAJ:MIN="8:16" RM="0" SIZE="7G" RO="0" TYPE="disk" MOUNTPOINTS=""
**_NAME="sdc" MAJ:MIN="8:32" RM="0" SIZE="64G" RO="0" TYPE="disk" MOUNTPOINTS=""_**

Ensure the **NAME** of the device, **sdc** is represented in the **[/ansible/myscript.sh](../ansible/myscript.sh)** file for the next steps. If not alter this file for the name of your data disk and save it.


Then type **_'logout'_** to get back to the local terminal.

>**_adminuser@vmname:~$_ logout**

### 2.4 Navigate to the Ansible directory to deploy the config

**sh**
```sh
cd ../ansible
touch hosts

{
 echo "[web]"
 echo "$vm ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/${vmname}"
} > hosts

```
**Run the Ansible Playbook**
From the ansible directory, run the playbook. This playbook should:
- Install Nginx
- Copy the myscript.sh and run it on the server to configure the **/datadrive** disk.

**sh**
```sh
ansible-playbook -i hosts config.yml
```
Wait for the ansible tasks to complete observing the results of the **PLAY RECAP** for any errors.


### 2.5 Check the web server now has a data drive

**sh**
```sh
ssh -i ~/.ssh/${vmname} adminuser@$vm lsblk -P | grep 'NAME="sdc1"'
```
**_NAME="sdc1" MAJ:MIN="8:33" RM="0" SIZE="64G" RO="0" TYPE="part" MOUNTPOINTS="/datadrive"_**

### 2.6 Check the web server is now up and running

**sh**
```sh
curl $vm # Gets a response from the web server
echo $vm # Show the IP Address to paste into your browser
```
**You should no be able to visit the webpage of the nginx server from a web browser**
![VM](../images/lab01.png)


## Part 1 Cleanup
Once you have configured, **remember to save costs by destroying the infrastruture** from the terraform root

**sh**
```sh
cd ../infra/
terraform destroy -auto-approve
```