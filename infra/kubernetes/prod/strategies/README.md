# PROD Advanced Rollout Manifests

These manifests are optional PROD-only rollout variants for EKS:

- `microservice-canary-deployment.yaml`
- `microservice-canary-service.yaml`
- `microservice-blue-deployment.yaml`
- `microservice-green-deployment.yaml`
- `microservice-active-service.yaml`

The base `infra/kubernetes/prod/` directory stays aligned with UAT so the core app layout is the same in both environments.
