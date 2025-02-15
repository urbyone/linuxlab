locals {
  ssh_key_path = "~/.ssh/${var.vmname}_key.pub"
}

locals {
  ssh_key = file(local.ssh_key_path)
}


resource "azurerm_resource_group" "rsg1" {
  location = var.region
  name     = var.rsgname
}

resource "azurerm_ssh_public_key" "sshkey1" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${azurerm_linux_virtual_machine.azvm1.name}-sshkey"
  public_key          = local.ssh_key
  resource_group_name = var.rsgname

}

resource "azurerm_public_ip" "pip1" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.vmname}-pip"
  resource_group_name = azurerm_resource_group.rsg1.name
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rsg1]
}

resource "azurerm_virtual_network" "vnet1" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.vmname}-vnet"
  resource_group_name = azurerm_resource_group.rsg1.name
  depends_on          = [azurerm_resource_group.rsg1]
}

resource "azurerm_subnet" "snt1" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "${var.vmname}-snet"
  resource_group_name  = azurerm_resource_group.rsg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name

}

resource "azurerm_network_interface" "nic1" {
  accelerated_networking_enabled = true
  location                       = azurerm_resource_group.rsg1.location
  name                           = "${var.vmname}-nic"
  resource_group_name            = azurerm_resource_group.rsg1.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/publicIPAddresses/${azurerm_public_ip.pip1.name}"
    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet1.name}/subnets/${azurerm_subnet.snt1.name}"
  }
  depends_on = [azurerm_subnet.snt1]
}

resource "azurerm_linux_virtual_machine" "azvm1" {
  admin_username        = "adminuser"
  location              = azurerm_resource_group.rsg1.location
  name                  = var.vmname
  network_interface_ids = ["/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkInterfaces/${azurerm_network_interface.nic1.name}"]
  resource_group_name   = azurerm_resource_group.rsg1.name
  size                  = var.vmSKU


  additional_capabilities {
  }
  admin_ssh_key {
    public_key = local.ssh_key
    username   = "adminuser"
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "${var.vmname}-osd"
  }

  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }

}

resource "azurerm_network_interface_security_group_association" "nsgadd1" {
  network_interface_id      = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkInterfaces/${azurerm_network_interface.nic1.name}"
  network_security_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkSecurityGroups/${azurerm_network_security_group.nsg1.name}"
  depends_on                = [azurerm_network_interface.nic1, azurerm_network_security_group.nsg1]

}
resource "azurerm_network_security_group" "nsg1" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${azurerm_linux_virtual_machine.azvm1.name}-nsg"
  resource_group_name = azurerm_resource_group.rsg1.name

}
resource "azurerm_network_security_rule" "nsgrule1" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  name                        = "AllowAnyHTTPInbound"
  network_security_group_name = azurerm_network_security_group.nsg1.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rsg1.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on                  = [azurerm_network_security_group.nsg1]

}
resource "azurerm_network_security_rule" "nsgrule2" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  direction                   = "Inbound"
  name                        = "AllowAnyHTTPSInbound"
  network_security_group_name = azurerm_network_security_group.nsg1.name
  priority                    = 120
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rsg1.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on                  = [azurerm_network_security_group.nsg1]
}

resource "azurerm_network_security_rule" "nsgrule3" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "AllowAnySSHInbound"
  network_security_group_name = azurerm_network_security_group.nsg1.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rsg1.name
  source_address_prefix       = var.my_ip_cidr
  source_port_range           = "*"
  depends_on                  = [azurerm_network_security_group.nsg1]

}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "${var.vmname}-datadisk"
  location             = azurerm_resource_group.rsg1.location
  resource_group_name  = azurerm_resource_group.rsg1.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4


  depends_on = [
    azurerm_resource_group.rsg1
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.azvm1.id
  lun                = "1"
  caching            = "ReadWrite"

  depends_on = [
    azurerm_managed_disk.data_disk,
    azurerm_linux_virtual_machine.azvm1
  ]
}

resource "azurerm_log_analytics_workspace" "log" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.rsgname}-log"
  resource_group_name = var.rsgname
  depends_on = [
    azurerm_resource_group.rsg1
  ]
}

