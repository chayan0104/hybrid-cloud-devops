# Infra Scripts

Location: `infra/scripts/`

## Scripts

- `deploy-war.sh`: deploy WAR to remote Tomcat and restart service
- `rollback-microservice.sh`: rollout undo helper for Kubernetes deployment
- `preflight-check.sh`: validates required CLIs, scanner images, env vars, and repo paths
- `TOOLING-READINESS-MATRIX.md`: readiness checklist and expected tooling/capabilities

## Usage

```bash
bash infra/scripts/deploy-war.sh applications/monolith/target/monolith.war ubuntu@host /opt/tomcat/webapps

bash infra/scripts/rollback-microservice.sh enterprise-uat microservice

bash infra/scripts/preflight-check.sh

STRICT_ENDPOINT_CHECKS=true \
VAULT_ADDR=https://vault.company.com:8200 \
SONAR_HOST_URL=https://sonarqube.company.com \
bash infra/scripts/preflight-check.sh
```