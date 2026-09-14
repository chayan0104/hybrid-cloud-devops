# Hybrid Cloud DevOps Reference Architecture

**Production-grade reference project** demonstrating a modern DevOps architecture with a hybrid delivery model combining containerization, infrastructure as code, CI/CD, and cloud deployment.

## 🎯 Quick Start

**New to the project?** Get running in 5 minutes:
```bash
git clone https://github.com/your-org/hybrid-cloud-devops.git
cd hybrid-cloud-devops
cd applications && docker compose up -d --build
# Open http://localhost:9091 (frontend), http://localhost:9092 (monolith), http://localhost:9093 (microservice)
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | System design and runtime flow |
| **[docs/SETUP-AND-DEPLOYMENT-GUIDE.md](docs/SETUP-AND-DEPLOYMENT-GUIDE.md)** | Local, UAT, and PROD deployment procedures |
| **[docs/INFRASTRUCTURE.md](docs/INFRASTRUCTURE.md)** | Terraform, Jenkins, Vault, and monitoring operations |
| **[docs/UAT-LOCAL-REPLICATION-WSL.md](docs/UAT-LOCAL-REPLICATION-WSL.md)** | WSL-based local UAT runbook |
| **[docs/INTERVIEW.md](docs/INTERVIEW.md)** | Interview-ready architecture summary |
| **[docs/todo.md](docs/todo.md)** | Current work backlog and task list |

## 🏗️ Architecture Overview

### Components

```
┌──────────────────────────────────────────────────────────┐
│                    Users / Browsers                       │
└──────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────┐
│              Load Balancer / Ingress                      │
│          (ALB in PROD, Ingress in K8s)                   │
└──────────────────────────────────────────────────────────┘
              ↙              ↓              ↘
    ┌──────────────┐ ┌─────────────  ┐ ┌──────────────────┐
    │   Frontend   │ │   Monolith    │ │   Microservice   │
    │   (Angular)  │ │   (WAR)       │ │   (Spring Boot)  │
    │   K8s/EKS    │ │ Tomcat/K8s/EKS  │   K8s/EKS        │
    └──────────────┘ └───────────--──┘ └──────────────────┘
                           ↓
                    ┌──────────────┐
                    │  PostgreSQL  │
                    │   (RDS/VM)/  │
                    └──────────────┘
```

### Environment Comparison

| Layer | LOCAL | UAT | PROD |
|-------|-------|-----|------|
| **Frontend** | Container | K8s (nginx) | EKS (nginx) |
| **Monolith** | Container | Tomcat VM/K8s/EKS   | EC2 Tomcat/K8s/EKS   |
| **Microservice** | Container | K8s (Spring) | EKS (Spring) |
| **Database** | PostgreSQL Container | PostgreSQL Server | RDS |
| **Infrastructure** | Docker Compose | EC2 + K8s | EKS + EC2 + RDS + ALB |
| **Secrets** | Hardcoded (dev) | Vault | Vault |

### Deployment Pipeline

```
Source Code (applications/)
        ↓
    [CI Pipeline]
    ├─ Build images
    ├─ Scan vulnerabilities (Trivy)
    ├─ Push to registry (JFrog)
        ↓
    [UAT Pipeline]
    ├─ Deploy to UAT Kubernetes
    ├─ Run validation tests
        ↓
    [PROD Pipeline]
    ├─ Deploy to EKS + EC2
    ├─ Verify health checks
