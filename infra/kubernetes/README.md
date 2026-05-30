# Kubernetes Deployment - Setup and Workflow

Location: `infra/kubernetes/`

## Environments

- `uat/`: frontend + microservice in `enterprise-uat`
- `prod/`: frontend + microservice in `enterprise-prod` with rolling/canary/blue-green resources
- `perf-prod/`: perf environment for frontend + microservice in `enterprise-perf-prod`

## Core Pattern

- Frontend image placeholder: `__FRONTEND_IMAGE__`
- Microservice image placeholder: `__MICROSERVICE_IMAGE__`
- Pipelines render YAML with actual image tags and apply.

## Quick Commands

```bash
kubectl apply -f infra/kubernetes/uat/
kubectl apply -f infra/kubernetes/prod/
kubectl apply -f infra/kubernetes/perf-prod/
```

## Rollout Verification

```bash
kubectl rollout status deployment/frontend -n enterprise-uat
kubectl rollout status deployment/microservice -n enterprise-uat
```

## Related

- CI/CD: `infra/jenkins/README.md`
- Setup guide: `docs/SETUP-AND-DEPLOYMENT-GUIDE.md`