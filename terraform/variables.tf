#Here we define the variable name and type

#resource group
variable "resource_group" {
  type = object({
    name     = string
    location = string
  })

}

#virtual network
variable "virtual_network" {
  type = object({
    name = string
    address_space = list(
      string
    )
  })
}

#subnet
variable "subnet" {
  type = object({
    name             = string
    address_prefixes = list(string)
  })
}

#public ips
variable "public_ip" {
  type = object({
    master_ip_name    = string
    allocation_method = string
  })
}

#network interface
variable "network_interface" {
  type = object({
    master_nic_name               = string
    ip_configuration_name         = string
    private_ip_address_allocation = string
  })

}

#network security group
variable "network_security_group" {
  type = object({
    network_security_group_name = string
  })
}

#security rule
variable "security_rule" {
  type = object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })
}

# Optional: Add variables for other security rules if you uncomment them in tfvars
# variable "security_rule_ssh" {
#   type = object({
#     name                       = string
#     priority                   = string
#     direction                  = string
#     access                     = string
#     protocol                   = string
#     source_port_range          = string
#     destination_port_range     = string
#     source_address_prefix      = string
#     destination_address_prefix = string
#   })
#   default = null # Or provide default values
# }

# variable "security_rule_app_service" {
#   type = object({
#     name                       = string
#     priority                   = string
#     direction                  = string
#     access                     = string
#     protocol                   = string
#     source_port_range          = string
#     destination_port_range     = string
#     source_address_prefix      = string
#     destination_address_prefix = string
#   })
#   default = null # Or provide default values
# }

#virtual machines
variable "virtual_machines" {
  type = object({
    master_name                     = string
    size                            = string
    priority                        = string
    eviction_policy                 = string
    max_bid_price                   = string
    disable_password_authentication = string
  })

}

#vms os disks
variable "os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
  })

}

#vms images
variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

}

#vms secrets
variable "vm_secrets" {
  type = object({
    admin_username = string
    // admin_password = string // Removed as password is now random
  })
  sensitive = true
}

#vms extension
variable "vm_extension" {
  type = object({
    name                 = string
    publisher            = string
    type                 = string
    type_handler_version = string
    // protected_settings removed from here
  })
}

#azure webapp
variable "webapp" {
  type = object({
    webapp_name    = string
    python_version = string # Added for Python configuration
    startup_command = string # Added for custom startup command
  })
}

#azure appservice
variable "appservice" {
  type = object({
    appservice_name = string
    os_type         = string
    sku_name        = string
  })
}
