# Setup and Deployment Guide

This guide explains how the repository is structured and how the current implementation is expected to run across local, UAT, and production-style environments.

> Cloud deployment requires AWS, Jenkins, JFrog, MySQL, and Kubernetes configuration that is intentionally not stored in this repository.

## Quick navigation

- [Local development](#local-development)
- [UAT deployment](#uat-deployment)
- [Production-style deployment](#production-style-deployment)
- [Terraform and state handling](#terraform-and-state-handling)
- [CI notes](#ci-notes)

## Local development

### Prerequisites

- Docker Desktop or Docker Engine
- Docker Compose enabled

### Start the stack

```powershell
Set-Location applications
Copy-Item .env.example .env
docker compose up -d --build
```

### Validate the services

```powershell
curl.exe -fsS http://localhost:9091/
curl.exe -fsS http://localhost:9092/monolith/health
curl.exe -fsS http://localhost:9093/microservice/actuator/health
curl.exe -fsS http://localhost:9093/microservice/api/status
curl.exe -fsS http://localhost:9092/monolith/api/customer-summary/1
```

The frontend uses same-origin paths such as `/monolith` and `/microservice`. Nginx handles the proxy routing and keeps the browser from directly depending on raw backend hostnames.

### Useful local commands

```powershell
docker compose logs -f
docker compose down
```

> The `.env` file is optional for local defaults, and the embedded credentials are intended only for development use.

## UAT deployment

The pipeline in `infra/jenkins/Jenkinsfile-UAT` deploys the frontend, monolith, and microservice to the `enterprise-uat` namespace. Before running it, make sure the Kubernetes context and required Jenkins credentials are configured.

### Required values

- `IMAGE_TAG`: a unique CI build tag, typically the Jenkins build number
- `DB_HOST`, `DB_PORT` (`3306`), and `DB_NAME` (`app_db`)
- Jenkins credentials: `uat-mysql-credentials` and `jfrog-creds`
- Global Jenkins env values: `JFROG_SERVER` and `JFROG_DOCKER_REPO`

The job renders temporary Kubernetes Secret files, applies the manifests from `infra/kubernetes/uat/`, waits for rollouts, and validates the app endpoints. Vault fetching is not part of the current pipeline.

## Production-style deployment

The AWS stack should only be provisioned after reviewing cost, IAM permissions, data protection, and state security. The repository currently does not define a production-grade remote Terraform backend.

### Terraform validation pattern

```powershell
Set-Location infra/terraform/prod
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with approved account-specific values; never commit it.
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

The Terraform configuration creates a private MySQL instance and database named `app_db`.

### Jenkins production flow

`infra/jenkins/Jenkinsfile-PROD` deploys the frontend and microservice manifests from `infra/kubernetes/prod/` to EKS. Required inputs include:

- `IMAGE_TAG` from CI
- `MONOLITH_UPSTREAM`: the WebLogic URL used by Nginx as the monolith origin
- `DB_HOST`, `DB_PORT` (`3306`), and `DB_NAME` (`app_db`)
- Jenkins credentials: `prod-mysql-credentials` and `jfrog-creds`
- Global environment values: `JFROG_SERVER` and `JFROG_DOCKER_REPO`

The pipeline waits for rollout success and probes `/microservice/actuator/health`. It does not automatically deploy the WAR to WebLogic.

### Manual WebLogic deployment path

CI archives the WAR artifact, and the separate script below is the existing deployment helper:

```bash
infra/scripts/deploy-war.sh applications/monolith/target/monolith.war user@weblogic-host /path/to/domain/autodeploy
```

This process assumes SSH access and a compatible WebLogic service setup. Use it only after verifying the target server, deployment path, and operational procedure.

## Terraform and state handling

### Environment manifests

`infra/k8s/` is a separate, single-namespace reference stack and is not the active UAT or PROD pipeline path. For real environment deployment, use the manifests under:

- `infra/kubernetes/uat/`
- `infra/kubernetes/prod/`

### State security

The AWS and database layers are intentionally designed to show platform patterns, but they still require production hardening:

- encrypt Terraform state
- control remote state access carefully
- keep database credentials out of source control
- apply real IAM boundaries before reuse outside a lab context

## CI notes

The CI process builds:

- Angular bundle
- monolith WAR or container image
- Spring Boot microservice image

The images are tagged using the Jenkins build number and pushed to JFrog Artifactory. The WAR artifact is archived in Jenkins rather than being published to a generic repository. Some security scan steps currently report findings without failing the build.

## Final note

This repository demonstrates solid DevOps thinking across build, deploy, cloud infrastructure, and environment operations. It is best positioned as a professional portfolio project and a realistic reference implementation rather than a production-certified deployment system.
