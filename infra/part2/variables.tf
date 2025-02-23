# variables.tf
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