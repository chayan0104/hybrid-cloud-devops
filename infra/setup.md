# Infrastructure Navigation Hub

Start here if you are working in `infra/`.

## Primary docs

- Master guide: `INFRASTRUCTURE.md`
- Full setup flow: `../docs/SETUP-AND-DEPLOYMENT-GUIDE.md`

## By area

- Vault: `vault/VAULT_SETUP.md`
- Terraform: `terraform/prod`, `terraform/perf-prod`, `terraform/modules/{network,security,alb,tomcat-ec2,eks,rds}`, `terraform/bootstrap-state`
- Kubernetes UAT: `kubernetes/uat/`
- Kubernetes PROD: `kubernetes/prod/`
- Kubernetes PERF-PROD: `kubernetes/perf-prod/`
- Helm chart (microservice): `helm/charts/microservice` with values in `helm/values/`
- Jenkins pipelines: `jenkins/Jenkinsfile-*`
- Monitoring: `monitoring/prometheus`, `monitoring/alertmanager`, `monitoring/newrelic`, `monitoring/prometheus-grafana-alertmanager`
- Preflight and tooling matrix: `scripts/preflight-check.sh`, `scripts/TOOLING-READINESS-MATRIX.md`
- Local UAT replication: `../docs/UAT-LOCAL-REPLICATION-WSL.md`

## Fast sequence

1. Bootstrap Terraform state (`terraform/bootstrap-state`)
2. Configure Vault AppRole and seed secrets
3. Provision PROD stack (`terraform/prod`)
4. Apply K8s manifests (`kubernetes/uat`, `kubernetes/prod`)
5. Deploy microservice manifests to UAT/PROD Kubernetes
6. Run Jenkins pipelines for CI -> UAT -> PROD