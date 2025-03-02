module "AzPolicy" {
  source          = "./modules/Policy"
  region          = var.region
  rsgname         = azurerm_resource_group.rsg1.name
  tagName         = keys(var.vm_tags)[1]
  tagValue        = values(var.vm_tags)[1]
  subscription_id = data.azurerm_subscription.current.subscription_id
}

locals {
  ssh_key_path = "~/.ssh/${var.rsgname}_key.pub"
}

locals {
  ssh_key = file(local.ssh_key_path)
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rsg1" {
  location = var.region
  name     = "${var.rsgname}"
}

resource "azurerm_ssh_public_key" "sshkey1" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.rsgname}-sshkey"
  public_key          = local.ssh_key
  resource_group_name = azurerm_resource_group.rsg1.name

}

resource "azurerm_public_ip" "pip1" {
  count               = var.instances
  allocation_method   = "Static"
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.vmname}${count.index + 1}-pip"
  resource_group_name = azurerm_resource_group.rsg1.name
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rsg1]
}

resource "azurerm_virtual_network" "vnet1" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.rsgname}-vnet"
  resource_group_name = azurerm_resource_group.rsg1.name
  depends_on          = [azurerm_resource_group.rsg1]
}

resource "azurerm_subnet" "snt1" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "${var.vmname}-snt"
  resource_group_name  = azurerm_resource_group.rsg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name

}

resource "azurerm_network_interface" "nic1" {
  count                          = var.instances
  accelerated_networking_enabled = true
  location                       = azurerm_resource_group.rsg1.location
  name                           = "${var.vmname}${count.index + 1}-nic"
  resource_group_name            = azurerm_resource_group.rsg1.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/publicIPAddresses/${azurerm_public_ip.pip1[count.index].name}"
    subnet_id                     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet1.name}/subnets/${azurerm_subnet.snt1.name}"
  }
  depends_on = [azurerm_subnet.snt1]
}

resource "azurerm_linux_virtual_machine" "azvm1" {
  count                 = var.instances
  admin_username        = "adminuser"
  location              = azurerm_resource_group.rsg1.location
  name                  = "${var.vmname}${count.index + 1}"
  network_interface_ids = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkInterfaces/${azurerm_network_interface.nic1[count.index].name}"]
  resource_group_name   = azurerm_resource_group.rsg1.name
  size                  = var.vmSKU
  tags                  = var.vm_tags

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
    name                 = "${var.vmname}${count.index + 1}-osd"
  }

  source_image_reference {
    offer     = var.os["offer"]
    publisher = var.os["publisher"]
    sku       = var.os["sku"]
    version   = var.os["version"]
  }

  depends_on = [module.AzPolicy]
}

resource "azurerm_network_interface_security_group_association" "nsgadd1" {
  count                     = var.instances
  network_interface_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkInterfaces/${var.vmname}${count.index + 1}-nic"
  network_security_group_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}/providers/Microsoft.Network/networkSecurityGroups/${azurerm_network_security_group.nsg1.name}"
  depends_on                = [azurerm_network_interface.nic1, azurerm_network_security_group.nsg1]

}
resource "azurerm_network_security_group" "nsg1" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${var.rsgname}-nsg"
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
  name                        = "AllowHomeSSHInbound"
  network_security_group_name = azurerm_network_security_group.nsg1.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rsg1.name
  source_address_prefix       = var.my_ip_cidr
  source_port_range           = "*"
  depends_on                  = [azurerm_network_security_group.nsg1]

}


resource "azurerm_monitor_action_group" "amag" {
  name                = "Cloud Operations"
  resource_group_name = azurerm_resource_group.rsg1.name
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
  resource_group_name = azurerm_resource_group.rsg1.name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}"]
  action {
    action_group_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${azurerm_resource_group.rsg1.name}/providers/microsoft.insights/actiongroups/${azurerm_monitor_action_group.amag.name}"
  }
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/write"
  }

}
resource "azurerm_monitor_metric_alert" "alert" {
  frequency                = "PT1H"
  name                     = "CPUAlerts"
  resource_group_name      = azurerm_resource_group.rsg1.name
  scopes                   = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rsg1.name}"]
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = azurerm_resource_group.rsg1.location
  severity                 = 2
  window_size              = "PT1H"
  action {
    action_group_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${azurerm_resource_group.rsg1.name}/providers/microsoft.insights/actiongroups/${azurerm_monitor_action_group.amag.name}"
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

