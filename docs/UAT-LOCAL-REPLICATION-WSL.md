# Local UAT Lab on WSL2

This is an optional laptop lab for running the application and a UAT-style Kubernetes cluster. It is not a production deployment guide.

## Prerequisites

- Windows 10/11 with WSL2 and Docker Desktop WSL integration
- Ubuntu in WSL2
- Docker, kind, `kubectl`, Helm, Maven, Node.js/npm, and Java 25 (the Maven projects target Java 25)
- Jenkins agent with Docker access and the tools above if running the Jenkins jobs locally
- JFrog repository and Jenkins credentials if publishing private images

Running Jenkins, SonarQube, a kind cluster, and application containers together is memory-intensive. The earlier project estimate was 11-14 GB total with 2-3 GB headroom; treat it as a planning estimate, not a measured benchmark.

## Start Local Application

```bash
cd applications
docker compose up -d --build
curl -fsS http://localhost:9091/
curl -fsS http://localhost:9092/monolith/health
curl -fsS http://localhost:9093/microservice/actuator/health
```

Compose runs MySQL and mounts `infra/database/init-scripts/` for initial schema/data creation. The database scripts execute only when the MySQL data directory is empty.

## Create a UAT Cluster

```bash
kind create cluster --name enterprise-uat
kubectl config current-context
kubectl get nodes
```

The Jenkins UAT job expects the cluster context to point to this cluster and deploys the frontend, monolith, and microservice into `enterprise-uat`.

## Jenkins Setup

Create pipeline jobs for `infra/jenkins/Jenkinsfile-CI` and `infra/jenkins/Jenkinsfile-UAT`. Configure Pipeline, Git, Credentials Binding, and Email Extension plugins, plus SMTP if email reports are needed.

Configure these Jenkins global values:

- `JFROG_SERVER`: host only, no URL scheme
- `JFROG_DOCKER_REPO`: Docker repository key

Configure credentials:

- `jfrog-creds`: JFrog username/password
- `uat-mysql-credentials`: UAT MySQL username/password
- `sonarqube-token`: SonarQube token when code scanning is enabled

Vault credentials are not consumed by these pipelines. The UAT job also needs `IMAGE_TAG` from CI plus `DB_HOST`, `DB_PORT` (3306), and `DB_NAME` (`app_db`).

## Artifacts and Validation

CI publishes frontend, monolith, and microservice container images to the configured JFrog Docker repository with the Jenkins build number as the tag. The WAR is archived in Jenkins; it is not currently uploaded to a JFrog generic repository.

Run the UAT job using that same build number, then inspect:

```bash
kubectl get pods -n enterprise-uat
kubectl rollout status deployment/frontend -n enterprise-uat
kubectl rollout status deployment/monolith -n enterprise-uat
kubectl rollout status deployment/microservice -n enterprise-uat
```

The job checks the monolith health endpoint and monolith-to-microservice bridge. Local Compose API checks are separate from the kind cluster checks; port-forward a UAT service if you need to call it from WSL.

## Troubleshooting

- Confirm Docker Desktop is running before Compose, image build, or kind operations.
- Check `kubectl config current-context` before any deployment.
- If pods cannot pull images, check the JFrog credentials and namespace `jfrog-registry` Secret.
- If database-backed endpoints fail, inspect MySQL availability, endpoint/port, and the UAT Jenkins credential.
- Treat scanner output as advisory where the pipeline uses report-only settings.