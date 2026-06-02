# UAT Kubernetes Manifests

Namespace: `enterprise-uat`

## Files

- `namespace.yaml`
- `microservice-configmap.yaml`
- `microservice-secret.yaml`
- `microservice-deployment.yaml`
- `microservice-service.yaml`
- `microservice-hpa.yaml`
- `monolith-configmap.yaml`
- `monolith-secret.yaml`
- `monolith-deployment.yaml`
- `monolith-service.yaml`
- `frontend-deployment.yaml`
- `frontend-service.yaml`

## Apply

```bash
kubectl apply -f infra/kubernetes/uat/
```

## Notes

- `__MICROSERVICE_IMAGE__`, `__MAIN_APP_IMAGE__`, and `__FRONTEND_IMAGE__` are still rendered by the pipeline.
- UAT is intended to run on `kind`, but it uses the same app manifest naming and structure as PROD.
- Secrets are rendered by Jenkins into temporary files at deploy time, not stored in git.
- Backend deployments consume config with `envFrom`, which keeps the workload YAML smaller and easier to maintain.
