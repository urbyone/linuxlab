# variables.tf
variable "ssh_key" {
  description = "Public Key"
  type        = string
}

variable "my_ip_cidr" {
  description = "client IP(s) for SSH on Security Group Rule in CIDR notation"
  type        = string
  default     = "*"

}
variable "rsgname" {
  description = "the name of the azure resource group"
  type        = string
  default     = "myGitHubActions-rg"
}

variable "region" {
  description = "Resource location"
  type        = string
  default     = "uksouth"
}

variable "vmname" {
  description = "the name of the virtual machine"
  type        = string
  default     = "MyLinuxVM"
}

variable "vmSKU" {
  description = "the SKU of the virtul machine size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "email" {
  description = "emal address for action group"
  type        = string
  default     = "yourmail@domain.com"
}