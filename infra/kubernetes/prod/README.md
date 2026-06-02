# PROD Kubernetes Manifests

Namespace: `enterprise-prod`

## Files

- Stable microservice: `microservice-configmap.yaml`, `microservice-secret.yaml`, `microservice-deployment.yaml`, `microservice-service.yaml`, `microservice-hpa.yaml`
- Monolith: `monolith-configmap.yaml`, `monolith-secret.yaml`, `monolith-deployment.yaml`, `monolith-service.yaml`
- Frontend: `frontend-deployment.yaml`, `frontend-service.yaml`
- Advanced rollout variants: `strategies/`

## Deployment Strategies

- Rolling
- Canary
- Blue-Green

## Notes

- PROD runs on EKS, but the base app manifest set intentionally matches UAT.
- Image and secret values are rendered by Jenkins at deploy time.
- Canary and blue-green manifests remain available under `strategies/` for controlled rollout experiments.
