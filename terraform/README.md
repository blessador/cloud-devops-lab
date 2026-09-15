# 🏗️ Terraform Infrastructure Modules & Deployment Guide

This directory contains the modular Infrastructure as Code (IaC) configuration for deploying high-availability compute and networking environments on Azure.

---

## 📦 Provisioned Modules & Resources

### 1. Networking Module (`modules/vnet`)
* **`azurerm_resource_group`**: Scope wrapper for environment resources.
* **`azurerm_virtual_network`**: Core VNet (`10.0.0.0/16`).
* **`azurerm_subnet`**: Compute tier subnet (`10.0.1.0/24`).

### 2. Compute & Load Balancing Module (`modules/vm`)
* **`azurerm_public_ip.lb_pip`**: Standard SKU Public IP for incoming Load Balancer traffic.
* **`azurerm_public_ip.vm_pip`**: Dedicated Standard Public IPs for direct SSH administration.
* **`azurerm_network_security_group`**: Inbound rules permitting SSH (22), HTTP (80), and explicit `AzureLoadBalancer` health probes.
* **`azurerm_lb` & `azurerm_lb_backend_address_pool`**: Standard SKU Azure Load Balancer routing port 80 traffic.
* **`azurerm_lb_probe`**: HTTP Health Probe checking `/` on Port 80 every 5 seconds.
* **`azurerm_linux_virtual_machine`**: Scaled Linux compute instances (`count = 2`, `Standard_D2s_v3`).

---

## 🚀 Execution & Deployment Guide

```bash
# 1. Initialize Terraform & Remote Backend Storage
terraform init

# 2. Plan Infrastructure Execution Graph
terraform plan

# 3. Apply Provisioning Graph
terraform apply -auto-approve

# 4. Verify Multi-Node Load Distribution
for i in {1..6}; do 
  curl -s -H "Connection: close" http://$(terraform output -raw load_balancer_public_ip) | grep "Served by Node"; 
  sleep 1; 
done

# 5. Clean Up / Destroy Resources
terraform destroy -auto-approve
```

## 📤 Module Outputs

| Output Name | Type | Description |
|---|---|---|
| `load_balancer_public_ip` | `string` | Public IP address of the Azure Load Balancer |
| `vm_public_ips` | `list(string)` | Direct Public IP addresses of individual Web Server VMs |
