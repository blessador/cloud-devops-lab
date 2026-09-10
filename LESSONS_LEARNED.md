Markdown
# 📝 Lessons Learned & Engineering Troubleshooting Log

This document records real-world technical challenges, root-cause analyses, step-by-step resolutions, and best practices established while building the **30-Day Cloud & DevOps Portfolio Lab** on Microsoft Azure using Terraform.

---

## 📌 Incident Summary Table

| Incident ID | Focus Area | Error Code / Symptom | Root Cause | Resolution |
| :--- | :--- | :--- | :--- | :--- |
| **INC-01** | Azure Policy Guardrails | `StatusCode=403 -- Original Error: Code="RequestDisallowedByAzure"` | Educational subscription enforced strict region deployment policies (`Allowed resource deployment regions`). | Discovered permitted regions via Azure CLI policy queries; updated Terraform configurations to `italynorth`. |
| **INC-02** | Azure CLI Subprocess Timeout | `exit status 0xc000013a` / `KeyboardInterrupt` | Terraform spawned background `az account show` process in Git Bash on Windows; interrupting it crashed the Python execution context. | Exported `ARM_SUBSCRIPTION_ID` directly as an environment variable to bypass CLI subprocess calls. |
| **INC-03** | Git File Size Rejection | `GH001: Large files detected (>100MB)` | `.terraform/` provider binaries (`>240MB`) were staged and committed due to a missing `.gitignore`. | Created `.gitignore`, purged `.terraform/` from Git cache, reset unpushed commit history, and re-committed clean code. |
| **INC-04** | Undeclared Resource Reference | `Error: Reference to undeclared resource` | Module `outputs.tf` referenced Network Security Group (NSG) resources that were removed from `main.tf`. | Refactored `outputs.tf` to export only existing Virtual Network and Subnet attributes. |
| **INC-05** | Git Directory Tracking Error | `fatal: pathspec 'docs/screenshots/day-01/' did not match any files` | Git does not track empty directories until files or `.gitkeep` placeholders exist inside them. | Created directory structure and added a `.gitkeep` file before running `git add`. |

---

## 🔍 Detailed Incident Breakdowns & Resolutions

### INC-01: Tenant Region Enforcement (`RequestDisallowedByAzure`)

