
```markdown
# 🛠️ Infrastructure as Code — Azure Terraform Labs

This directory contains the modular Terraform code for deploying cloud infrastructure across the 30-day lab series.

---

## 📁 Folder Structure

```text
terraform/
├── main.tf              # Root configuration & module instantiation
├── providers.tf         # AzureRM provider & remote backend block
├── variables.tf         # Global input variables
├── outputs.tf           # Root level deployment outputs
├── backend_info.txt     # Created storage account metadata
├── .gitignore           # Ignores local state, plans, and provider binaries
└── modules/
    └── vnet/            # Custom reusable Virtual Network module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf