# Reusable Backend Helm Chart

Location: `infra/helm/charts/microservice/`

## Purpose

This chart now deploys either the microservice or monolith backend by swapping values files. It separates non-secret config from Vault-sourced secrets and includes the operational pieces normally expected in production.

## Rendered resources

- `ConfigMap`
- `ExternalSecret`
- `Deployment`
- `Service`
- `HorizontalPodAutoscaler`
- `PodDisruptionBudget`
- `ServiceAccount`

Use environment override files from `infra/helm/values/`.
