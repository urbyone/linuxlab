resource "azurerm_recovery_services_vault" "rsv" {
  name                = "${var.rsgname}-rsv"
  location            = var.region
  resource_group_name = var.rsgname
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
  soft_delete_enabled = false
}


resource "azurerm_backup_policy_vm" "rsvpol" {
  name                = "LinuxLabDemo7DBackups"
  policy_type         = "V2"
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  resource_group_name = var.rsgname
  backup {
    frequency = "Daily"
    time      = "22:00"
  }
  retention_daily {
    count = 7
  }
  depends_on = [
    azurerm_recovery_services_vault.rsv,
  ]
}

resource "azurerm_resource_group_policy_assignment" "pol-backups1" {
  name                 = "Configure Backups for PROD VMs"
  location             = var.region
  resource_group_id    = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/345fa903-145c-4fe1-8bcd-93ec2adccde8"
  display_name         = "Configure backup on virtual machines with a given tag to an existing recovery services vault in the same location"
  description          = "Deploy Azure Backups to Prod VMs"
  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode(
    {
      "vaultLocation" : {
        "value" : "${var.region}"
      },
      "backupPolicyId" : {
        "value" : "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}/providers/Microsoft.RecoveryServices/vaults/${azurerm_recovery_services_vault.rsv.name}/backupPolicies/${azurerm_backup_policy_vm.rsvpol.name}"
      },
      "inclusionTagName" : {
        "value" : "${var.tagName}"
      },
      "inclusionTagValue" : {
        "value" : [
          "${var.tagValue}"
        ]
      },
      "effect" : {
        "value" : "deployIfNotExists"
      }
    }
  )
  depends_on = [azurerm_backup_policy_vm.rsvpol]
}

resource "azurerm_role_assignment" "pol-rbac-1" {
  principal_id = azurerm_resource_group_policy_assignment.pol-backups1.identity[0].principal_id
  scope = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}"
  role_definition_name = "Backup Contributor"
}
resource "azurerm_role_assignment" "pol-rbac-2" {
  principal_id = azurerm_resource_group_policy_assignment.pol-backups1.identity[0].principal_id
  scope = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}"
  role_definition_name = "Virtual Machine Contributor"
}
