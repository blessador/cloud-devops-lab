# 1. Azure Standard Load Balancer
resource "azurerm_lb" "lb" {
  name                = "lb-dev-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = var.public_ip_id
  }
}

# 2. Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

# 3. Associate NICs to Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_assoc" {
  count                   = length(var.nic_ids)
  network_interface_id    = var.nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

# 4. HTTP Health Probe (Port 80)
resource "azurerm_lb_probe" "hp" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-health-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

# 5. Load Balancing Rule (Forward Port 80 -> Backend Port 80)
resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "HTTP-Traffic-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.hp.id
}
