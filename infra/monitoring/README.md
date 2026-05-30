# Monitoring Stack

Location: `infra/monitoring/`

## Components

- `prometheus/`: scrape config
- `alertmanager/`: alert routing config
- `prometheus-grafana-alertmanager/`: local monitoring compose stack
- `newrelic/`: optional New Relic integration assets

## Local Startup

```bash
cd infra/monitoring/prometheus-grafana-alertmanager
docker compose -f docker-compose.monitoring.yml up -d
```

## Endpoints

- Prometheus: `http://localhost:9090`
- Alertmanager: `http://localhost:9093`
- Grafana: `http://localhost:3000`