resource "azurerm_resource_group" "rsg1" {
  location = var.region
  name     = var.rsgname
}

resource "azurerm_ssh_public_key" "sshkey1" {
  location            = azurerm_resource_group.rsg1.location
  name                = "${azurerm_linux_virtual_machine.azvm1.name}-sshkey"
  public_key          = file(var.sshkeypath)
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
    public_key = file(var.sshkeypath)
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

}


resource "azurerm_role_assignment" "rbac" {
  principal_id         = azurerm_linux_virtual_machine.azvm1.identity[0].principal_id
  scope                = azurerm_resource_group.rsg1.id
  role_definition_name = "Contributor"

}