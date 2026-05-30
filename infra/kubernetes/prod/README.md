# PROD Kubernetes Manifests

Namespace: `enterprise-prod`

## Files

- Stable microservice: `deployment.yaml`, `service.yaml`
- Canary resources: `deployment-canary.yaml`, `service-canary.yaml`
- Blue-green resources: `deployment-blue.yaml`, `deployment-green.yaml`, `service-active.yaml`
- Frontend: `frontend-deployment.yaml`, `frontend-service.yaml`
- Autoscaling: `hpa.yaml`

## Deployment Strategies

- Rolling
- Canary
- Blue-Green

All image updates are done through YAML placeholder rendering in pipeline.