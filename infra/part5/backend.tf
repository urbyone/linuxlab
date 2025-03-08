terraform {
  backend "azurerm" {
    resource_group_name  = "MyTerraformState"
    storage_account_name = "your_storage_account_name"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    tenant_id            = "your_tenant_id"
    subscription_id      = "your_subscription_id"
  }
}
