# Kubernetes Manifests

Location: `infra/kubernetes/`

## Layout Goal

UAT and PROD now use the same core app manifest layout even though UAT runs on `kind` and PROD runs on EKS. The cluster changes, but the app YAML shape stays the same.

## Environments

- `uat/`: frontend, microservice, and monolith in `enterprise-uat`
- `prod/`: frontend, microservice, and monolith in `enterprise-prod` plus canary and blue-green variants
- `perf-prod/`: frontend and microservice in `enterprise-perf-prod`

## Core App Pattern

Each backend app keeps its own YAML files:

- `microservice-configmap.yaml`
- `microservice-secret.yaml`
- `microservice-deployment.yaml`
- `microservice-service.yaml`
- `microservice-hpa.yaml`
- `monolith-configmap.yaml`
- `monolith-secret.yaml`
- `monolith-deployment.yaml`
- `monolith-service.yaml`

Frontend keeps:

- `frontend-deployment.yaml`
- `frontend-service.yaml`

## Secret Handling

Secret templates are committed without values. Jenkins renders the real values into temporary `*.rendered.yaml` files during deployment, so the same manifest model works on both `kind` and EKS.

## Quick Commands

```bash
kubectl apply -f infra/kubernetes/uat/
kubectl apply -f infra/kubernetes/prod/
kubectl apply -f infra/kubernetes/perf-prod/
```

## Rollout Verification

```bash
kubectl rollout status deployment/microservice -n enterprise-uat
kubectl rollout status deployment/monolith -n enterprise-uat
kubectl rollout status deployment/frontend -n enterprise-uat
```

## Related

- Helm path: `infra/helm/README.md`
- CI/CD: `infra/jenkins/README.md`
