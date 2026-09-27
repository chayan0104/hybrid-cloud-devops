# Hybrid Cloud DevOps Reference Project

> A portfolio-style hybrid cloud delivery project demonstrating modern DevOps practices across local development, containerization, CI/CD automation, Kubernetes deployment, and AWS infrastructure as code.

## Overview

This repository brings together multiple application and infrastructure layers into a single reference environment:

- Angular frontend application
- Java-based monolith packaged as a WAR
- Spring Boot microservice with REST APIs
- MySQL persistence across local and cloud environments
- Jenkins pipelines for CI and deployment stages
- Kubernetes manifests for UAT and production patterns
- Terraform modules for AWS provisioning and environment setup

This project is designed to showcase real-world infrastructure patterns and DevOps execution flow. It is a strong interview and portfolio project, but it is intentionally documented as a reference implementation rather than a fully production-certified platform.

## Architecture at a glance

| Environment | Runtime | Data layer | Delivery status |
|---|---|---|---|
| Local | Docker Compose: Angular, monolith, microservice | MySQL container | Runnable locally |
| UAT | Kubernetes namespace `enterprise-uat` | External MySQL | Deployment pipeline configured |
| PROD | EKS frontend + microservice; monolith remains on WebLogic/EC2 | MySQL RDS | Partially automated |
| Lab stack | Separate `infra/k8s/` reference bundle | MySQL | Reference only |

The single-namespace bundle in `infra/k8s/` is a separate learning stack. The active deployment work is driven by the environment-specific manifests in `infra/kubernetes/`.

## Quick start

### Local development

Prerequisites: Docker Desktop or Docker Engine with Compose enabled.

```bash
cd applications
docker compose up -d --build
```

Then access the app:

- Frontend: `http://localhost:9091`
- Monolith health: `http://localhost:9092/monolith/health`
- Microservice health: `http://localhost:9093/microservice/actuator/health`

Sample checks:

```bash
curl http://localhost:9092/monolith/health
curl http://localhost:9093/microservice/actuator/health
curl http://localhost:9093/microservice/api/status
curl http://localhost:9092/monolith/api/customer-summary/1
```

> Local Compose uses development-level defaults and should not be reused outside local experimentation.

## Repository structure

| Path | Purpose |
|---|---|
| `applications/` | Angular app, Java monolith, microservice, and Compose stack |
| `infra/jenkins/` | CI, UAT, and PROD Jenkins pipelines |
| `infra/kubernetes/` | Environment-specific UAT and PROD Kubernetes manifests |
| `infra/k8s/` | separate single-namespace lab/reference stack |
| `infra/terraform/` | AWS infrastructure modules and environment configurations |
| `infra/database/` | MySQL init scripts and schema setup |
| `infra/vault/` | Vault policies and setup helpers |
| `infra/monitoring/` | Prometheus, Grafana, Alertmanager, and observability examples |
| `docs/` | Architecture, deployment, interview, and operational notes |

## Delivery flow

1. `Jenkinsfile-CI` builds the frontend and Java artifacts, scans them, tags images with the Jenkins build number, and publishes them to JFrog Artifactory.
2. `Jenkinsfile-UAT` applies the UAT deployment manifests to Kubernetes and validates health and rollout expectations.
3. `Jenkinsfile-PROD` deploys the frontend and microservice to EKS, while the Java WAR remains outside the automated EKS path and is handled separately.

Required pipeline configuration includes JFrog and environment-specific credential values documented in [infra/jenkins/README.md](infra/jenkins/README.md).

## Infrastructure layer

Terraform modules define reusable AWS resources, including:

- VPC and networking
- Security groups
- ALB and WebLogic EC2 resources
- EKS configuration
- MySQL RDS provisioning

Example validation flow:

```powershell
Set-Location infra/terraform/prod
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Never commit `terraform.tfvars` or real credentials to source control.

## Current status

This project demonstrates a realistic delivery pipeline and cloud architecture mindset, but is intentionally documented with clear boundaries:

- WebLogic WAR deployment is still manual
- Vault integration is not fully wired into Jenkins workflows
- Production-grade ingress, remote state, and secret hardening still need follow-through
- This is a portfolio/reference implementation, not a fully production-certified deployment

## Project documentation

- [Architecture and current implementation status](docs/ARCHITECTURE.md)
- [Setup and deployment guide](docs/SETUP-AND-DEPLOYMENT-GUIDE.md)
- [Infrastructure and operations](docs/INFRASTRUCTURE.md)
- [Interview preparation notes](docs/INTERVIEW.md)
- [WSL2 UAT replication guide](docs/UAT-LOCAL-REPLICATION-WSL.md)
- [Jenkins pipeline documentation](infra/jenkins/README.md)
- [Known work items and backlog](docs/todo.md)

## Interview positioning

When discussing this project in interviews, frame it as a realistic DevOps portfolio project that shows breadth across:

- application packaging and runtime flow
- environment separation and deployment strategy
- infrastructure-as-code and cloud design
- automation and operations discipline
- security, configuration, and deployment awareness

Be explicit about what is implemented versus what remains a future hardening step. That distinction makes the project sound more credible and professional.
