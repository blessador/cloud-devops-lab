output "public_ip_address" {
  description = "Public IP address of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}
