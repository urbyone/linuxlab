output "vm_ip_address" {
  value = azurerm_public_ip.pip1.ip_address
}

output "storage_account" {
  value = azurerm_storage_account.sto.name
}

output "recovery_vault" {
  value = azurerm_recovery_services_vault.rsv1.name

}

output "backup_policy" {
  value = azurerm_backup_policy_vm.rsvpol-1.name
}