```

## 📁 Project Structure

```
hybrid-cloud-devops/
├── applications/              ← Source code (local Docker Compose)
│   ├── frontend-angular/      ← Angular SPA
│   ├── monolith/              ← Java WAR
│   └── microservice/           ← Spring Boot
├── k8s/                        ← Production Kubernetes manifests ✅ CURRENT
├── infra/
│   ├── terraform/             ← Infrastructure as Code (AWS)
│   ├── jenkins/               ← CI/CD pipelines
│   ├── vault/                 ← Secret management
│   ├── monitoring/            ← Prometheus, Grafana, New Relic
│   └── kubernetes/            ← ⚠️ DEPRECATED (use k8s/ instead)
├── docs/                       ← Comprehensive documentation
└── [Project docs]             ← This README + structure guides
```

**→ Documentation hub:** [docs](docs)

## 🚀 Key Features

### Production-Grade Kubernetes
- ✅ **Security**: RBAC, NetworkPolicies, Pod security contexts, seccomp
- ✅ **High Availability**: Pod anti-affinity, disruption budgets, multi-replicas
- ✅ **Autoscaling**: HPA (CPU/Memory) + optional VPA
- ✅ **Deployment Strategies**: Rolling updates, canary, blue-green
- ✅ **Observability**: Prometheus ServiceMonitor, PrometheusRules, alerts
- ✅ **Resource Management**: Realistic CPU/memory limits, startup probes

### Infrastructure as Code
- ✅ **Terraform Modules**: Reusable, environment-agnostic
- ✅ **Multi-Environment**: PROD, PERF-PROD, UAT, LOCAL
- ✅ **AWS Resources**: VPC, Security Groups, ALB, EKS, RDS, EC2
- ✅ **State Management**: Remote state backend with locking

### CI/CD Pipelines
- ✅ **Multi-stage**: CI → UAT → PROD
- ✅ **Automation**: Build, scan, test, deploy
- ✅ **Validation**: Health checks, smoke tests
- ✅ **Secrets**: Vault integration for sensitive data

### Observability
- ✅ **Monitoring**: Prometheus metrics + Grafana dashboards
- ✅ **Alerting**: PrometheusRules with threshold-based alerts
- ✅ **Logging**: Centralized logs via Prometheus + Grafana
- ✅ **Tracing**: Optional New Relic integration

## 🔄 Quick Commands

### Local Development
```bash
# Start local stack
cd applications && docker compose up -d --build

# Verify services
curl http://localhost:9091                      # Frontend
curl http://localhost:9092/monolith/health      # Monolith
curl http://localhost:9093/microservice/health  # Microservice

# View logs
docker compose logs -f

# Stop
docker compose down
```

### Kubernetes Deployment
```bash
# Deploy all components
kubectl apply -f k8s/

# Check status
kubectl get all -n enterprise-app
kubectl rollout status deployment/microservice -n enterprise-app

# View logs
kubectl logs -f deployment/microservice -n enterprise-app

# Port forward for local testing
kubectl port-forward -n enterprise-app svc/microservice 8081:80
```

### Infrastructure Provisioning
```bash
# Initialize Terraform
cd infra/terraform/prod
terraform init

