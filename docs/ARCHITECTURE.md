# Architecture Overview

## Runtime Architecture

Request flow pattern:

- Browser -> Angular frontend
- Angular -> Monolith (`/main-app/api/customer/{id}`)
- Angular -> Microservice (`/api/orders/{id}`)
- Angular -> Monolith summary (`/main-app/api/customer-summary/{id}`)
- Monolith summary -> Microservice (`/api/orders/{id}`)
- Microservice -> PostgreSQL

- UAT:
  - Tomcat Linux VM runs `main-app.war`
  - Kubernetes namespace `enterprise-uat` runs `frontend` and `microservice` pods
  - PostgreSQL is consumed by microservice using Vault-injected credentials

- PROD:
  - ALB fronts EC2 Tomcat monolith tier
  - EKS namespace `enterprise-prod` runs `frontend` and `microservice` pods
  - RDS PostgreSQL backend

- PERF-PROD:
  - Same as PROD for pre-production validation

## Delivery Architecture

- CI (`Jenkinsfile-CI`): build monolith WAR + frontend/microservice images, scan via Trivy, publish to JFrog
- UAT (`Jenkinsfile-UAT`): deploy monolith WAR to Tomcat VM and frontend/microservice containers to Kubernetes
- PROD (`Jenkinsfile-PROD`): deploy monolith WAR to EC2 Tomcat and frontend/microservice containers to EKS
- All pipelines pull secrets from Vault and send email reports via `emailext`

## Infrastructure as Code

- `infra/terraform/modules/*` reusable modules:
  - network, security, tomcat-ec2, alb, eks, rds
- Environment stacks:
  - `infra/terraform/prod`
  - `infra/terraform/perf-prod`