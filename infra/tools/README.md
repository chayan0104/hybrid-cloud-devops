# Infrastructure Tools Setup Guides

**Location:** `infra/tools/`

Quick reference for DevOps setup and operations. Choose your path:

## 🚀 Getting Started Paths

### Path 1: Local Development (Docker Compose)
**Time:** 5 minutes  
**Skills required:** Basic Docker

→ [DOCKER_LOCAL_SETUP.md](DOCKER_LOCAL_SETUP.md) - Run everything locally with Docker

---

### Path 2: UAT Environment (Kubernetes + Tomcat VM)
**Time:** 30-45 minutes  
**Skills required:** Kubernetes, Terraform basics

→ [UAT_SETUP.md](UAT_SETUP.md) - Deploy to UAT cluster

**Prerequisites:**
1. [BOOTSTRAP.md](BOOTSTRAP.md) - Initialize Terraform state & Vault
2. [TERRAFORM_PROVISIONING.md](TERRAFORM_PROVISIONING.md) - Provision AWS infrastructure
3. [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md) - Deploy apps to K8s
4. [VAULT_SECRETS.md](VAULT_SECRETS.md) - Configure secret management

---

### Path 3: Production Environment (EKS + EC2 + RDS)
**Time:** 60+ minutes  
**Skills required:** AWS, Kubernetes, CI/CD

→ [PROD_SETUP.md](PROD_SETUP.md) - Production deployment

**Prerequisites:** Complete Path 2 first

---

## 📋 Setup Timeline

```
┌─────────────────────────────────────────────────────┐
│ Step 1: Local Dev (Docker) - 5 min                  │
├─────────────────────────────────────────────────────┤
│        ↓                                              │
│ Step 2: Bootstrap Terraform - 10 min                │
│ Step 3: Configure Vault - 15 min                    │
├─────────────────────────────────────────────────────┤
│        ↓                                              │
│ Step 4: Provision AWS (Terraform) - 15 min          │
│ Step 5: Setup Kubernetes - 15 min                   │
├─────────────────────────────────────────────────────┤
│        ↓                                              │
│ Step 6: Deploy Applications - 10 min                │
│ Step 7: Setup Monitoring - 10 min                   │
│ Step 8: Configure CI/CD (Jenkins) - 15 min          │
├─────────────────────────────────────────────────────┤
│ Total: ~2 hours for full environment               │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Commands Reference

### Local Development
```bash
cd applications
docker compose up -d --build
curl http://localhost:9091  # Frontend
```

### Bootstrap Phase (First-time setup)
```bash
# 1. Initialize Terraform state backend
cd infra/tools/bootstrap
bash bootstrap.sh

# 2. Configure Vault
cd infra/vault
bash vault-secrets-setup.sh
```

### Provisioning Phase (Infrastructure)
```bash
# 1. Provision PROD infrastructure
cd infra/terraform/prod
terraform init
terraform apply

# 2. Get outputs for next step
terraform output
```

### Deployment Phase (Applications)
```bash
# 1. Deploy to Kubernetes
kubectl apply -f k8s/

# 2. Verify
kubectl get all -n enterprise-app
```

### CI/CD Phase (Automation)
```bash
# See: JENKINS_CICD.md
# Access: http://jenkins.company.com
```

---

## 📚 Full Setup Guides

| Guide | Purpose | Audience | Time |
|-------|---------|----------|------|
| [DOCKER_LOCAL_SETUP.md](DOCKER_LOCAL_SETUP.md) | Local dev with Docker Compose | All developers | 5 min |
| [BOOTSTRAP.md](BOOTSTRAP.md) | Initialize Terraform + Vault | DevOps | 10 min |
| [TERRAFORM_PROVISIONING.md](TERRAFORM_PROVISIONING.md) | Provision AWS resources | DevOps/SRE | 15 min |
| [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md) | Deploy apps to K8s | DevOps/SRE | 15 min |
| [VAULT_SECRETS.md](VAULT_SECRETS.md) | Secret management | DevOps/Security | 20 min |
| [JENKINS_CICD.md](JENKINS_CICD.md) | CI/CD pipeline setup | DevOps | 30 min |
| [MONITORING_SETUP.md](MONITORING_SETUP.md) | Prometheus + Grafana + New Relic | DevOps/SRE | 20 min |
| [HELM_DEPLOYMENT.md](HELM_DEPLOYMENT.md) | Alternative Helm-based deployment | DevOps | 15 min |
| [TROUBLESHOOTING_TOOLS.md](TROUBLESHOOTING_TOOLS.md) | Common issues & debugging | All | Varies |

---

## 🔍 Pre-Requisites

### Local Development
- Docker & Docker Compose (latest)
- Git

### AWS/Kubernetes Deployment
- Terraform 1.5+
- kubectl 1.28+
- AWS CLI configured with credentials
- HashiCorp Vault CLI (optional)
- Helm 3.12+ (if using Helm)

**Verify prerequisites:**
```bash
bash infra/tools/verify-prerequisites.sh
```

---

## ⚙️ Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| **terraform.tfvars** | `infra/terraform/prod/` | AWS region, VPC CIDR, instance types |
| **vault-secrets-setup.sh** | `infra/vault/` | Secret seeding |
| **vault-policies.hcl** | `infra/vault/` | RBAC for Jenkins |
| **Jenkinsfile-*** | `infra/jenkins/` | CI/CD pipeline definitions |
| **docker-compose.yml** | `applications/` | Local development stack |
| **k8s/*.yaml** | `k8s/` | Kubernetes manifests |

---

## 🔐 Security Considerations

- Never commit secrets, API keys, or credentials
- Use Vault for all environment-specific secrets
- Use Kubernetes Secrets for pod-level credentials
- Enable RBAC for all service accounts
- Use NetworkPolicy for pod-to-pod communication
- Scan container images with Trivy

See [../../docs/SECURITY_GUIDE.md](../../docs/SECURITY_GUIDE.md) for details.

---

## 📞 Support & Troubleshooting

- **General issues:** [TROUBLESHOOTING_TOOLS.md](TROUBLESHOOTING_TOOLS.md)
- **Docker issues:** [DOCKER_LOCAL_SETUP.md](DOCKER_LOCAL_SETUP.md#troubleshooting)
- **Terraform errors:** [TERRAFORM_PROVISIONING.md](TERRAFORM_PROVISIONING.md#troubleshooting)
- **Kubernetes problems:** [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md#troubleshooting)
- **Secret issues:** [VAULT_SECRETS.md](VAULT_SECRETS.md#troubleshooting)
- **CI/CD problems:** [JENKINS_CICD.md](JENKINS_CICD.md#troubleshooting)

---

## 🔗 Related Documents

- **Project overview:** [../../README.md](../../README.md)
- **Project structure:** [../../PROJECT_STRUCTURE.md](../../PROJECT_STRUCTURE.md)
- **Architecture:** [../../docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- **Kubernetes guide:** [../../k8s/README.md](../../k8s/README.md)
- **Production checklist:** [../../PRODUCTION_CHECKLIST.md](../../PRODUCTION_CHECKLIST.md)

---

## ✅ Setup Validation

After each phase, run validation:

```bash
# After local setup
bash infra/tools/validate-local.sh

# After bootstrap
bash infra/tools/validate-bootstrap.sh

# After provisioning
bash infra/tools/validate-provisioning.sh

# After deployment
bash infra/tools/validate-deployment.sh
```

---

**Choose your path above and follow the step-by-step guide. ⬆️**
