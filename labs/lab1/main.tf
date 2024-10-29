provider "azurerm" {
  features {}
}

variable "location" {
  default = "East US"
}

variable "myname" {
  default = "barak"
}

variable "vm_size" {
  default = "Standard_B1ms"
}

variable "admin_username" {
  default = "adminuser-barak"
}

variable "admin_password" {
  default = "Password123!"
}


resource "azurerm_resource_group" "rg-barak" {
  name     = "${var.myname}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-barak" {
  name                = "${var.myname}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-barak.name
}

resource "azurerm_subnet" "subnet-barak" {
  name                 = "${var.myname}-subnet"
  resource_group_name  = azurerm_resource_group.rg-barak.name
  virtual_network_name = azurerm_virtual_network.vnet-barak.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-barak" {
  name                = "${var.myname}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-barak.name
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}

resource "azurerm_network_interface" "nic-barak" {
  name                = "${var.myname}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-barak.name

  ip_configuration {
    name                          = "${var.myname}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-barak.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-barak.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-barak" {
  name                  = "${var.myname}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-barak.name
  network_interface_ids = [azurerm_network_interface.nic-barak.id]
  size                  = var.vm_size

  os_disk {
    name              = "${var.myname}-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "${var.myname}-vm"
}

output "vm_public_ip" {
  value = azurerm_public_ip.pip-barak.ip_address
  description = "Public IP address of the VM"
}
