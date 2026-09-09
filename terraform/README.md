```markdown
# 🛠️ Infrastructure as Code — Day 01 (Azure Network Module)

This directory contains the modular Terraform code for deploying the baseline cloud networking layer on Microsoft Azure.

---

## 📁 Folder Structure

```text
terraform/
├── main.tf              # Root configuration & module instantiation
├── providers.tf         # AzureRM provider requirements & settings
├── variables.tf         # Global input variables
├── outputs.tf           # Root level deployment outputs
├── .gitignore           # Prevents committing provider binaries & state
└── modules/
    └── vnet/            # Custom reusable Virtual Network module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
