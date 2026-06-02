# DevOps Interview Guide

This guide is tailored for DevOps interviews based on this repository.

## 1. Platform Summary

- UAT runtime:
  - `monolith.war` on Tomcat Linux VM
  - `frontend` and `microservice` on Kubernetes namespace `enterprise-uat`
- PROD runtime:
  - ALB -> EC2 Tomcat (`monolith.war`)
  - `frontend` and `microservice` on EKS namespace `enterprise-prod`
  - PostgreSQL on RDS
- PERF-PROD runtime:
  - Same topology as PROD for validation

## 2. DevOps QnA

1. How are secrets managed?
   - Vault is the centralized source (`secret/shared`, `secret/uat`, `secret/prod`, `secret/perf-prod`).

2. How are DB credentials injected into workloads?
   - Jenkins renders per-app Kubernetes `Secret` manifests at deploy time and applies them to the target namespace.

3. How is deployment done for microservice?
   - YAML-based image substitution (`__MICROSERVICE_IMAGE__`) and `kubectl apply`.

4. Which rollout strategies are supported in PROD?
   - Rolling, Canary, Blue-Green.

5. How is rollback handled?
   - Pipelines capture previous image and re-apply deployment YAML with old image.

6. How are artifacts published?
   - Docker images and WAR files are published to JFrog from CI.

7. How is quality/security validated in CI?
   - Maven build/test + Trivy image and filesystem scans.

8. How are notifications handled?
   - `emailext` in CI/UAT/PROD with reports and build logs.

9. What is the Terraform model?
   - Reusable modules: `network`, `security`, `alb`, `tomcat-ec2`, `eks`, `rds`.

10. Which files define setup and architecture?
    - `../README.md`, `ARCHITECTURE.md`, `SETUP-AND-DEPLOYMENT-GUIDE.md`, `../infra/INFRASTRUCTURE.md`.

11. How do app components communicate locally?
    - Shared Docker network `enterprise_app_net` connects frontend, main app, microservice, and PostgreSQL.

12. Is there a DB interaction example?
    - Yes. `../infra/database/init-scripts/01-init.sql` seeds `customers`; endpoint `GET /api/customers` reads it.

## 3. Hands-On Tasks

1. Add a new Vault secret and expose it to microservice in UAT.
2. Rotate PostgreSQL password in Vault and redeploy without code changes.
3. Execute canary release in PROD and promote only after health validation.
4. Trigger rollback by deploying a bad image and restore previous image via YAML.
5. Add a Prometheus alert for high error rate and verify Alertmanager routing.
6. Provision PERF-PROD with Terraform and validate outputs.

## 4. Evaluation Rubric

- Deployment safety:
  - Candidate understands promotion/rollback conditions.
- Secrets discipline:
  - No credentials in repo, all sensitive values from Vault.
- IaC maturity:
  - Correct use of Terraform modules and environment inputs.
- Observability thinking:
  - Candidate can define actionable metrics and alerts.
- Incident response:
  - Candidate demonstrates fast rollback and clear validation checks.

## 5. Rapid Review Checklist

- Knows where Jenkins pipelines are (`../infra/jenkins/`)
- Knows where Kubernetes manifests are (`../infra/kubernetes/`)
- Knows where Terraform environments are (`../infra/terraform/prod`, `../infra/terraform/perf-prod`)
- Knows where Vault setup is (`../infra/vault/`)
- Knows where setup/architecture docs are (`../README.md`, `ARCHITECTURE.md`, `SETUP-AND-DEPLOYMENT-GUIDE.md`)
