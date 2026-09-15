# 📓 Master Incident Log & Lessons Learned

This document serves as a centralized post-mortem tracking log for all technical challenges, configuration bugs, cloud provisioning edge cases, and incident resolutions encountered during the **30-Day Azure & Terraform Cloud/DevOps Lab**.

---

## 🗓️ Day 05: Azure Standard Load Balancer & Backend Scaling

### INC-16: Cloud-Init Silent Failure via Windows Line Endings (CRLF)

- **Symptom:** `systemctl status nginx` returned `Unit nginx.service could not be found`. The execution log `/var/log/cloud-init-output.log` completed in under 2 seconds without installing software.
- **Root Cause:** `user_data.sh` contained Windows carriage returns (`\r\n`), causing the Linux bash interpreter (`#!/bin/bash\r`) to fail silently on boot.
- **Resolution:** Stripped carriage returns using `sed -i 's/\r$//' modules/vm/scripts/user_data.sh`, tainted both VM instances in Terraform state (`terraform taint`), and executed `terraform apply`.

### INC-17: Internal VNet Hairpin NAT / Loopback Restriction

- **Symptom:** Executing `curl http://<VM_PUBLIC_IP>` inside an SSH session returned `curl: (7) Failed to connect... Connection refused`.
- **Root Cause:** Azure Virtual Network security policies prevent a VM from routing out to its own assigned public IP and looping back into its local interface.
- **Resolution:** Verified local NGINX process health using `curl http://localhost` within the SSH session, and executed external endpoint tests exclusively from the local Git Bash client.

### INC-18: Standard Load Balancer Inbound Traffic Blocked by Missing Health Probe Rule

- **Symptom:** Inbound HTTP requests to the Load Balancer Public IP timed out despite NGINX running cleanly on backend nodes.
- **Root Cause:** Azure Standard Load Balancers drop 100% of ingress traffic to backend pool members if HTTP health probes fail. Default NSG rules were blocking probe requests originating from the `168.63.129.16` Azure infrastructure IP.
- **Resolution:** Provisioned an explicit NSG security rule (`AllowAzureLoadBalancerInbound`) matching source service tag `AzureLoadBalancer` on destination Port 80.

### INC-19: HTTP TCP Connection Keep-Alive Preventing Load Distribution Testing

- **Symptom:** A standard `curl` bash loop repeatedly returned responses from `vm-dev-web-1` without balancing to `vm-dev-web-2`.
- **Root Cause:** Default HTTP/1.1 TCP socket reuse kept the connection open to the initial backend node across loop iterations.
- **Resolution:** Modified the test loop to pass an explicit connection header forcing connection rotation per request:

```bash
for i in {1..6}; do
  curl -s -H "Connection: close" http://<LB_PUBLIC_IP> | grep "Served by Node"
  sleep 1
done
```

---

## 🗓️ Day 04: Virtual Machine Automation & Custom Data

### INC-13: SSH Public Key Path Mismatch

- **Symptom:** SSH connection attempts failed with `Permission denied (publickey)`.

- **Root Cause:** OpenSSH client defaulted to searching for `~/.ssh/id_rsa`, whereas the active keypair generated for the lab environment was `~/.ssh/devops_id_rsa`.

- **Resolution:** Specified the exact private key flag (`ssh -i ~/.ssh/devops_id_rsa`) and aligned `ssh_public_key_path` in `terraform.tfvars`.

### INC-14: Cloud-Init Apt Repository Lock Contention

- **Symptom:** Package installation failed with `E: Could not get lock /var/lib/dpkg/lock-frontend`.

- **Root Cause:** Ubuntu's automated background update service (`unattended-upgrades`) ran concurrently during VM boot alongside the Cloud-Init script.

- **Resolution:** Added defensive delays and non-interactive apt flags to `user_data.sh`:

```bash
export DEBIAN_FRONTEND=noninteractive
systemctl stop unattended-upgrades
apt-get update -y
```

---

## 🗓️ Day 03: Security Groups & Access Control

### INC-09: Excessive Inbound Management Exposure

- **Symptom:** Potential security risk from open SSH access across all internet source vectors.

- **Root Cause:** Initial NSG rule used wildcard `*` source prefixes for port 22 access.

- **Resolution:** Constrained SSH inbound rules to specific developer source IPs and segregated public web traffic (Port 80) into explicit rule priorities.

---

## 🗓️ Day 02: Remote State & Backend Synchronization

### INC-05: State File Lock Acquisition Timeouts

- **Symptom:** `terraform apply` hung attempting to acquire state lock on Azure Blob Storage.

- **Root Cause:** Interrupted local terminal execution left a persistent lease on the state container blob.

- **Resolution:** Cleared orphan leases via Azure CLI / Portal and validated blob container permissions for lease acquisition.

---

## 🗓️ Day 01: Core VNet & Subnet Modularization

### INC-01: Azure Provider Variable Scope Mismatches

- **Symptom:** Module initialization errors during `terraform plan`.

- **Root Cause:** Submodules attempted to access root-level variables without explicit declaration within `modules/vnet/variables.tf`.

- **Resolution:** Standardized input/output contracts across root and child module parameters.

---

## Next Steps

- Commit updated documentation to Git.
- Perform Day 05 resource teardown with `terraform destroy` when the lab resources are no longer required.
