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

Deploy all components (Kubernetes manifests consolidation):

```bash
# Apply entire Kubernetes stack (namespace, configs, postgres, frontend, monolith, microservice, ingress)
kubectl apply -f k8s/

# Wait for deployments to be ready
kubectl rollout status deployment/microservice -n enterprise-app
kubectl rollout status deployment/frontend -n enterprise-app
kubectl rollout status deployment/monolith -n enterprise-app
kubectl rollout status deployment/postgres -n enterprise-app
```

With image substitution (via Jenkins):

```bash
# Substitute real image URIs before applying
sed "s|__MICROSERVICE_IMAGE__|your-registry.io/microservice:uat-v1|g" \
  k8s/microservice/deployment.yaml | kubectl apply -f -
sed "s|__FRONTEND_IMAGE__|your-registry.io/frontend-angular:uat-v1|g" \
  k8s/frontend/deployment.yaml | kubectl apply -f -
sed "s|__MONOLITH_IMAGE__|your-registry.io/monolith:uat-v1|g" \
  k8s/monolith/deployment.yaml | kubectl apply -f -
```

Port forwarding for testing:

```bash
kubectl port-forward -n enterprise-app svc/frontend 8080:80
kubectl port-forward -n enterprise-app svc/monolith 8082:80
kubectl port-forward -n enterprise-app svc/microservice 8081:80
```

Helm option for microservice (legacy, optional):

```bash
helm upgrade --install microservice-uat infra/helm/charts/microservice \
  -f infra/helm/values/uat-microservice.yaml \
  --namespace enterprise-app --create-namespace
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
# Apply entire Kubernetes stack
kubectl apply -f k8s/

# Wait for rollouts
kubectl rollout status deployment/microservice -n enterprise-app
kubectl rollout status deployment/frontend -n enterprise-app
kubectl rollout status deployment/monolith -n enterprise-app
```

With image substitution (via Jenkins):

```bash
# Substitute and deploy microservice
sed "s|__MICROSERVICE_IMAGE__|your-registry.io/microservice:prod-v1|g" \
  k8s/microservice/deployment.yaml | kubectl apply -f -

# Deploy frontend  
sed "s|__FRONTEND_IMAGE__|your-registry.io/frontend-angular:prod-v1|g" \
  k8s/frontend/deployment.yaml | kubectl apply -f -

# Deploy monolith
sed "s|__MONOLITH_IMAGE__|your-registry.io/monolith:prod-v1|g" \
  k8s/monolith/deployment.yaml | kubectl apply -f -
```

Helm option for microservice (legacy, optional):

```bash
helm upgrade --install microservice-prod infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-app --create-namespace
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
