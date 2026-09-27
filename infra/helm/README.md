# Helm Charts - Optional Deployment Path

Location: `infra/helm/`

## What changed

The chart is an optional alternative deployment example. The current Jenkins UAT/PROD jobs use environment-specific Kubernetes YAML instead. It renders:

- `ConfigMap` for non-secret runtime configuration
- `ExternalSecret` for Vault-backed secret sync
- `Deployment` with rolling updates, probes, and container hardening
- `Service`
- `HorizontalPodAutoscaler`
- `PodDisruptionBudget`
- `ServiceAccount`

The chart requires External Secrets Operator and a Vault `ClusterSecretStore`; it is not invoked by the current Jenkins jobs.

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

helm upgrade --install microservice infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-prod --create-namespace
```

Monolith values remain for the optional UAT Kubernetes lab. Do not use the PROD monolith values for the selected hybrid design; PROD keeps the WAR on WebLogic/EC2.

## Secrets model

Configure each sample image repository/tag for the JFrog instance before installing. The optional chart maps Vault properties to the exact environment variables the apps consume:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
