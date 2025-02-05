# variables.tf
variable "subscription_id" {
  description = "The subscription ID for the Azure account"
  type        = string
  default     = "e7ff6a6d-ec02-4fcc-b579-16ba0251b540"
}

variable "my_ip_cidr" {
  description = "client IP(s) for SSH on Security Group Rule in CIDR notation"
  type        = string
  default     = "81.109.228.215/32"
}
variable "rsgname" {
  description = "the name of the azure resource group"
  default     = "thecite-linuxlabs"
}
variable "region" {
  description = "Resource location"
  type        = string
  default     = "uksouth"
}

variable "sshkeypath" {
  description = "the local path of the public ssh key"
  type        = string
  default     = "C:/LABS/Azure/Deploy-and-administer-Linux-virtual-machines-in-Azure/lx-vm-ssh.pub"
}

variable "vmname" {
  description = "the name of the virtual machine"
  type        = string
  default     = "ecom-nginx-web01"
}

variable "vmSKU" {
  description = "the SKU of the virtul machine size"
  default     = "Standard_DS1_v2"
}