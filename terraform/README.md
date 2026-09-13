```markdown
# 🛠️ Infrastructure as Code — Azure Terraform Labs

This directory contains the modular **Terraform** configurations used to provision and manage Microsoft Azure infrastructure resources across the 30-day portfolio lab.

---

## 📁 Repository Structure

```text
terraform/
├── main.tf              # Root configuration & module instantiations
├── providers.tf         # AzureRM provider setup & remote storage state backend
├── variables.tf         # Global input variable definitions
├── outputs.tf           # VM public IP and network outputs
└── modules/
    ├── vnet/            # Virtual Network & Subnet module
    └── vm/              # Compute, NIC, NSG, Public IP & Cloud-Init module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── scripts/
            └── user_data.sh # Cloud-Init bootstrapping script