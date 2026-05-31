# Jenkins CI/CD - Setup and Operations

Location: `infra/jenkins/`

## Files

- `Jenkinsfile-CI`: build, test, scan, publish artifacts/images
- `Jenkinsfile-UAT`: deploy frontend + microservice to K8s and monolith WAR to UAT Tomcat VM
- `Jenkinsfile-PROD`: deploy frontend + microservice to EKS and monolith WAR to EC2 Tomcat

## Required Jenkins Plugins

- Pipeline
- Git
- Credentials Binding
- Email Extension (`emailext`)

## Required Credentials

- `vault-approle` (username/password format for role id/secret id)
- `sonarqube-token` (secret text for SonarQube analysis)

## Pipeline Reports

Each pipeline generates `reports/**`, archives it, and sends email with attachments.

CI also includes:

- SonarQube analysis (monolith and microservice)
- Dependency audits (`npm audit` and OWASP dependency-check)
- IaC security scans (`tfsec` and `checkov`)
- Secret leak scanning (`gitleaks`)

## Typical Setup

1. Create 3 pipeline jobs mapped to the 3 Jenkinsfiles.
2. Ensure agent has Docker, kubectl, helm, vault, java, maven, node.
3. Configure SMTP in Jenkins for `emailext`.
4. Trigger CI from SCM webhook, trigger UAT/PROD by release flow.

## Local Host Sizing

If Jenkins is running locally on a Windows 11 + WSL2 laptop alongside Docker Desktop, SonarQube, PostgreSQL, a registry, VS Code, and Chrome:

- Expect roughly 11-14 GB total RAM usage
- Keep 2-3 GB RAM headroom free
- 16 GB RAM is the recommended baseline for a stable developer setup

For the detailed breakdown, see `../../docs/UAT-LOCAL-REPLICATION-WSL.md`.
