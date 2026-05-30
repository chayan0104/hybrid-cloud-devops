# UAT Kubernetes Manifests

Namespace: `enterprise-uat`

## Files

- `namespace.yaml`
- `deployment.yaml` (microservice)
- `service.yaml` (microservice)
- `hpa.yaml`
- `frontend-deployment.yaml`
- `frontend-service.yaml`

## Apply

```bash
kubectl apply -f infra/kubernetes/uat/
```

Use pipeline YAML rendering for `__MICROSERVICE_IMAGE__` and `__FRONTEND_IMAGE__` placeholders.