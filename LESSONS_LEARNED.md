# 📝 Lessons Learned & Engineering Troubleshooting Log

This document records real-world technical challenges, root-cause analyses, step-by-step resolutions, and best practices established while building the **30-Day Cloud & DevOps Portfolio Lab** on Microsoft Azure using Terraform.

---

## 📌 Incident Summary Table

| Incident ID | Day | Focus Area | Error Code / Symptom | Root Cause | Resolution |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **INC-01** | Day 01 | Azure Policy Guardrails | `StatusCode=403 -- Original Error: Code="RequestDisallowedByAzure"` | Educational subscription enforced strict region deployment policies (`Allowed resource deployment regions`). | Discovered permitted regions via Azure CLI policy queries; updated Terraform configurations to `italynorth`. |
| **INC-02** | Day 01 | Azure CLI Subprocess Timeout | `exit status 0xc000013a` / `KeyboardInterrupt` | Terraform spawned background `az account show` process in Git Bash on Windows; interrupting it crashed Python execution context. | Exported `ARM_SUBSCRIPTION_ID` directly as an environment variable to bypass CLI subprocess calls. |
| **INC-03** | Day 01 | Git File Size Rejection | `GH001: Large files detected (>100MB)` | `.terraform/` provider binaries (`>240MB`) were staged and committed due to a missing `.gitignore`. | Created `.gitignore`, purged `.terraform/` from Git cache, reset unpushed commit history, and re-committed clean code. |
| **INC-04** | Day 01 | Undeclared Resource Reference | `Error: Reference to undeclared resource` | Module `outputs.tf` referenced Network Security Group (NSG) resources that were removed from `main.tf`. | Refactored `outputs.tf` to export only existing Virtual Network and Subnet attributes. |
| **INC-05** | Day 01 | Git Directory Tracking Error | `fatal: pathspec 'docs/screenshots/day-01/' did not match any files` | Git does not track empty directories until files or `.gitkeep` placeholders exist inside them. | Created directory structure and added a `.gitkeep` file before running `git add`. |
| **INC-06** | Day 02 | Provider Version Incompatibility | `Error: Unsupported argument ... resource_provider_registrations = "none"` | `resource_provider_registrations` is exclusive to AzureRM Provider `v4.x`, but `providers.tf` was pinned to `~> 3.80.0`. | Removed the invalid argument and retained `skip_provider_registration = true` for `v3.x` compatibility. |
| **INC-07** | Day 02 | Git Remote / Local Sync Drift | `! [rejected] main -> main (non-fast-forward)` / Remote ahead of local branch | Unsynced commits on GitHub remote repository conflicted with incoming local pushes. | Staged/committed local work and executed `git pull origin main --rebase` to reconcile branch histories cleanly. |

---

## 🔍 Detailed Incident Breakdowns & Resolutions

### INC-01: Tenant Region Enforcement (`RequestDisallowedByAzure`)

* **Symptom:** Running `terraform apply` failed with HTTP `StatusCode=403` and `RequestDisallowedByAzure` when attempting to create Virtual Networks and Network Security Groups in `eastus` or `westeurope`:
  ```text
  Error: creating/updating Virtual Network ... StatusCode=403 -- Original Error: Code="RequestDisallowedByAzure" 
  Message="Resource 'dev-vnet' was disallowed by Azure: This policy maintains a set of best available regions..."