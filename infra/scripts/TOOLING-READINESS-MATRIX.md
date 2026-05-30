# Tooling Readiness Matrix

Location: `infra/scripts/`

Use this matrix before running CI/UAT/PROD pipelines.

## Runtime and CLI Requirements

| Tool | Required For | Check Command | Pass Criteria |
|---|---|---|---|
| git | CI checkout | `git --version` | returns version |
| docker | image build/scan/push | `docker --version` | returns version |
| java | Maven builds | `java -version` | Java 17+ |
| mvn | Java builds | `mvn -version` | Maven 3.9+ |
| node | frontend build | `node --version` | Node 20+ |
| npm | frontend build/audit | `npm --version` | returns version |
| kubectl | UAT/PROD deploy | `kubectl version --client` | returns version |
| helm | optional deploy mode | `helm version` | returns version |
| terraform | IaC plan/apply | `terraform version` | returns version |
| vault | secrets retrieval | `vault --version` | returns version |
| curl | health and endpoint probes | `curl --version` | returns version |

## Security Scan Tooling (Dockerized)

| Tool | Required For | Validation |
|---|---|---|
| Trivy | image/fs vulnerability scan | `docker run --rm aquasec/trivy:0.56.2 --version` |
| tfsec | Terraform misconfiguration scan | `docker run --rm aquasec/tfsec:v1.28.5 --version` |
| checkov | IaC policy scan | `docker run --rm bridgecrew/checkov:3.2.360 --version` |
| gitleaks | secret leak scan | `docker run --rm zricethezav/gitleaks:v8.21.2 version` |

## Endpoint and Service Requirements

| Endpoint | Purpose |
|---|---|
| Vault URL (`VAULT_ADDR`) | Jenkins and scripts retrieve secrets |
| SonarQube URL (`SONAR_HOST_URL`) | static analysis stage |
| JFrog URL (`secret/shared/jfrog:url`) | artifact and image publishing |
| Kubernetes API endpoint (context-based) | deploy and rollout verification |

## Credential Requirements (Jenkins)

| Credential ID | Type | Used In |
|---|---|---|
| `vault-approle` | username/password (role id/secret id) | CI, UAT, PROD |
| `sonarqube-token` | secret text | CI SonarQube stage |

## Required Repository Paths

- `infra/jenkins/Jenkinsfile-CI`
- `infra/jenkins/Jenkinsfile-UAT`
- `infra/jenkins/Jenkinsfile-PROD`
- `infra/kubernetes/uat`
- `infra/kubernetes/prod`
- `infra/terraform/prod`
- `infra/terraform/perf-prod`
- `infra/vault/vault-secrets-setup.sh`

## Run Preflight Script

```bash
bash infra/scripts/preflight-check.sh
```

Optional strict endpoint checks:

```bash
STRICT_ENDPOINT_CHECKS=true \
VAULT_ADDR=https://vault.company.com:8200 \
SONAR_HOST_URL=https://sonarqube.company.com \
bash infra/scripts/preflight-check.sh
```