# Plan & Apply
terraform plan
terraform apply
```

### Jenkins Deployment
Access Jenkins UI and run:
1. **Jenkinsfile-CI** → Build & scan code
2. **Jenkinsfile-UAT** → Deploy to UAT
3. **Jenkinsfile-PROD** → Deploy to PROD

## 📊 Technology Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Angular 16+, Nginx, Docker |
| **Monolith** | Java Spring, Tomcat, WAR/Docker |
| **Microservice** | Spring Boot 2.7+, Actuator |
| **Database** | PostgreSQL 15 |
| **Containers** | Docker, Docker Compose |
| **Orchestration** | Kubernetes, EKS |
| **IaC** | Terraform, AWS |
| **CI/CD** | Jenkins, Groovy |
| **Secrets** | HashiCorp Vault |
| **Monitoring** | Prometheus, Grafana, New Relic |
| **Scanning** | Trivy (container), SonarQube (code) |

## 📋 Production Checklist

- [x] Kubernetes manifests with RBAC & NetworkPolicies
- [x] Pod Disruption Budgets for HA
- [x] HPA autoscaling (CPU & memory)
- [x] Prometheus monitoring + alerts
- [x] Deployment strategies (rolling, canary, blue-green)
- [x] Vault for secrets management
- [x] Terraform IaC for infrastructure
- [x] Jenkins multi-stage CI/CD pipelines
- [x] Comprehensive documentation
- [x] Graceful shutdown & health probes
- [x] Resource requests/limits on all workloads
- [x] Regular backups (PostgreSQL)

## 🔐 Security Features

- ✅ Non-root containers with dropped capabilities
- ✅ Network policies (default deny, allow from ingress)
- ✅ RBAC with limited service account permissions
- ✅ Secrets in Vault (not in code or configs)
- ✅ TLS termination on Ingress
- ✅ Container image scanning (Trivy)
- ✅ Code scanning (SonarQube)
- ✅ Security group rules (Terraform)

## 🚨 Need Help?

| Issue | Resource |
|-------|----------|
| **Getting Started** | [QUICK_START.md](QUICK_START.md) |
| **Find Files** | [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) |
| **Common Issues** | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| **System Design** | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **Deployment Steps** | [docs/SETUP-AND-DEPLOYMENT-GUIDE.md](docs/SETUP-AND-DEPLOYMENT-GUIDE.md) |
| **Local Development** | [docs/UAT-LOCAL-REPLICATION-WSL.md](docs/UAT-LOCAL-REPLICATION-WSL.md) |
| **Q&A / Exercises** | [docs/INTERVIEW.md](docs/INTERVIEW.md) |

## 📝 Document Conventions

- 📖 **README.md**: Overview & quick reference
- 📋 **QUICK_START.md**: 5-minute setup
- 📍 **PROJECT_STRUCTURE.md**: File navigation
- 🔧 **TROUBLESHOOTING.md**: Common issues & fixes
- 📚 **docs/**: Detailed technical documentation
- 📑 **Component README.md**: Service-specific guides

## 🔄 Workflows

### 1. Local Development
```
Code → Docker Compose → http://localhost:9091/9092/9093 → Verify
```

### 2. UAT Deployment
```
Code → Jenkins CI → Jenkins UAT → Kubernetes (UAT) → Validate
```

### 3. PROD Deployment
```
Code → Jenkins CI → Jenkins PROD → EKS + EC2 + RDS → Verify Health
```

## 📈 Scaling

### Horizontal Scaling
- Frontend: HPA scales 1-5 replicas
- Microservice: HPA scales 3-10 replicas (CPU 70%, Memory 80%)
- Monolith: Manual scaling on EC2

### Vertical Scaling
- Database: RDS performance class changes
- Compute: EC2 instance type upgrades
- Memory: Kubernetes node scaling

## 🔍 Monitoring & Observability

### Metrics & Alerts
- Application metrics via Prometheus
- Infrastructure metrics from CloudWatch (AWS)
- Custom alerts via PrometheusRules
- Dashboard in Grafana

### Logs
- Kubernetes: `kubectl logs -f <pod>`
- Container: `docker compose logs -f`
- Centralized: CloudWatch Logs or ELK

### Debugging
```bash
# Pod issues
kubectl describe pod <pod-name> -n enterprise-app

# Logs
kubectl logs <pod-name> -n enterprise-app

# Exec into pod
kubectl exec -it <pod-name> -n enterprise-app -- /bin/sh

# Port forward
kubectl port-forward svc/<service> 8080:80 -n enterprise-app
```

## 🎓 Learning Resources

1. **Kubernetes**: [Official docs](https://kubernetes.io/docs/)
2. **Terraform**: [Official docs](https://www.terraform.io/docs/)
3. **Docker**: [Official docs](https://docs.docker.com/)
4. **Spring Boot**: [Official docs](https://spring.io/projects/spring-boot)
5. **Prometheus**: [Official docs](https://prometheus.io/docs/)

## 📞 Support

- **Documentation**: Start with [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- **Issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Architecture**: Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Deployment**: Follow [docs/SETUP-AND-DEPLOYMENT-GUIDE.md](docs/SETUP-AND-DEPLOYMENT-GUIDE.md)

## 📄 License

This is a reference architecture project. Use as a template for your organization's projects.

---

**Ready to start?** → [QUICK_START.md](QUICK_START.md)

**Want details?** → [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

**Having issues?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

- Full setup: `docs/SETUP-AND-DEPLOYMENT-GUIDE.md`
- Architecture: `docs/ARCHITECTURE.md`
- Infra master guide: `infra/INFRASTRUCTURE.md`
- Infra navigation: `infra/setup.md`
- WSL2 UAT replication: `docs/UAT-LOCAL-REPLICATION-WSL.md`