terraform {
  backend "s3" {
    bucket  = "terraform-state-store-ves"
    key     = "foobar/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}

variable "client_id" {
}

variable "client_secret" {
}

variable "subscription_id" {
}

variable "tenant_id" {
}

variable "location" {
  default = "eastus"
}

variable "machine_type_jumphost" {
  default = "Standard_B2ms"
}

variable "machine_type" {
  default = "Standard_D3_v2"
}

variable "machine_disk_size" {
  default = "40"
}

variable "machine_admin" {
  default = "centos"
}

# var.user_name ssh pub key
variable "machine_public_key" {
  default = ""
}

variable "iam_owner" {
  default = "default"
}

variable "environment" {
  default = "production"
}

variable "name" {
}

provider "azurerm" {
  version         = "=1.34.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "main" {
  name     = "${var.name}-resources"
  location = var.location
}

resource "azurerm_public_ip" "compute_public_ip" {
  name                = "machine-${var.name}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.name}-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "balancer"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.compute_public_ip.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = var.name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.machine_type

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name          = "${var.name}-system"
    create_option = "FromImage"
    os_type       = "Linux"
    disk_size_gb  = var.machine_disk_size
  }

  os_profile {
    computer_name  = var.name
    admin_username = var.machine_admin
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.machine_admin}/.ssh/authorized_keys"
      key_data = var.machine_public_key
    }
  }
  tags = {
    environment = var.environment
    iam_owner   = var.iam_owner
  }
}

output "public_addresses" {
  value = azurerm_public_ip.compute_public_ip.ip_address
}