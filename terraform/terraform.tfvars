#Here we declare the variable values

#resource group
resource_group = {
  location = "east us"
  name     = "jenkins-rg" # Example name, can be changed
}

#virtual network
virtual_network = {
  address_space = ["10.0.0.0/16"]
  name          = "vnet1"
}

#subnet
subnet = {
  address_prefixes = ["10.0.2.0/24"]
  name             = "subnet1"
}

#public ip
public_ip = {
  master_ip_name    = "master_ip"
  allocation_method = "Static"
}

#network interface
network_interface = {
  ip_configuration_name         = "internal"
  master_nic_name               = "nic1"
  private_ip_address_allocation = "Dynamic"

}

#network security group
network_security_group = {
  network_security_group_name = "SecurityGroup"
}

#security rule
security_rule = {
  name                       = "JenkinsWebAccess" # Name for the security rule, can be changed
  priority                   = "200"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp" # Changed from * to Tcp
  source_port_range          = "*"   # Keep as * for source, or restrict if known
  destination_port_range     = "*"
  source_address_prefix      = "0.0.0.0/0" # Or a specific IP range for added security e.g. your Azure DevOps agent IP
  destination_address_prefix = "*"
}

#security rule for SSH (optional, but recommended for VM access)
# security_rule_ssh = {
#   name                       = "SSH"
#   priority                   = "220"
#   direction                  = "Inbound"
#   access                     = "Allow"
#   protocol                   = "Tcp"
#   source_port_range          = "*"
#   destination_port_range     = "22" # SSH port
#   source_address_prefix      = "YOUR_IP_ADDRESS_OR_RANGE" # Replace with your IP or a trusted range
#   destination_address_prefix = "*"
# }

#security rule for App Service (if needed, though typically handled by App Service itself)
# security_rule_app_service = {
#   name                       = "AppServiceHTTP"
#   priority                   = "240"
#   direction                  = "Inbound"
#   access                     = "Allow"
#   protocol                   = "Tcp"
#   source_port_range          = "*"
#   destination_port_range     = "80" # HTTP port for the app service
#   source_address_prefix      = "AzureCloud" # Allow traffic from Azure services
#   destination_address_prefix = "*"
# }

#virtual machine(s)
virtual_machines = {
  master_name                     = "mastervm" # Example name, can be changed
  size                            = "Standard_D2s_v3"
  priority                        = "Spot"
  eviction_policy                 = "Deallocate"
  max_bid_price                   = "0.20"
  disable_password_authentication = "false"
}

#vms os disk
os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "Premium_LRS"
}

#vms image
source_image_reference = {
  offer     = "CentOS"
  publisher = "OpenLogic"
  version   = "latest"
  sku       = "8_5-gen2"
}

#vms secrets
vm_secrets = {
  admin_username = "<ADMIN-USERNAME>" # Replace with your desired admin username
}

#vms extension
vm_extension = {
  name                 = "script"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
}

#azure appservice
appservice = {
  appservice_name = "pythonserviceplan" # Example name, can be changed
  os_type         = "Linux"
  sku_name        = "B1"                # Basic tier, suitable for dev/test
}

#azure webapp
webapp = {
  webapp_name     = "python-flask-app-example" # Example name, ensure it's globally unique
  python_version  = "3.13"                      # Matches Jenkinsfile build environment
  startup_command = "gunicorn --bind=0.0.0.0 --timeout 600 app:app" # Gunicorn for Flask
}
