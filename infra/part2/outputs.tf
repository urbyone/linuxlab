output "vm_ip_address" {
  value = azurerm_public_ip.pip1.ip_address
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
