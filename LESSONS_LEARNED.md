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
| **INC-08** | Day 03 | Public IP SKU Quota | `Code="IPv4BasicSkuPublicIpCountLimitReached"` | Azure zero-quota restriction on legacy Basic SKU Public IPs for student subscriptions. | Updated `azurerm_public_ip` to `sku = "Standard"` and `allocation_method = "Static"`. |
| **INC-09** | Day 03 | Regional Compute Capacity | `Code="SkuNotAvailable"` | High demand on `Standard_B1s`/`B1ms` instances in restricted regional zones. | Shifted deployment region to `austriaeast` and scaled VM size to `Standard_D2s_v3`. |
| **INC-10** | Day 03 | MSYS Path Expansion | `Error: ID contained more segments than required... map[Program Files:Git]` | Git Bash on Windows automatically converts leading slashes (`/subscriptions/`) into Windows local paths. | Prepended `MSYS_NO_PATHCONV=1` to `terraform import` commands. |
| **INC-11** | Day 03 | Teardown Safety Lock | `Resource Group still contains Resources` | AzureRM safety feature prevents destroying Resource Groups containing out-of-band resources. | Configured `prevent_deletion_if_contains_resources = false` inside `provider "azurerm"` `features {}` block. |
| **INC-12** | Day 03 | SSH Fingerprint Validation | `Host key verification failed` | SSH connection dropped before accepting host fingerprint into `~/.ssh/known_hosts`. | Re-established SSH session and explicitly submitted `yes` at initial prompt. |
| **INC-13** | Day 04 | Storage Backend | `StatusCode=404 -- Code="ResourceGroupNotFound"` | Resource Group hosting `.tfstate` storage backend was purged during previous teardown. | Re-provisioned Resource Group and Storage Account via Azure CLI, then ran `terraform init -reconfigure`. |
| **INC-14** | Day 04 | Terraform / VM Lifecycle | `custom_data` script did not execute on active VM | Cloud-Init scripts execute strictly once during initial instance OS boot. | Executed `terraform taint module.vm.azurerm_linux_virtual_machine.vm` to force instance replacement. |
| **INC-15** | Day 04 | Network / Browser Security | `Connection refused` in browser but `200 OK` via `curl` | Modern browsers automatically rewrite `http://` to `https://` (Port 443), which was not open in NSG. | Tested using explicit `http://` in an Incognito window or verified via `curl -I`. |
| **INC-16** | Day 04 | Cloud-Init Script Encoding | Cloud-Init finished in ~2s without installing NGINX | Script saved with Windows CRLF (`\r\n`) line endings broke Linux `/bin/bash` interpreter. | Stripped carriage returns using `sed -i 's/\r$//' user_data.sh` prior to running `terraform apply`. |
| **INC-17** | Day 04 | Azure VNet Loopback Routing | `curl` to Public IP from inside VM failed (`Connection refused`) | Azure VNet NAT blocks host loopback/hairpinning to its own Public IP from within the VM. | Verified internal web server status using `curl http://localhost` inside SSH sessions. |

---

## 🔍 Detailed Incident Breakdowns & Resolutions

### INC-01: Tenant Region Enforcement (`RequestDisallowedByAzure`)

* **Symptom:** Running `terraform apply` failed with HTTP `StatusCode=403` and `RequestDisallowedByAzure` when attempting to create Virtual Networks and Network Security Groups in `eastus` or `westeurope`.
* **Root Cause:** Subscription policy restricted resource creation to specific allowed geographic regions.
* **Resolution:** Queried allowed locations via Azure CLI and set infrastructure region to `italynorth` (later adjusted to `austriaeast` for compute capacity).

---

### INC-08: Public IP Basic SKU Limit (`IPv4BasicSkuPublicIpCountLimitReached`)

* **Symptom:** `terraform apply` failed with `Cannot create more than 0 IPv4 Basic SKU public IP addresses for this subscription`.
* **Root Cause:** Microsoft Azure enforced a global policy restricting creation of Basic SKU Public IPs in favor of Standard SKUs.
* **Resolution:** Updated `modules/vm/main.tf` configuration:
  ```hcl
  resource "azurerm_public_ip" "pip" {
    name                = "pip-dev-vm"
    location            = var.location
    resource_group_name = var.resource_group_name
    allocation_method   = "Static"
    sku                 = "Standard"
  }