#maser vm ip address
output "ip_address_master_vm" {
  value = azurerm_public_ip.master-ip.ip_address
}

output "webapp_default_hostname" {
  value = azurerm_linux_web_app.webapp.default_hostname
  description = "The default hostname of the deployed Python web app."
}

output "virtual_machine_admin_password" {
  value       = random_password.password.result
  description = "The randomly generated admin password for the Jenkins VM."
  sensitive   = true
}
