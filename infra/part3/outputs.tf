output "vm_ip_address" {
  value = azurerm_public_ip.pip1.ip_address
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "storageaccount" {
  value = azurerm_storage_account.sto.name
}

output "sharename" {
  value = azurerm_storage_share.share1.name
}

output "containername" {
  value = azurerm_storage_container.container1.name
}