resource "azurerm_monitor_action_group" "amag" {
  name                = "Cloud Operations"
  resource_group_name = var.rsgname
  short_name          = "CloudOps"
  email_receiver {
    email_address = var.email
    name          = "Email1"
  }
  depends_on = [
    azurerm_resource_group.rsg1
  ]
}
resource "azurerm_monitor_activity_log_alert" "log_activity" {
  description         = "Virtual machine was updated or deleted."
  name                = "VM-Changes-Alert"
  resource_group_name = var.rsgname
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}"]
  action {
    action_group_id = "/subscriptions/${var.subscription_id}/resourcegroups/${var.rsgname}/providers/microsoft.insights/actiongroups/${azurerm_monitor_action_group.amag.name}"
  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/write"
  }

}
resource "azurerm_monitor_metric_alert" "alert" {
  frequency                = "PT1H"
  name                     = "CPUAlerts"
  resource_group_name      = var.rsgname
  scopes                   = ["/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}"]
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = azurerm_resource_group.rsg1.location
  severity                 = 2
  window_size              = "PT1H"
  action {
    action_group_id = "/subscriptions/${var.subscription_id}/resourcegroups/${var.rsgname}/providers/microsoft.insights/actiongroups/${azurerm_monitor_action_group.amag.name}"
  }
  criteria {
    aggregation      = "Average"
    metric_name      = "Percentage CPU"
    metric_namespace = "Microsoft.Compute/virtualMachines"
    operator         = "GreaterThan"
    threshold        = 90
  }
  depends_on = [
    azurerm_linux_virtual_machine.azvm1
  ]
}

resource "azurerm_recovery_services_vault" "rsv1" {
  name                = "${var.rsgname}-rsv"
  location            = azurerm_resource_group.rsg1.location
  resource_group_name = azurerm_resource_group.rsg1.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
  soft_delete_enabled = false
}


resource "azurerm_backup_policy_vm" "rsvpol-1" {
  name                = "${var.rsgname}-bak"
  policy_type         = "V2"
  recovery_vault_name = azurerm_recovery_services_vault.rsv1.name
  resource_group_name = azurerm_resource_group.rsg1.name
  backup {
    frequency = "Daily"
    time      = "00:00"
  }
  retention_daily {
    count = 7
  }
  depends_on = [
    azurerm_recovery_services_vault.rsv1,
  ]
}

resource "azurerm_virtual_machine_extension" "ama" {
  auto_upgrade_minor_version = true
  name                       = "AzureMonitorLinuxAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}/providers/Microsoft.Compute/virtualMachines/${var.vmname}"
  depends_on = [
    azurerm_linux_virtual_machine.azvm1
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "azvm-dcr" {
  name                    = "${var.vmname}-vmdc"
  target_resource_id      = azurerm_linux_virtual_machine.azvm1.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.res-5.id
  description             = "MonitorVM"
}

resource "azurerm_monitor_data_collection_rule" "res-5" {
  description         = "Data collection rule for VM Insights."
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.rsgname}-dcr"
  resource_group_name = var.rsgname
  data_flow {
    destinations = ["VMInsightsPerf-Logs-Dest"]
    streams      = ["Microsoft-InsightsMetrics"]
  }
  data_flow {
    destinations = ["VMInsightsPerf-Logs-Dest"]
    streams      = ["Microsoft-ServiceMap"]
  }
  data_sources {
    extension {
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
      streams        = ["Microsoft-ServiceMap"]
    }
    performance_counter {
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "VMInsightsPerfCounters"
      sampling_frequency_in_seconds = 60
      streams                       = ["Microsoft-InsightsMetrics"]
    }
  }
  destinations {
    log_analytics {
      name                  = "VMInsightsPerf-Logs-Dest"
      workspace_resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rsgname}/providers/Microsoft.OperationalInsights/workspaces/${var.rsgname}-log"
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.log
  ]
}


resource "random_string" "random_sto" {
  length  = 12
  special = false
  upper   = false



}

resource "azurerm_storage_account" "sto" {
  name                            = "${random_string.random_sto.result}sto"
  resource_group_name             = azurerm_resource_group.rsg1.name
  location                        = azurerm_resource_group.rsg1.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  default_to_oauth_authentication = true
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true
}

resource "azurerm_storage_share" "share1" {
  name                 = "share1"
  storage_account_name = azurerm_storage_account.sto.name
  quota                = 5
}

resource "azurerm_storage_container" "container1" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.sto.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "rbac-user-blob" {
  principal_id         = var.userid
  scope                = azurerm_resource_group.rsg1.id
  role_definition_name = "Storage Blob Data Contributor"

}
resource "azurerm_role_assignment" "rbac-user-smb" {
  principal_id         = var.userid
  scope                = azurerm_resource_group.rsg1.id
  role_definition_name = "Storage File Data SMB Share Contributor"

}

resource "azurerm_role_assignment" "rbac-vm-blob" {
  principal_id         = azurerm_linux_virtual_machine.azvm1.identity[0].principal_id
  scope                = azurerm_resource_group.rsg1.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "rbac-vm-smb" {
  principal_id         = azurerm_linux_virtual_machine.azvm1.identity[0].principal_id
  scope                = azurerm_resource_group.rsg1.id
  role_definition_name = "Storage File Data SMB Share Contributor"
}