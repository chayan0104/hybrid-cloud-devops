# Setup and Deployment Guide

This guide covers Local Development, UAT deployment, and PROD deployment for the hybrid model:

- Frontend app: Angular + Nginx container
- Main app: Java WAR on Tomcat
- Microservice: Spring Boot on Kubernetes
- Infra: Terraform on AWS
- Secrets: Vault
- CI/CD: Jenkins
- Database: PostgreSQL

## 1. Local Development

```bash
cp applications/.env.example applications/.env
cd applications
docker compose up -d --build
```

If you also plan to run the full local CI/UAT toolchain on the same machine with WSL2, Docker Desktop, Jenkins, SonarQube, PostgreSQL, registry, VS Code, and Chrome:

- Plan for 11-14 GB total RAM usage
- Keep 2-3 GB RAM headroom available
- 16 GB RAM is the recommended baseline

Detailed sizing is documented in `UAT-LOCAL-REPLICATION-WSL.md`.

Verify:

```bash
curl http://localhost:9093/microservice/api/status
curl http://localhost:9093/microservice/api/orders/1
curl http://localhost:9092/monolith/api/customer/1
curl http://localhost:9092/monolith/api/customer-summary/1
curl http://localhost:9091/

# Swagger
open http://localhost:9092/monolith/swagger
open http://localhost:9093/microservice/swagger-ui.html
```

## 2. UAT Deployment

```bash
kubectl apply -f infra/kubernetes/uat/
sed "s|__MICROSERVICE_IMAGE__|your-registry.io/microservice:uat-v1|g" \
  infra/kubernetes/uat/microservice-deployment.yaml | kubectl apply -f -
kubectl rollout status deployment/microservice -n enterprise-uat
```

Deploy monolith WAR to UAT Tomcat:

```bash
bash infra/scripts/deploy-war.sh \
  applications/monolith/target/monolith.war \
  ubuntu@uat-tomcat.internal \
  /opt/tomcat/webapps
```

Deploy frontend container to UAT Kubernetes:

```bash
sed "s|__FRONTEND_IMAGE__|your-registry.io/frontend-angular:uat-v1|g" \
  infra/kubernetes/uat/frontend-deployment.yaml | kubectl apply -f -
kubectl apply -f infra/kubernetes/uat/frontend-service.yaml
```

Helm option for microservice:

```bash
helm upgrade --install microservice-uat infra/helm/charts/microservice \
  -f infra/helm/values/uat-microservice.yaml \
  --namespace enterprise-uat --create-namespace
```

## 3. PROD Deployment

Provision AWS:

```bash
cd infra/terraform/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 4. PERF-PROD Deployment

```bash
cd infra/terraform/perf-prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Deploy PROD workloads:

```bash
kubectl apply -f infra/kubernetes/prod/
sed "s|__MICROSERVICE_IMAGE__|your-registry.io/microservice:prod-v1|g" \
  infra/kubernetes/prod/strategies/microservice-canary-deployment.yaml | kubectl apply -f -
kubectl rollout status deployment/microservice-canary -n enterprise-prod
```

Promote stable:

```bash
sed "s|__MICROSERVICE_IMAGE__|your-registry.io/microservice:prod-v1|g" \
  infra/kubernetes/prod/microservice-deployment.yaml | kubectl apply -f -
kubectl scale deployment/microservice-canary --replicas=0 -n enterprise-prod
```

Blue-green option:

```bash
kubectl apply -f infra/kubernetes/prod/strategies/microservice-blue-deployment.yaml
kubectl apply -f infra/kubernetes/prod/strategies/microservice-green-deployment.yaml
kubectl apply -f infra/kubernetes/prod/strategies/microservice-active-service.yaml
```

## 5. CI/CD Pipelines

- `../infra/jenkins/Jenkinsfile-CI`
- `../infra/jenkins/Jenkinsfile-UAT`
- `../infra/jenkins/Jenkinsfile-PROD`

Features:

- CI builds all apps, runs Dockerized Trivy scans, pushes to JFrog
- UAT deploys monolith WAR to Tomcat and deploys frontend + microservice via Kubernetes YAML image substitution
- PROD deploys monolith WAR to EC2 Tomcat and deploys frontend + microservice to EKS via Kubernetes YAML image substitution
- All pipelines generate `reports/**`, archive them, and send email notifications via `emailext`

Jenkins plugin requirement:

- Email Extension Plugin (`emailext`)

## 6. Monitoring

- Prometheus/Grafana/Alertmanager: `../infra/monitoring/prometheus-grafana-alertmanager`
- New Relic: `../infra/monitoring/newrelic/setup.md`

## 7. Documentation

- Infra master guide: `../infra/INFRASTRUCTURE.md`
- Infra navigation: `../infra/setup.md`
- Vault setup: `../infra/vault/VAULT_SETUP.md`
- Local UAT replication on WSL2: `UAT-LOCAL-REPLICATION-WSL.md`
