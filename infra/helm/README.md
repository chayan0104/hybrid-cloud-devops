# Helm Charts - Recommended Deployment Path

Location: `infra/helm/`

## What changed

The chart is now the primary deployment path for backend workloads. It renders:

- `ConfigMap` for non-secret runtime configuration
- `ExternalSecret` for Vault-backed secret sync
- `Deployment` with rolling updates, probes, and container hardening
- `Service`
- `HorizontalPodAutoscaler`
- `PodDisruptionBudget`
- `ServiceAccount`

This keeps the deployment model small while staying production-friendly.

## Structure

- `charts/microservice/`: reusable backend application chart
- `values/uat-microservice.yaml`: UAT microservice values
- `values/prod-microservice.yaml`: PROD microservice values
- `values/uat-monolith.yaml`: UAT monolith values
- `values/prod-monolith.yaml`: PROD monolith values

## Prerequisite

Install External Secrets Operator and create a `ClusterSecretStore` named `vault-backend` that points to Vault. The chart expects Vault KV paths like `secret/data/<env>/app`.

## Commands

```bash
helm upgrade --install microservice infra/helm/charts/microservice \
  -f infra/helm/values/uat-microservice.yaml \
  --namespace enterprise-uat --create-namespace

helm upgrade --install monolith infra/helm/charts/microservice \
  -f infra/helm/values/uat-monolith.yaml \
  --namespace enterprise-uat --create-namespace

helm upgrade --install microservice infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-prod --create-namespace

helm upgrade --install monolith infra/helm/charts/microservice \
  -f infra/helm/values/prod-monolith.yaml \
  --namespace enterprise-prod --create-namespace
```

## Secrets model

Secrets are no longer described inline in the deployment template. Each release maps Vault properties to the exact environment variables the apps already consume:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
