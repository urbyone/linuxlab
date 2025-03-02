variable "tagName" {
  description = "Tag for the VMs that need backups enabled"
  type        = string
}
variable "tagValue" {
  description = "Tag for the VMs that need backups enabled"
  type        = string
}
variable "rsgname" {
  description = "Resource Group of the RSV Resource"
  type        = string
}
variable "region" {
  description = "Azure Region"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription"
  type        = string
}