# Helm Deployment Guide

Helm is used for the microservice deployment path.

## Charts

- `charts/microservice`

## Install or upgrade per environment

UAT microservice:

```bash
helm upgrade --install microservice-uat infra/helm/charts/microservice \
  -f infra/helm/values/uat-microservice.yaml \
  --namespace enterprise-uat --create-namespace
```

PROD microservice:

```bash
helm upgrade --install microservice-prod infra/helm/charts/microservice \
  -f infra/helm/values/prod-microservice.yaml \
  --namespace enterprise-prod --create-namespace
```

Main-app is deployed as WAR to Tomcat in UAT and PROD.
Frontend is deployed as container image in Kubernetes/EKS.