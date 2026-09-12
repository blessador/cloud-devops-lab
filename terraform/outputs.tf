output "vm_public_ip" {
  description = "Public IP address of the deployed Linux VM"
  value       = module.vm.public_ip_address
}
