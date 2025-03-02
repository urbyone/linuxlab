# variables.tf
variable "vm_tags" {
  description = "Tags to be assigned to the Azure VM"
  type        = map(string)
  default = {
    env     = "Production"
    Project = "The Linux Lab"
  }
}

variable "os" {
  type = map(string)
  default = {
    offer     = "CentOS-LVM"
    publisher = "OpenLogic"
    sku       = "7-lvm-gen2"
    version   = "latest"
  }
}
variable "instances" {
  type        = number
  description = "*** WARNING - DEPLOYING MORE INSTANCES WILL LEAD TO HIGHER COSTS! Ensure you are in control of your subscription costs and know how to destroy resources before proceeding! ***"
}

variable "my_ip_cidr" {
  description = "client IP(s) for SSH on Security Group Rule in CIDR notation"
  type        = string

}
variable "rsgname" {
  description = "the name of the azure resource group"
  type        = string
}

variable "region" {
  description = "Resource location"
  type        = string
}

variable "vmname" {
  description = "the name of the virtual machine"
  type        = string
}

variable "vmSKU" {
  description = "the SKU of the virtul machine size"
  type        = string
}

variable "email" {
  description = "emal address for action group"
  type        = string
}