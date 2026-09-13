# 📓 Day 04 Lessons Learned: Cloud-Init & NGINX Automation

This document logs real-world technical challenges, failure modes, root-cause analyses, and resolutions encountered during **Day 04: Web Server Automation (NGINX & Cloud-Init)**.

## INC-13: Storage Backend Resource Group Not Found

### Symptom

Running:

```bash
terraform apply
```

failed with:

```text
StatusCode=404 Code="ResourceGroupNotFound"
```

### Root Cause

The resource group hosting the Terraform state storage account was manually deleted or destroyed during a previous cleanup cycle.

### Resolution

Re-provisioned the backend storage infrastructure via Azure CLI and re-initialized the Terraform state:

```bash
az group create   --name rg-cloud-devops-lab   --location austriaeast

az storage account create   --name sttfstatedevops4595   --resource-group rg-cloud-devops-lab   --location austriaeast   --sku Standard_LRS

az storage container create   --name tfstate   --account-name sttfstatedevops4595   --auth-mode login

terraform init -reconfigure
```

## INC-14: Cloud-Init Non-Execution on Existing Virtual Machines

### Symptom

The `custom_data` script was updated in Terraform code, but NGINX was not installed after running `terraform apply`.

### Root Cause

Cloud-Init scripts execute during the initial OS boot sequence. Updating `custom_data` on an already-running VM does not automatically cause Cloud-Init to execute again.

Cloud-Init execution logs can be found at:

```text
/var/log/cloud-init-output.log
```

### Resolution

Marked the VM resource for replacement to force a fresh boot sequence:

```bash
terraform taint module.vm.azurerm_linux_virtual_machine.vm
terraform apply -auto-approve
```

## INC-15: Browser HTTPS Auto-Upgrades on Unencrypted HTTP Endpoints

### Symptom

Running:

```bash
curl -I http://<PUBLIC_IP>
```

returned:

```text
HTTP/1.1 200 OK
```

However, web browsers timed out or refused the connection.

### Root Cause

Web browsers may automatically rewrite or upgrade `http://` URLs to `https://`.

This changes the connection from TCP port 80 to TCP port 443, which was blocked by the Network Security Group (NSG).

### Resolution

Forced an explicit HTTP connection in the browser address bar:

```text
http://<PUBLIC_IP>
```

Testing in an Incognito/Private window was also used to avoid cached HTTPS/HSTS behavior.

## INC-16: Windows CRLF Line Endings Breaking Cloud-Init Script Execution

### Symptom

Cloud-Init reported:

```text
status: done
```

within approximately two seconds, but NGINX was not installed.

Additionally, `/var/log/cloud-init-output.log` contained no expected script execution logs.

### Root Cause

The shell script was created on Windows/Git Bash and contained CRLF (`
`) line endings.

Linux interpreted the shebang as:

```text
#!/bin/bash
```

instead of:

```text
#!/bin/bash
```

As a result, the system could not locate the expected interpreter and the script failed to execute correctly.

### Resolution

Stripped carriage-return characters from the script before deployment:

```bash
sed -i 's/\r$//' terraform/modules/vm/scripts/user_data.sh
```

## INC-17: Internal VNet Hairpinning & Loopback Routing Restriction

### Symptom

Running the following command from an SSH session on the VM:

```bash
curl http://<PUBLIC_IP>
```

returned:

```text
Connection refused
```

### Root Cause

Azure VNet internal routing prevents a virtual machine from accessing its own external Public IP address through loopback/hairpin NAT in the expected manner.

### Resolution

Tested internal service availability using:

```bash
curl http://localhost
```

from within the SSH session.

Public IP verification was performed from a local client terminal outside the Azure VNet.

## 🔑 Key Lessons Learned

- **Terraform state infrastructure is a dependency:** If the backend resource group or storage account is deleted, Terraform must be reconfigured against a recreated backend.
- **Cloud-Init is primarily a first-boot mechanism:** Changes to `custom_data` do not mean an existing VM will automatically rerun the initialization script.
- **HTTP and HTTPS are different network paths:** A successful `curl` test against port 80 does not guarantee that a browser will connect successfully over HTTPS/port 443.
- **Line endings matter in automation:** Windows CRLF line endings can cause Linux shell scripts and Cloud-Init execution to fail.
- **Test from the correct network location:** `localhost` is appropriate for validating the service from inside the VM, while the Public IP should be tested from an external client.
