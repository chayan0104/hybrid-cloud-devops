# Helm Charts - Setup and Deployment

Location: `infra/helm/`

## Purpose

Helm is optional for microservice deployment where chart-based release control is preferred over raw manifests.

## Structure

- `charts/microservice/`: chart definition and templates
- `values/uat-microservice.yaml`: UAT overrides
- `values/prod-microservice.yaml`: PROD overrides

## Commands

```bash
helm upgrade --install microservice-uat infra/helm/charts/microservice \
  -f infra/helm/values/uat-microservice.yaml \
  --namespace enterprise-uat --create-namespace

helm upgrade --install microservice-prod infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-prod --create-namespace
```