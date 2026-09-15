# 🚀 30-Day Cloud & DevOps Portfolio Lab: Microsoft Azure & Terraform

Hands-on infrastructure engineering lab tracking daily progress in modular infrastructure as code (IaC), networking, load balancing, security, and cloud automation on Azure using Terraform.

---

## 📅 Daily Execution Log

| Day | Module / Architecture Target | Key Deliverables | Status |
| :--- | :--- | :--- | :---: |
| **Day 01** | **VNet & Subnet Modularization** | Modularized VNet, Subnet, and Resource Group structure | Completed |
| **Day 02** | **Terraform Remote State** | Configured Azure Storage Account backend with Blob lease locking | Completed |
| **Day 03** | **Network Security Groups** | NSG rules restricting SSH (Port 22) & HTTP (Port 80) access | Completed |
| **Day 04** | **VM Provisioning & Cloud-Init** | Single Ubuntu 22.04 VM auto-provisioned with NGINX via Cloud-Init | Completed |
| **Day 05** | **Standard Load Balancer & Scaling** | Multi-node (`count = 2`) backend cluster under Azure Standard LB | Completed |

---

## 🛠️ Architecture Overview (Day 05 State)

```text
[ Internet / Client ]
          │
          ▼
┌────────────────────────────────────────────────────────┐
│   Azure Standard Load Balancer (Public IP: 68.210.98.7)│
└─────────────────────────┬──────────────────────────────┘
                          │ (Port 80 TCP Probe & Traffic)
        ┌─────────────────┴─────────────────┐
        ▼                                   ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│  NIC: nic-dev-vm-1      │       │  NIC: nic-dev-vm-2      │
│  VM: vm-dev-web-1       │       │  VM: vm-dev-web-2       │
│  (Ubuntu 22.04 / NGINX) │       │  (Ubuntu 22.04 / NGINX) │
└─────────────────────────┘       └─────────────────────────┘
```

## 🛠️ Tech Stack & Tools

- **Cloud Provider:** Microsoft Azure
- **IaC Tool:** Terraform v1.x (AzureRM Provider ~> 3.0)
- **OS / Server:** Ubuntu Server 22.04 LTS / NGINX Web Server
- **Local Terminal:** Git Bash (Windows MSYS2)
- **Version Control:** Git & GitHub

## 📂 Repository Structure

<<<<<<< HEAD
### 1. Successful apply with port 80 rule & custom_data
![Terraform Apply](./docs/screenshots/day-04/01-terraform-apply.png)

### 2. Live Web Server Landing Page
![NGINX Custom Landing Page](./docs/screenshots/day-04/02-nginx-browser.png)

### 3. Cloud-Init Boot Log Execution
![Cloud-Init Execution Log](./docs/screenshots/day-04/03-cloud-init-log.png)

---

## 🛠️ Rapid Verification

```bash
# Test HTTP response headers from local terminal
curl -I http://<VM_PUBLIC_IP>

# Fetch custom HTML landing page
curl http://<VM_PUBLIC_IP>
=======
```text
cloud-devops-lab/
├── README.md                          # Global Portfolio Documentation
├── terraform/                         # Primary Terraform Configuration Root
│   ├── main.tf                        # Root Module & Azure Provider Setup
│   ├── variables.tf                   # Global Input Variables
│   ├── outputs.tf                     # Environment Output Definitions
│   ├── terraform.tfvars               # Infrastructure Variable Overrides
│   └── modules/                       # Reusable IaC Modules
│       ├── vnet/                      # Virtual Network & Subnet Module
│       └── vm/                        # Multi-Node VM & Load Balancer Module
└── docs/
    ├── lessons/
    │   └── day-05.md                  # Day 05 Detailed Incident Log & Verification
    └── screenshots/
        └── day-05/                    # Visual Proof of Load Balancing & LB Configuration
```
>>>>>>> c2359cd (docs(day-05): complete load balancer integration and lesson logs)
