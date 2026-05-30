# Local Monitoring Compose

Location: `infra/monitoring/prometheus-grafana-alertmanager/`

Run stack:

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

Services:

- Prometheus: `9090`
- Alertmanager: `9093`
- Grafana: `3000`
- New Relic infra agent (optional via env)