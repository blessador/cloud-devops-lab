```markdown
# 🛠️ Infrastructure as Code — Azure Terraform Labs

## 📁 Folder Structure

```text
terraform/
├── main.tf              # Root configuration & module instantiations
├── providers.tf         # AzureRM provider & Azure Blob remote state
├── variables.tf         # Global input variables
├── outputs.tf           # VM public IP and VNet outputs
└── modules/
    ├── vnet/            # Virtual Network & Subnets module
    └── vm/              # Linux VM, Public IP & NSG module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf