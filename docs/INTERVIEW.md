# DevOps Interview Preparation

## Project Summary

This portfolio project demonstrates a hybrid delivery model for a small customer/orders application. Angular is served by Nginx, a Java WAR monolith owns customer endpoints, and a Spring Boot microservice owns order/status endpoints. MySQL is used locally and in the AWS Terraform model. Jenkins builds/scans images, publishes to JFrog, deploys UAT workloads to Kubernetes, and deploys the frontend/microservice to EKS in PROD.

The production WebLogic WAR deployment remains manual, and the repository does not yet define a public EKS ingress for the frontend. Present these as known boundaries, not completed automation.

## Architecture Walkthrough

1. The browser requests the Angular UI.
2. Angular calls same-origin `/monolith/...` or `/microservice/...` endpoints.
3. Nginx proxies those paths to internal Kubernetes/Compose services; in PROD, `/monolith/` uses the configured WebLogic ALB URL.
4. The monolith summary endpoint calls the microservice; the microservice queries MySQL.

Local Compose is the runnable end-to-end environment. The Terraform model provisions a VPC, ALB, WebLogic EC2, EKS, and MySQL RDS, but no live AWS environment is included in the repository.

## Questions and Evidence-Based Answers

**How are images versioned and promoted?**
CI tags images with the Jenkins build number and pushes them to a configured JFrog Docker repository. UAT/PROD jobs receive the tag as `IMAGE_TAG`; do not deploy `latest`.

**How are secrets handled?**
Database and JFrog credentials are bound from Jenkins credentials. The deployment jobs render Kubernetes Secret manifests temporarily. Vault policies and setup files are present, but the pipelines do not retrieve secrets from Vault yet.

**How does production deployment work?**
The PROD pipeline deploys frontend and microservice workloads to `enterprise-prod`, waits for rollouts, and probes the microservice actuator health endpoint. The WebLogic WAR is archived by CI and deployed separately using the SSH helper; that stage is not automated.

**How does rollback work?**
The deployment jobs expose a rollback-only path that asks Kubernetes to undo frontend and microservice deployments (and UAT monolith). This is Kubernetes revision rollback, not a complete database or WebLogic rollback strategy.

**How is persistence configured?**
The services use MySQL JDBC. Local Compose initializes schema/data from `infra/database/init-scripts/`; Terraform provisions private MySQL RDS and the `app_db` database. Terraform state must be secured because it contains the DB password.

**What do the security scans enforce?**
CI runs SonarQube, dependency, IaC, secret, and Trivy scans. Several commands are report-only and do not fail the build, so the current pipeline does not guarantee a clean security gate.

**What remains before calling this production-ready?**
Configure a public frontend ingress and routing, secure remote Terraform state, move DB secret delivery to an approved secret manager, automate/test WebLogic deployment, make scan thresholds blocking, and validate recovery/backup procedures in a live environment.

## Troubleshooting Story

A useful example is tracing why a deployed UI would fail even while its backend pods were healthy: browser code used `localhost` URLs, which point to the end user's own machine. Replacing them with same-origin API paths and adding Nginx reverse-proxy routes makes Compose and Kubernetes service DNS usable without browser-side environment-specific hostnames.

Another example is reconciling database drift: JDBC and seed SQL were MySQL-specific while Kubernetes/Terraform declared PostgreSQL. The application path and AWS RDS settings now agree on MySQL; the separate lab bundle and cloud deployment still require full environment validation.

## Interview Guardrails

- State what runs locally versus what is only declared as infrastructure.
- Do not claim live deployment, measured availability, cost savings, or security compliance without evidence.
- Explain why immutable tags, controlled secrets, remote state, health gates, and rollback boundaries matter.
- Describe the remaining manual WebLogic path and absent public EKS ingress candidly.