output "vm_ip_address" {
  value = azurerm_public_ip.pip1.ip_address
}

output "storage_account" {
  value = azurerm_storage_account.sto.name
}