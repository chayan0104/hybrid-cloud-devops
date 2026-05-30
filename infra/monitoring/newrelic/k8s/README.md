# New Relic K8s Manifests

Location: `infra/monitoring/newrelic/k8s/`

Deploy infra agent daemonset:

```bash
kubectl apply -f infra/monitoring/newrelic/k8s/newrelic-infra-daemonset.yaml
```

Requires `newrelic-credentials` secret with license key.