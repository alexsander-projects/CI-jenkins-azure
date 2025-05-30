terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0" # Updated to a newer version range
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6" # Updated to a newer version range
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "<YOUR_SUBSCRIPTION_ID>" # Replace with your Azure subscription ID
}

provider "random" {
}

#Resource Group
resource "azurerm_resource_group" "jenkins-rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
}

#Virtual network
resource "azurerm_virtual_network" "jenkins-vnet" {
  name                = var.virtual_network.name
  address_space       = var.virtual_network.address_space
  location            = azurerm_resource_group.jenkins-rg.location
  resource_group_name = azurerm_resource_group.jenkins-rg.name
  depends_on          = [azurerm_resource_group.jenkins-rg]
}

#Subnet
resource "azurerm_subnet" "jenkins-subnet" {
  name                 = var.subnet.name
  resource_group_name  = azurerm_resource_group.jenkins-rg.name
  virtual_network_name = azurerm_virtual_network.jenkins-vnet.name
  address_prefixes     = var.subnet.address_prefixes
  depends_on           = [azurerm_virtual_network.jenkins-vnet]
}

#Network Security Group
resource "azurerm_network_security_group" "jenkins-nsg" {
  name                = var.network_security_group.network_security_group_name
  location            = azurerm_resource_group.jenkins-rg.location
  resource_group_name = azurerm_resource_group.jenkins-rg.name
  security_rule {
    name                       = var.security_rule.name
    priority                   = var.security_rule.priority
    direction                  = var.security_rule.direction
    access                     = var.security_rule.access
    protocol                   = var.security_rule.protocol
    source_port_range          = var.security_rule.source_port_range
    destination_port_range     = var.security_rule.destination_port_range
    source_address_prefix      = var.security_rule.source_address_prefix
    destination_address_prefix = var.security_rule.destination_address_prefix
  }
}

#Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "jenkins-nsg-asc" {
  subnet_id                 = azurerm_subnet.jenkins-subnet.id
  network_security_group_id = azurerm_network_security_group.jenkins-nsg.id
  depends_on                = [azurerm_network_security_group.jenkins-nsg]
}

#Public Ip Master
resource "azurerm_public_ip" "master-ip" {
  name                = var.public_ip.master_ip_name
  resource_group_name = azurerm_resource_group.jenkins-rg.name
  location            = azurerm_resource_group.jenkins-rg.location
  allocation_method   = var.public_ip.allocation_method
  depends_on          = [azurerm_subnet.jenkins-subnet]
}

#Network Interface Master
resource "azurerm_network_interface" "master_nic" {
  name                = var.network_interface.master_nic_name
  location            = azurerm_resource_group.jenkins-rg.location
  resource_group_name = azurerm_resource_group.jenkins-rg.name

  ip_configuration {
    name                          = var.network_interface.ip_configuration_name
    subnet_id                     = azurerm_subnet.jenkins-subnet.id
    private_ip_address_allocation = var.network_interface.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.master-ip.id
  }
  depends_on = [azurerm_public_ip.master-ip]
}

#Linux Virtual Machine Master
resource "azurerm_linux_virtual_machine" "masterVm" {
  name                            = "master${random_string.masterVm.result}"
  resource_group_name             = azurerm_resource_group.jenkins-rg.name
  location                        = azurerm_resource_group.jenkins-rg.location
  size                            = var.virtual_machines.size
  priority                        = var.virtual_machines.priority
  eviction_policy                 = var.virtual_machines.eviction_policy
  max_bid_price                   = var.virtual_machines.max_bid_price
  admin_username                  = var.vm_secrets.admin_username
  admin_password                  = random_password.password.result // Use random password
  disable_password_authentication = var.virtual_machines.disable_password_authentication
  network_interface_ids           = [
    azurerm_network_interface.master_nic.id
  ]
  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }
  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
  computer_name = var.virtual_machines.master_name
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.jenkins-storage.primary_blob_endpoint
  }
  depends_on = [azurerm_network_interface.master_nic]
}

#Virtual Machine Extension
resource "azurerm_virtual_machine_extension" "vmextension" {
  name                 = var.vm_extension.name
  virtual_machine_id   = azurerm_linux_virtual_machine.masterVm.id
  publisher            = var.vm_extension.publisher
  type                 = var.vm_extension.type
  type_handler_version = var.vm_extension.type_handler_version
  protected_settings   = jsonencode({
    script           = base64encode(file("../script.sh")) // Assumes script.sh is in the parent directory
  })
  depends_on           = [azurerm_linux_virtual_machine.masterVm]
}

#Storage Account
resource "azurerm_storage_account" "jenkins-storage" {
  name                     = "jenkinsstorage${random_string.masterVm.result}"
  resource_group_name      = azurerm_resource_group.jenkins-rg.name
  location                 = azurerm_resource_group.jenkins-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2" // Added: Enforce minimum TLS 1.2
  depends_on               = [azurerm_resource_group.jenkins-rg]
}

#Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = var.appservice.appservice_name
  resource_group_name = azurerm_resource_group.jenkins-rg.name
  location            = azurerm_resource_group.jenkins-rg.location
  os_type             = "Linux" // Changed to Linux for Python
  sku_name            = var.appservice.sku_name
}

#Linux Web App
resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp.webapp_name
  resource_group_name = azurerm_resource_group.jenkins-rg.name
  location            = azurerm_resource_group.jenkins-rg.location
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  https_only          = true // Added: Enforce HTTPS

  site_config {
    application_stack {
      python_version = var.webapp.python_version
    }

  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1" // Recommended for deployment
  }

  depends_on = [azurerm_service_plan.appserviceplan]
}

#Random string
resource "random_string" "masterVm" {
  length  = 4
  special = false
  upper   = false
}

#Random password
resource "random_password" "password" {
  length           = 16
  special          = false
}
