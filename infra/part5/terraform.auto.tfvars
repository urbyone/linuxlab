# terraform.tfvars
# Configuration values for Part 5

# Your IP address in CIDR notation for SSH access (e.g., "1.2.3.4/32")
# Use "*" to allow from anywhere (not recommended for production)
my_ip_cidr = "*"

# Azure resource group name
rsgname = "gr-linuxlabs"

# Azure region
region = "uksouth"

# Virtual machine name
vmname = "MyLinuxVM01"

# Virtual machine size/SKU
vmSKU = "Standard_DS1_v2"
