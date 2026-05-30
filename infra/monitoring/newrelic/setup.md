# New Relic Integration

New Relic is optional but recommended for UAT and PROD APM correlation.

## UAT Docker deployment

```bash
cd infra/monitoring/newrelic
cp .env.example .env
# set NEW_RELIC_LICENSE_KEY and NEW_RELIC_CLUSTER_NAME
docker compose -f docker-compose.uat.yml up -d
```

## Kubernetes deployment

```bash
kubectl apply -f infra/monitoring/newrelic/k8s/newrelic-infra-daemonset.yaml
```