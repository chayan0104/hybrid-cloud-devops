# Single-Namespace Kubernetes Lab

Location: `infra/k8s/`

This is a standalone lab/reference bundle for `enterprise-app`. It is not the canonical UAT/PROD deployment path; those Jenkins jobs use `infra/kubernetes/uat/` and `infra/kubernetes/prod/`. Do not apply this bundle to a production cluster.

## Contents

- Frontend, monolith, and microservice deployments with services and health probes
- MySQL 8 deployment with a PVC and health probes
- Resource requests/limits, RBAC, namespace quota, and example NetworkPolicies
- Example canary/blue-green resources and Prometheus custom resources

The database in this lab is a single MySQL pod with persistent volume storage. It is not a substitute for managed RDS, backups, or high availability.

## Prepare Secrets and Schema

Create the namespace and ConfigMap containing the existing SQL scripts:

```bash
kubectl apply -f infra/k8s/namespace.yaml
kubectl create configmap mysql-init-scripts \
  --from-file=infra/database/init-scripts \
  -n enterprise-app --dry-run=client -o yaml | kubectl apply -f -
```

Render `secrets.yaml` with local/test values before applying it. The template requires `DB_HOST`, `DB_PORT` (`3306`), `DB_NAME`, `DB_USER`, `DB_PASSWORD`, and `MYSQL_ROOT_PASSWORD`. Do not put real or reused credentials in shell history or Git. The lab bundle does not include a secret-rendering helper.

The MySQL image runs the scripts from `infra/database/init-scripts/` only when its data directory is empty. Existing PVC data is not reinitialized.

## Apply the Lab

The deployment files contain image placeholders, and `secrets.yaml` contains value placeholders. There is no checked-in renderer or one-command deploy for this lab; applying the raw files will not produce a working stack. Render and inspect the database secrets and immutable image references first, then apply the namespace, generated SQL ConfigMap, shared ConfigMaps/secrets, and rendered workload files in dependency order.

Use the environment-specific UAT/PROD Jenkins jobs for the automated deployment path. Optional VPA and Prometheus resources require their respective cluster add-ons.

## Verify

```bash
kubectl get pods,services,pvc -n enterprise-app
kubectl rollout status deployment/mysql -n enterprise-app
kubectl rollout status deployment/microservice -n enterprise-app
kubectl port-forward -n enterprise-app svc/frontend 8080:80
```

The lab NetworkPolicies, ingress controller, storage class, and custom-resource definitions must match the cluster before use. Validate effective policy connectivity before expecting application-to-database traffic.