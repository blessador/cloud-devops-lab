variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "italynorth"
}

variable "vnet_name" {
  type    = string
  default = "dev-vnet"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "public_subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "private_subnet_prefixes" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Dev"
    Project     = "cloud-devops-lab"
    ManagedBy   = "Terraform"
    Day         = "01"
  }
}
