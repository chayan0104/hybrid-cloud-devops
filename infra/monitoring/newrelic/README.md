# New Relic Integration

Location: `infra/monitoring/newrelic/`

## Files

- `setup.md`: integration steps
- `docker-compose.uat.yml`: local/UAT-style agent deployment
- `k8s/newrelic-infra-daemonset.yaml`: Kubernetes daemonset deployment

Set license key in `.env` or Kubernetes secret before deployment.