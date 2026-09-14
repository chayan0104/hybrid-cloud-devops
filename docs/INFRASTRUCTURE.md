# Infrastructure and Operations Guide

This page consolidates the main infrastructure, platform, and deployment operational guidance for the project.

## 1. Environment model

The repository supports a hybrid deployment model across local, UAT, and production environments:

- Local: Docker Compose for application components
- UAT: Kubernetes + WebLogic VM workloads, Jenkins-driven deployment
- PROD: AWS infrastructure via Terraform + Kubernetes/EKS + EC2 + RDS
- PERF-PROD: pre-production validation environment using the same patterns as PROD

## 2. Infrastructure as Code

Terraform is the canonical infrastructure provisioning mechanism for AWS resources.

Common modules:

- `infra/terraform/modules/network`
- `infra/terraform/modules/security`
- `infra/terraform/modules/alb`
- `infra/terraform/modules/weblogic-ec2`
- `infra/terraform/modules/eks`
- `infra/terraform/modules/rds`

Environment stacks:

- `infra/terraform/prod`
- `infra/terraform/perf-prod`
- `infra/terraform/bootstrap-state`

Typical flow:

```bash
cd infra/terraform/prod
terraform init
terraform plan
terraform apply
```

## 3. Kubernetes and deployment manifests

The app stack is represented in the consolidated manifests under:

- `k8s/`
- `infra/kubernetes/` (legacy/reference)
- `infra/helm/` and `infra/helm/charts/` (Helm-based deployment options)

Core deployment resources include:

- namespace
- configmaps
- ingress
- frontend
- monolith
- microservice
- PostgreSQL
- monitoring resources

Example:

```bash
kubectl apply -f k8s/
kubectl rollout status deployment/microservice -n enterprise-app
```

## 4. Secrets and Vault

HashiCorp Vault is used for environment and app secrets instead of storing credentials in the repository.

Key areas:

- `infra/vault/VAULT_SETUP.md`
- `infra/vault/vault-policies.hcl`
- `infra/vault/vault-secrets-setup.sh`

Common pattern:

- Store shared and environment-specific secret paths in Vault
- Inject credentials at deploy time into Kubernetes secrets or runtime config
- Keep sensitive values out of Git and manifests

## 5. CI/CD and Jenkins

The project includes Jenkins pipelines for multi-stage delivery:

- `infra/jenkins/Jenkinsfile-CI`
- `infra/jenkins/Jenkinsfile-UAT`
- `infra/jenkins/Jenkinsfile-PROD`

CI responsibilities:

- build frontend, monolith, and microservice artifacts
- run code and image security scans
- publish Docker images and WARs to the registry/artifact store

UAT and PROD responsibilities:

- deploy application images or artifacts to the correct runtime
- validate health and rollout status
- support rollback to a prior image/version

## 6. Monitoring and observability

Monitoring resources are organized under:

- `infra/monitoring/`
- `infra/monitoring/prometheus/`
- `infra/monitoring/alertmanager/`
- `infra/monitoring/newrelic/`

Typical stack:

- Prometheus for metrics collection
- Alertmanager for notification routing
- Grafana for dashboards
- New Relic for optional APM/integration

## 7. Local bootstrap and Docker setup

For local development and a laptop UAT-style laboratory:

```bash
cd applications
docker compose up -d --build
```

For a full local stack with Jenkins + Docker + Kind + WSL2:

```bash
sudo apt update
sudo apt install -y curl git jq unzip openjdk-17-jdk maven
```

Additional setup references:

- `infra/tools/DOCKER_LOCAL_SETUP.md`
- `infra/tools/BOOTSTRAP.md`
- `infra/scripts/TOOLING-READINESS-MATRIX.md`

## 8. Operations checklist

- Validate Terraform state and environment variables before apply
- Ensure Vault access and policies are ready before deployment
- Verify Docker images, tags, and registry auth for CI/CD
- Run health checks after each promotion
- Prepare rollback procedures before deploying to PROD
- Keep monitoring and alert thresholds reviewed for service level risk

## 9. Where to look next

- [README.md](../README.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [SETUP-AND-DEPLOYMENT-GUIDE.md](SETUP-AND-DEPLOYMENT-GUIDE.md)
