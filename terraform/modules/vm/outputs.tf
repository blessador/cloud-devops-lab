output "lb_public_ip_id" {
  value = azurerm_public_ip.lb_pip.id
}

output "lb_public_ip_address" {
  value = azurerm_public_ip.lb_pip.ip_address
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}

output "vm_public_ip_addresses" {
  value = azurerm_public_ip.vm_pip[*].ip_address
}
