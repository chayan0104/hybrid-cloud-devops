# Hybrid Cloud DevOps Architecture

Production-style reference project with a simple operational model.

## Components

- `applications/frontend-angular`: Angular frontend application
- `applications/monolith`: Java monolith WAR for Tomcat
- `applications/microservice`: Spring Boot microservice
- `infra/kubernetes`: UAT and PROD manifests
- `infra/terraform`: reusable AWS modules (Network, Security, ALB, EC2 Tomcat, EKS, RDS)
- `infra/terraform/perf-prod`: performance/parallel prod-like environment using same modules
- `infra/jenkins`: CI and deployment pipelines
- `infra/vault`: Vault policy and secret setup
- `infra/helm`: Helm chart for microservice rollout option
- `infra/monitoring`: Prometheus, Alertmanager, Grafana, New Relic

## Environment model

- LOCAL: Angular + Nginx container, monolith Tomcat container, microservice container, PostgreSQL container via Docker Compose
- UAT: frontend Angular + Nginx in Kubernetes, monolith on standalone Tomcat Linux VM, microservice in Kubernetes, PostgreSQL server
- PROD: frontend Angular + Nginx in EKS, monolith on EC2 Tomcat, microservice in EKS, PostgreSQL on RDS
- PERF-PROD: PROD-like topology for validation, using same Terraform modules

## Local Ports and APIs

- Frontend: `http://localhost:9091`
- Monolith: `http://localhost:9092/monolith`
- Microservice: `http://localhost:9093/microservice`

Sample API checks:

- `GET /monolith/api/customer/1` via monolith
- `GET /microservice/api/orders/1` via microservice
- `GET /monolith/api/customer-summary/1` monolith -> microservice aggregation

Swagger:

- Monolith Swagger UI: `http://localhost:9092/monolith/swagger`
- Microservice Swagger UI: `http://localhost:9093/microservice/swagger-ui.html`

## Setup Guidance

1. Start with `docs/SETUP-AND-DEPLOYMENT-GUIDE.md`.
2. Follow infra details in `infra/INFRASTRUCTURE.md`.
3. Use `docs/UAT-LOCAL-REPLICATION-WSL.md` for local UAT parity.
4. Use `docs/INTERVIEW.md` for QnA and practical validation exercises.

## Start here

- Full setup: `docs/SETUP-AND-DEPLOYMENT-GUIDE.md`
- Architecture: `docs/ARCHITECTURE.md`
- Infra master guide: `infra/INFRASTRUCTURE.md`
- Infra navigation: `infra/setup.md`
- WSL2 UAT replication: `docs/UAT-LOCAL-REPLICATION-WSL.md`