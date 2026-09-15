# 📓 Day 05 Architecture Log: Azure Standard Load Balancer & Multi-Node Scaling

## 🎯 Objective
Scale a single-node NGINX deployment to a 2-node cluster (`Standard_D2s_v3`) managed by an Azure Standard Load Balancer with dynamic HTTP health probes and explicit Network Security Group (NSG) permissions.

---

## 🔬 Incident Reports & Troubleshooting

### INC-16: Cloud-Init Execution Failure due to Windows CRLF Line Endings
* **Symptom:** `systemctl status nginx` returned `Unit nginx.service could not be found`. `cloud-init-output.log` finished in under 2 seconds without executing package commands.
* **Root Cause:** Script `user_data.sh` had Windows carriage returns (`\r\n`), causing Linux `/bin/bash` to fail silently when evaluating the hashbang interpreter.
* **Resolution:** Converted script line endings to Unix (LF) via `sed -i 's/\r$//'`, tainted VM instances, and forced Terraform re-creation.

### INC-17: Connection Refusal via External IP inside SSH Session (Hairpin NAT)
* **Symptom:** `curl http://<VM_PUBLIC_IP>` inside an active SSH session returned `curl: (7) Failed to connect... Connection refused`.
* **Root Cause:** Azure VNet internal hairpin NAT rules prevent instances from routing out to their own external public IP and back into the local interface.
* **Resolution:** Verified local service health using `curl http://localhost` within SSH, and executed external verification directly from local Git Bash.

### INC-18: Load Balancer Health Probe Traffic Drop on Standard SKU
* **Symptom:** Load Balancer Public IP returned connection timeouts despite backend NGINX instances being active.
* **Root Cause:** Azure Standard Load Balancers strictly block 100% of ingress traffic to backend pool members until the health probe receives successful HTTP 200 responses. Strict NSG rules were blocking probe requests coming from `168.63.129.16`.
* **Resolution:** Added explicit NSG security rule `AllowAzureLoadBalancerInbound` allowing source service tag `AzureLoadBalancer` on Port 80.

### INC-19: Load Balancer Traffic Sticky Session Behavior during Testing
* **Symptom:** Standard `curl` loop returned responses exclusively from `vm-dev-web-1`.
* **Root Cause:** HTTP/1.1 default TCP connection keep-alive reused the existing connection socket across loop iterations.
* **Resolution:** Executed request loop passing explicit connection close headers: `curl -H "Connection: close"`.

---

## 📸 Verification & Proof of Work

### 1. Load Distribution Verification Loop
```bash
$ for i in {1..6}; do curl -s -H "Connection: close" http://68.210.98.7 | grep "Served by Node"; sleep 1; done
    <p>Served by Node: vm-dev-web-2</p>
    <p>Served by Node: vm-dev-web-1</p>
    <p>Served by Node: vm-dev-web-2</p>
    <p>Served by Node: vm-dev-web-1</p>
    <p>Served by Node: vm-dev-web-2</p>
    <p>Served by Node: vm-dev-web-1</p>
```

### 2. Screenshots Artifact Checklist
- `docs/screenshots/day-05/01-lb-curl-load-distribution.png`: Git Bash terminal showing round-robin responses.
- `docs/screenshots/day-05/02-azure-lb-backend-pool.png`: Azure Portal showing `nic-dev-vm-1` and `nic-dev-vm-2` in `BackEndAddressPool`.
- `docs/screenshots/day-05/03-azure-lb-health-probe.png`: Azure Portal showing 100% healthy probe status on Port 80.

---

## 🔮 Next Steps

- **Perform Day 05 Teardown:** Capture final metrics and tear down all Day 05 Azure resources using Terraform.
- **Commit Day 05 to GitHub:** Add, commit, and push all Day 05 changes and documentation to GitHub.
