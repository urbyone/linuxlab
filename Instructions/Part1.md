# Part 1

Please remember to see the prerequisites in the **[README](../README.md)** for this walkthrough before starting.

**_A note on the code snippets used in this walkthrough_**


```
# This code in a code block runs on your local lab machine / client to copy
```


> **adminuser@vmname:~$** These commands runs on the Azure virtual machine in the SSH session

### 1.0 Log into Azure CLI and get your objectid from Azure
Ensure you have installed **azcli** and **azcopy** setup in the console  environment variables for this step. Your objectid will be used to set EntraID **RBAC Roles** in your **ResourceGroup**

```sh
azcopy --version
azcli --version
```
Run the below in your local if not currently installed in distro
```sh
sudo apt update && sudo apt upgrade
sudo snap install azcli
```
Login to your **az** account:
```sh
az login --tenant $ARM_TENANT_ID
```

### 1.1 Set local variables
These local variables will be passed to the terraform configuration

```sh
subscription_id=$ARM_SUBSCRIPTION_ID
objectid=$(az ad signed-in-user show --query id --output tsv)
emailaddress="youremail@domain.com"
region="eastus"
rsgname="RG1"
vmname="VM1"
vmSKU="Standard_DS1_v2"
client_ip=$(curl -s http://api.ipify.org)
my_ip_cidr="${client_ip}/32"
tfvarsFilePath=./infra/terraform.tfvars
```

**Create the .tfvars file for the terraform workflow**


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
### 1.1 Create an SSH Key Pair 

**Create the SSH Key Pair and set file permissions**


```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${vmname}_key -C ${rsgname}
chmod 600 ~/.ssh/${vmname}_key
```

### 1.3 Deploy the Azure VM and its dependencies
Deploy the Virtual Machine and setup the SSH connection. A virtual network and NSG will be used to isolate inbound traffic from the internet. 

(In real-world scenarios, inbound traffic would not usually be permitted directy to the web server, but more on that in a later exercise)

**It's Terraform Workflow Time!**
Check the **./infra/terraform.tfvars** variables look correct once formatted by terraform


```sh
terraform -chdir=./infra fmt
cat ./infra/terraform.tfvars
```

Then run the following **terraform workflow** to kick off the deployment, providing your email address as a variable



```sh
terraform -chdir=./infra validate
```
```sh
terraform -chdir=./infra plan -var="email=$emailaddress" -var="userid=$objectid"
```
Replace the youremail@domain.com with the address you would like the Azure Monitor Alerts to go and run the apply stage, remembering to type **yes** if you do not use the **-auto-approve** flag
```sh
terraform -chdir=./infra apply -var="email=$emailaddress" -var="userid=$objectid"
```


### 1.4 Verify a connection to the instance


```sh
vm=$(terraform output -raw vm_ip_address)
storage=$(terraform output -raw storage_account)
ssh -i ~/.ssh/${vmname} adminuser@$vm
```
You will likely receive a **warning** about the host's fingerprint. Continue by typing **_yes_** to add the fingerprint to your known hosts file.


```sh
The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.
ED25519 key fingerprint is SHA256:+xxxxxxxxyyyyyyyzzzzzzzzz.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```
Confirm you are connected to the vm:

>**_adminuser@vmname:~$_**

To confim the data disk is configured at this point, use **lsblk** in the console to list the block devices to see which device is the data disk attached. It should be somthing like:
>**lsblk -P | grep 'TYPE="disk"'**

NAME="sda" MAJ:MIN="8:0" RM="0" SIZE="30G" RO="0" TYPE="disk" MOUNTPOINTS=""

NAME="sdb" MAJ:MIN="8:16" RM="0" SIZE="7G" RO="0" TYPE="disk" MOUNTPOINTS=""

**_NAME="sdc" MAJ:MIN="8:32" RM="0" SIZE="4G" RO="0" TYPE="disk" MOUNTPOINTS=""_**

Ensure the **NAME** of the device, **sdc** is represented in the **[/ansible/setupscript.sh](../ansible/setupscript.sh)** file for the next steps. If not alter this file for the name of your data disk in the above and save it.


Then type **_'logout'_** to get back to the local terminal.

>**_adminuser@vmname:~$_ logout**

### 1.5 Configure the server using Ansible


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
- Copy the setupscript.sh and run it on the server to configure the **/datadrive** disk.


```sh
ansible-playbook -i hosts ansible.yml
```
Wait for the ansible tasks to complete observing the results of the **PLAY RECAP** for any errors.


### 1.6 Check the web server now has a data drive


```sh
ssh -i ~/.ssh/${vmname}_key adminuser@$vm lsblk -P | grep 'NAME="sdc1"'
```
**_NAME="sdc1" MAJ:MIN="8:33" RM="0" SIZE="4G" RO="0" TYPE="part" MOUNTPOINTS="/datadrive"_**

### 1.7 Check the web server is now up and running


```sh
curl $vm # Gets a response from the web server
echo $vm # Show the IP Address to paste into your browser
```
**You should no be able to visit the webpage of the nginx server from a web browser**
![VM](../images/lab01.png)


## Part 1 Cleanup
Once you have configured, **remember to save costs by destroying the infrastruture** from the terraform root


```sh
terraform -chdir=./infra destroy -var="email=$emailaddress" -var="userid=$objectid" -auto-approve
```