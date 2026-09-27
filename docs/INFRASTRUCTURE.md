# Infrastructure and Operations

This guide describes implemented infrastructure assets and the configuration still required to operate them. A checked-in manifest or Terraform module is not evidence that a live environment has been deployed.

## Source of Truth

| Concern | Repository location | Current role |
|---|---|---|
| Local application | `applications/docker-compose.yml` | Angular, Java monolith, Spring Boot microservice, and MySQL |
| UAT workloads | `infra/kubernetes/uat/` | Three application workloads in `enterprise-uat` |
| PROD workloads | `infra/kubernetes/prod/` | Frontend and microservice in `enterprise-prod`; monolith manifests are not applied by PROD Jenkins |
| Kubernetes lab | `infra/k8s/` | Separate single-namespace reference bundle; not used by UAT/PROD jobs |
| AWS infrastructure | `infra/terraform/` | VPC, security groups, ALB, WebLogic EC2, EKS, MySQL RDS |
| CI/CD | `infra/jenkins/` | Builds/scans/publishes images and deploys UAT/PROD Kubernetes workloads |
| Database schema | `infra/database/init-scripts/` | MySQL schema and sample data |
| WebLogic helper | `infra/scripts/deploy-war.sh` | Manual SSH-based WAR copy/restart helper |

## Jenkins Configuration

Configure the following values in Jenkins. Do not put credentials in pipeline parameters or repository files.

Global environment:

- `JFROG_SERVER`: registry hostname only, without `https://`
- `JFROG_DOCKER_REPO`: JFrog Docker repository key

Credentials:

- `jfrog-creds`: username/password with image push and pull permission
- `uat-mysql-credentials`: UAT MySQL username/password
- `prod-mysql-credentials`: PROD MySQL username/password
- `sonarqube-token`: SonarQube token for CI

The `Jenkinsfile-UAT` job also requires `IMAGE_TAG`, `DB_HOST`, `DB_PORT`, and `DB_NAME`. The `Jenkinsfile-PROD` job additionally requires `MONOLITH_UPSTREAM`, the WebLogic ALB URL including scheme. CI tags images with the Jenkins build number; deploy that exact tag.

Pipeline secret retrieval from Vault is not implemented. Vault setup and policies exist under `infra/vault/`, but the current jobs use Jenkins credentials. Rendered database Secrets exist temporarily in the workspace during deployment; ensure workspace isolation and cleanup.

## Terraform

PROD and PERF-PROD compose reusable modules. MySQL RDS is private and allows port 3306 only from the WebLogic and EKS security groups.

The environment stacks currently have no remote backend configuration. Terraform state is local by default and includes the RDS password. Before shared or production use, configure encrypted remote state with locking/access control and rotate any secret that may have been stored in local state.

Review `terraform.tfvars.example` before copying it to a local `terraform.tfvars`. The example contains placeholder account/IAM values and is not deployable as-is.

## Kubernetes and Routing

UAT and PROD Jenkins jobs use environment-specific YAML under `infra/kubernetes/`. The frontend Nginx container proxies `/monolith/` and `/microservice/` to configured upstreams. PROD requires the WebLogic ALB URL at deploy time.

The repository does not configure a public EKS ingress/load balancer for the frontend. The Terraform ALB target group is wired to WebLogic, not to the EKS frontend. Production access to the frontend therefore remains an infrastructure task.

The `infra/k8s/` directory is a separate single-namespace lab stack; avoid applying it to the production cluster.

## CI and Release Controls

CI builds the Angular bundle, monolith WAR/container, and microservice container, runs code/dependency/IaC/image scans, and publishes container images to JFrog. The WAR is archived in Jenkins rather than published to a JFrog generic repository.

Some scan commands are report-only (`|| true` or Trivy `--exit-code 0`). Treat reports as advisory until explicit severity thresholds and fail-build behavior are agreed. The PROD pipeline deploys EKS services and checks microservice health; the WebLogic WAR is a separate manual deployment.

## Monitoring

Prometheus, Grafana, Alertmanager, New Relic, and Kubernetes alert examples live under `infra/monitoring/` and `infra/k8s/monitoring/`. They are configuration examples; central log aggregation and live alert delivery are not established by these files alone.

## Operational Checks

```bash
docker compose -f applications/docker-compose.yml config
kubectl config current-context
kubectl get all -n enterprise-uat
kubectl get all -n enterprise-prod
terraform -chdir=infra/terraform/prod validate
```

Use the correct Kubernetes context before any apply or rollback. Review Terraform plans and state handling before provisioning resources that can incur cost.