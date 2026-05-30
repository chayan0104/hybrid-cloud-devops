# Infrastructure and Deployment Guide

This repo uses a hybrid delivery model that is simple to operate and production-grade in controls.

## Runtime model

- UAT
  - Frontend app deployed as Angular + Nginx container in Kubernetes (`enterprise-uat`)
  - Main app deployed as WAR to standalone Tomcat Linux VM
  - Microservice deployed as container image to Kubernetes namespace `enterprise-uat`
- PROD
  - Frontend app deployed as Angular + Nginx container in EKS (`enterprise-prod`)
  - Main app on EC2-hosted Tomcat behind ALB
  - Microservice on EKS namespace `enterprise-prod`
  - RDS PostgreSQL backend
- PERF-PROD
  - Same as PROD topology for testing release and scaling behavior
  - Dedicated namespace `enterprise-perf-prod`

## Release strategies

- Rolling: default deployment replacement in Kubernetes
- Canary: deploy `microservice-canary`, validate, then promote stable
- Blue-Green: deploy `microservice-blue` and `microservice-green`, switch `microservice-active` service selector
- Helm: optional path for microservice only

## Setup sequence

## Phase 1: Bootstrap

1. Create Terraform remote state backend.
2. Initialize Vault and configure Jenkins AppRole.
3. Seed UAT and PROD secret paths.

Commands:

```bash
cd infra/terraform/bootstrap-state
terraform init && terraform apply

cd ../../vault
bash vault-secrets-setup.sh
```

## Phase 2: Provision cloud

```bash
cd infra/terraform/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output
```

Perf-prod stack:

```bash
cd infra/terraform/perf-prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

PROD stack composition:

- Reusable Terraform modules for network, security, EC2 Tomcat, ALB, EKS, and RDS
- Output includes ALB DNS, EKS cluster name, and RDS endpoint

## Phase 3: Kubernetes deployment

UAT:

```bash
kubectl apply -f infra/kubernetes/uat/
```

PROD:

```bash
kubectl apply -f infra/kubernetes/prod/
```

Blue-Green resources:

```bash
kubectl apply -f infra/kubernetes/prod/deployment-blue.yaml
kubectl apply -f infra/kubernetes/prod/deployment-green.yaml
kubectl apply -f infra/kubernetes/prod/service-active.yaml
```

Helm option:

```bash
helm upgrade --install microservice-prod infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-prod --create-namespace
```

## Phase 4: Monitoring

```bash
cd infra/monitoring/prometheus-grafana-alertmanager
docker compose -f docker-compose.monitoring.yml up -d
```

New Relic (optional):

```bash
cd infra/monitoring/newrelic
cp .env.example .env
docker compose -f docker-compose.uat.yml up -d
```

## Phase 5: Jenkins pipelines

Create 3 jobs pointing to:

- `infra/jenkins/Jenkinsfile-CI`
- `infra/jenkins/Jenkinsfile-UAT`
- `infra/jenkins/Jenkinsfile-PROD`

Pipeline capabilities:

- CI: builds frontend and microservice images, builds `main-app.war`, scans, publishes to JFrog
- UAT: YAML-based deploy and YAML-based rollback by image substitution
- PROD: YAML-based rolling/canary/blue-green deploy and YAML-based rollback by previous image
- Notifications: all Jenkins pipelines send email summaries with attached reports/logs using `emailext`

## Security defaults

- Secrets are centralized in Vault and read by pipelines at runtime for all environments.
- K8s has readiness/liveness probes and HPA.
- PROD uses manual approval plus canary or blue-green promotion.
- Terraform is the source of truth for AWS resources.

## Operational checklist

- ALB DNS healthy
- Stable microservice pods >= 2
- Canary deployment validated before promotion
- RDS connectivity verified
- Alertmanager and Grafana reachable
- Rollback command tested

## Database integration baseline

- PostgreSQL schema seed: `infra/database/init-scripts/01-init.sql`
- Includes `customers` and `orders` tables with bootstrap rows.
- Microservice endpoint `GET /api/orders/{customerId}` reads order data from PostgreSQL.
- Monolith endpoint `GET /main-app/api/customer-summary/{customerId}` merges customer + order data.

## Local replication

For WSL2 + local Jenkins + Docker scans + JFrog + UAT parity setup, use:

- `docs/UAT-LOCAL-REPLICATION-WSL.md`

## Jenkins reporting and email

- CI reports: Trivy scan outputs and build summary under `reports/`
- UAT reports: pod snapshot and main-app to microservice bridge output
- PROD reports: pod snapshot and main-app to microservice bridge output
- Each pipeline archives `reports/**` and emails status, build URL, and attachments