* **Symptom:** Running `terraform apply` failed with HTTP `StatusCode=403` and `RequestDisallowedByAzure` when attempting to create Virtual Networks and Network Security Groups in `eastus` or `westeurope`:
  ```text
  Error: creating/updating Virtual Network ... StatusCode=403 -- Original Error: Code="RequestDisallowedByAzure" 
  Message="Resource 'dev-vnet' was disallowed by Azure: This policy maintains a set of best available regions..."
Root Cause: The educational tenant ("Azure for Students") enforced a active policy assignment restricting resource creation to specific European region clusters. Portal GUI creations sometimes bypassed initial validation, but ARM API programmatic calls via Terraform were strictly blocked.

Troubleshooting Steps:
Queried policy assignments attached to the active subscription using Azure CLI:

Bash
az policy assignment list --query "[?contains(displayName, 'region') || contains(displayName, 'location')].{Name:displayName, AllowedLocations:parameters.listOfAllowedLocations.value}" -o json
Output Discovered:

JSON
[
  {
    "AllowedLocations": [
      "italynorth",
      "austriaeast",
      "polandcentral",
      "francecentral",
      "spaincentral"
    ],
    "Name": "Allowed resource deployment regions"
  }
]
Resolution:
Updated location across terraform/main.tf and terraform/modules/vnet/variables.tf to italynorth:

Terraform
resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-devops-lab"
  location = "italynorth"
}
INC-02: Azure CLI Subprocess Interruption (0xc000013a)
Symptom: Pressing Ctrl+C or interrupting terraform plan / terraform apply triggered Python tracebacks (humanfriendly/terminal import failure) with exit code 0xc000013a:

Plaintext
Error: unable to build authorizer for Batch Management API: could not configure AzureCli Authorizer:
obtaining subscription ID: running Azure CLI: exit status 0xc000013a
...
KeyboardInterrupt
Root Cause: When subscription_id is not explicitly set in Terraform configuration or environment variables, the HashiCorp AzureRM provider executes az account show behind the scenes. Interrupting this sub-process in Git Bash on Windows breaks Python's standard output handles.

Resolution:
Explicitly exported ARM_SUBSCRIPTION_ID directly into the Git Bash environment session:

Bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
Additionally updated providers.tf to disable provider registration checks that cause timeouts on restricted subscriptions:

Terraform
provider "azurerm" {
  features {}
  skip_provider_registration      = true
  resource_provider_registrations = "none"
}
INC-03: Git Remote Rejection Due to Staged Provider Binaries (GH001)
Symptom: Running git push origin main failed with a pre-receive hook refusal from GitHub:

Plaintext
remote: error: File terraform/.terraform/providers/registry.terraform.io/hashicorp/azurerm/3.80.0/windows_amd64/terraform-provider-azurerm_v3.80.0_x5.exe is 246.39 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected.
! [remote rejected] main -> main (pre-receive hook declined)
Root Cause: Running git add . without a root .gitignore staged the hidden .terraform/ dependency directory, which contained the downloaded 246 MB AzureRM provider binary.

Resolution:

Created a root .gitignore file to permanently exclude state files and provider binaries:

Bash
cat << 'EOF' > .gitignore
# Terraform internal files
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log

# OS generated files
.DS_Store
Thumbs.db
EOF
Cleared tracked binary objects from Git's index:

Bash
git rm -r --cached terraform/.terraform/
Reset the local unpushed commit to remove the large blob from Git history:

Bash
git reset --soft HEAD~1
git add .
git commit -m "feat(terraform): complete Day 1 Azure VNet deployment in italynorth"
git push origin main
INC-04: Undeclared Resource Reference in Module Outputs
Symptom: Running terraform plan failed during configuration parsing:

Plaintext
Error: Reference to undeclared resource
  on modules\vnet\outputs.tf line 23, in output "public_nsg_id":
  23:   value       = azurerm_network_security_group.public_nsg.id
A managed resource "azurerm_network_security_group" "public_nsg" has not been declared in module.vnet.
Root Cause: To isolate policy blocking issues during VNet debugging, Network Security Group resource blocks were removed from modules/vnet/main.tf, but modules/vnet/outputs.tf still contained output references pointing to those non-existent resources.

Resolution:
Refactored modules/vnet/outputs.tf to export only active infrastructure attributes:

Terraform
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = azurerm_subnet.private[*].id
}
INC-05: Git Directory Pathspec Mismatch (docs/screenshots/)
Symptom: Running git add docs/screenshots/day-01/ returned a pathspec error:

Plaintext
fatal: pathspec 'docs/screenshots/day-01/' did not match any files
Root Cause: Git tracks files, not empty directory paths. The folder docs/screenshots/day-01/ was created, but contained no image files or placeholder files when git add was called.

Resolution:
Created a hidden .gitkeep placeholder file so Git tracks the directory structure until final screenshot assets are saved:

Bash
mkdir -p docs/screenshots/day-01
touch docs/screenshots/day-01/.gitkeep
git add .
💡 Best Practices Established
Always Inspect Azure Policy Assignments First: On restricted educational or enterprise tenants, query az policy assignment list before selecting regions for IaC code to avoid debugging silent blocks.

Never Track Terraform Binaries or State in Version Control: Maintain a strict .gitignore at the root of every repository containing .terraform/, *.tfstate, and *.tfplan.

Explicitly Supply Azure Environment Variables: Define ARM_SUBSCRIPTION_ID in Git Bash sessions on Windows to prevent CLI auth subprocess freezes.

Synchronize Resource Removal Across Modules: When commenting out or deleting resource blocks in main.tf, always check and clean corresponding references in outputs.tf and variables.tf.
