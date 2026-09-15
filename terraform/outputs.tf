output "load_balancer_public_ip" {
  value       = module.vm.lb_public_ip_address
  description = "Public IP address of the Azure Load Balancer"
}

output "vm_public_ips" {
  value       = module.vm.vm_public_ip_addresses
  description = "Direct Public IP addresses of individual Web Server VMs"
}
