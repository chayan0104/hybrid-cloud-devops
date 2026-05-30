# UAT Replication on WSL2 Ubuntu with Local Jenkins

This runbook replicates the UAT delivery model on a laptop using WSL2 Ubuntu, Jenkins, Docker, KinD, Trivy scans, and JFrog publishing.

## 1. Prerequisites

- Windows 10/11 with WSL2
- Ubuntu 22.04 in WSL
- Docker Desktop with WSL integration enabled
- Java 17+, Maven 3.9+, Node 20+, kubectl, kind, helm
- JFrog account and credentials

## 2. Prepare WSL toolchain

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git jq unzip openjdk-17-jdk maven

curl -Lo ./kubectl https://dl.k8s.io/release/v1.30.4/bin/linux/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x kind && sudo mv kind /usr/local/bin/

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## 3. Create local UAT cluster

```bash
cat > ~/kind-uat.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: enterprise-uat
nodes:
  - role: control-plane
  - role: worker
EOF

kind create cluster --config ~/kind-uat.yaml
kubectl create namespace enterprise-uat
```

## 4. Start local Jenkins

```bash
docker run -d --name jenkins-local --restart unless-stopped \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts-jdk17
```

Initial password:

```bash
docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword
```

Install plugins:

- Pipeline
- Git
- Docker
- Kubernetes
- Credentials Binding
- Email Extension

## 5. Configure credentials in Jenkins

- `vault-approle` (required; pipelines load JFrog, DB, and app host secrets from Vault)
- SSH credentials for local mock UAT hosts

## 6. Run local CI with Docker-based scans

Use `../infra/jenkins/Jenkinsfile-CI`.

Features in CI:

- Builds frontend Angular container image
- Builds main-app WAR and microservice JAR
- Builds Docker images (including app-server images for local parity)
- Runs Trivy image scans in Docker containers
- Runs Trivy filesystem scan
- Publishes Docker images and WAR to JFrog

## 7. Deploy to local UAT profile

Use `../infra/jenkins/Jenkinsfile-UAT`.

- `ROLLBACK=true` to auto-rollback on failure

UAT deployment model in pipeline:

- `main-app.war` deploy to Tomcat host
- frontend and microservice deploy to Kubernetes via YAML image substitution
- microservice reads PostgreSQL credentials from Vault-backed `db-secrets`

Validate:

```bash
kubectl get all -n enterprise-uat
kubectl rollout status deployment/microservice -n enterprise-uat
curl http://localhost:8081/api/customers
```

## 8. JFrog repository layout

- Docker images: `docker-local/{microservice,main-app,frontend-angular}:<BUILD_NUMBER>`
- WAR artifacts:
  - `generic-local/main-app/main-app-<BUILD_NUMBER>.war`

## 9. Optional local New Relic

```bash
cd infra/monitoring/newrelic
cp .env.example .env
docker compose -f docker-compose.uat.yml up -d
```

## 10. Troubleshooting

- Docker permission issues in Jenkins: add Jenkins user to docker group in custom Jenkins image.
- Kube context mismatch: `kubectl config current-context` before running UAT pipeline.
- Failed scans: inspect Trivy output and patch base images or dependencies.
- JFrog push failure: verify URL format and repository permissions.